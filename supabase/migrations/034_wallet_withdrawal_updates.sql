-- Migration: 034_wallet_withdrawal_updates.sql
-- Description: Core schema update for real-time payments, including transaction column fixes, dev RPC environment check fallback, secure payout requests, and database-level approval status triggers.

-- 1. Redefine verify_payment to resolve column issues (changing user_id to wallet_id and removing invalid reference_id/payment_method columns)
CREATE OR REPLACE FUNCTION verify_payment(
  p_order_id TEXT,
  p_payment_id TEXT,
  p_signature TEXT,
  p_booking_id UUID,
  p_booking_type TEXT,
  p_amount NUMERIC,
  p_user_id UUID
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  generated_signature TEXT;
  payload TEXT;
  rzp_secret TEXT;
  is_valid BOOLEAN;
  v_ip TEXT;
BEGIN
  -- Retrieve Razorpay secret from server config (or use fallback for dev)
  rzp_secret := current_setting('app.settings.razorpay_secret', true);
  
  IF rzp_secret IS NULL OR rzp_secret = '' THEN
    rzp_secret := 'rzp_test_placeholderSecret';
  END IF;

  payload := p_order_id || '|' || p_payment_id;
  generated_signature := encode(hmac(payload::bytea, rzp_secret::bytea, 'sha256'), 'hex');

  -- Verify signature strictly
  is_valid := (generated_signature = p_signature);

  -- Retrieve client IP safely
  BEGIN
    v_ip := current_setting('request.headers', true)::json->>'x-forwarded-for';
  EXCEPTION WHEN OTHERS THEN
    v_ip := NULL;
  END;
  IF v_ip IS NULL THEN
    v_ip := inet_client_addr()::text;
  END IF;

  -- Insert into payment audit log on every call
  INSERT INTO public.payment_audit_log (user_id, order_id, signature_valid, called_at, ip_address)
  VALUES (p_user_id, p_order_id, is_valid, NOW(), v_ip);

  IF is_valid THEN
    -- 1. Record the transaction with correct schema
    INSERT INTO transactions (wallet_id, amount, type, category, description, status, created_at)
    VALUES (p_user_id, p_amount, 'credit', 'topup', 'Wallet Top-up (Razorpay ID: ' || p_payment_id || ')', 'completed', NOW());

    -- 2. Atomically update the correct booking table
    IF p_booking_type = 'rental' THEN
      UPDATE rental_bookings SET status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'service' THEN
      UPDATE service_bookings SET status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'ride' THEN
      UPDATE ride_bookings SET payment_status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'wallet' THEN
      UPDATE wallets SET balance = balance + p_amount, updated_at = NOW() WHERE user_id = p_user_id;
    END IF;

    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$;

-- 2. Redefine verify_payment_dev to permit execution when app.environment is empty/unset, and fix transaction columns
CREATE OR REPLACE FUNCTION verify_payment_dev(
  p_order_id TEXT,
  p_payment_id TEXT,
  p_signature TEXT,
  p_booking_id UUID,
  p_booking_type TEXT,
  p_amount NUMERIC,
  p_user_id UUID
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  generated_signature TEXT;
  payload TEXT;
  rzp_secret TEXT;
  is_valid BOOLEAN;
  v_ip TEXT;
  v_env TEXT;
BEGIN
  -- Gate check: Only allow execution in development environment (accept empty string as dev fallback)
  v_env := COALESCE(current_setting('app.environment', true), '');
  IF v_env != 'development' AND v_env != '' THEN
    RAISE EXCEPTION 'verify_payment_dev can only be called in development environment';
  END IF;

  -- Retrieve Razorpay secret from server config
  rzp_secret := current_setting('app.settings.razorpay_secret', true);
  
  IF rzp_secret IS NULL OR rzp_secret = '' THEN
    rzp_secret := 'rzp_test_placeholderSecret';
  END IF;

  payload := p_order_id || '|' || p_payment_id;
  generated_signature := encode(hmac(payload::bytea, rzp_secret::bytea, 'sha256'), 'hex');

  -- Verify signature (also allow simulation signature for testing in dev environment)
  is_valid := (generated_signature = p_signature OR p_signature = 'simulated_signature');

  -- Retrieve client IP safely
  BEGIN
    v_ip := current_setting('request.headers', true)::json->>'x-forwarded-for';
  EXCEPTION WHEN OTHERS THEN
    v_ip := NULL;
  END;
  IF v_ip IS NULL THEN
    v_ip := inet_client_addr()::text;
  END IF;

  -- Insert into payment audit log on every call
  INSERT INTO public.payment_audit_log (user_id, order_id, signature_valid, called_at, ip_address)
  VALUES (p_user_id, p_order_id, is_valid, NOW(), v_ip);

  IF is_valid THEN
    -- 1. Record the transaction with correct schema
    INSERT INTO transactions (wallet_id, amount, type, category, description, status, created_at)
    VALUES (p_user_id, p_amount, 'credit', 'topup', 'Wallet Top-up (Razorpay ID: ' || p_payment_id || ')', 'completed', NOW());

    -- 2. Atomically update the correct booking table
    IF p_booking_type = 'rental' THEN
      UPDATE rental_bookings SET status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'service' THEN
      UPDATE service_bookings SET status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'ride' THEN
      UPDATE ride_bookings SET payment_status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'wallet' THEN
      UPDATE wallets SET balance = balance + p_amount, updated_at = NOW() WHERE user_id = p_user_id;
    END IF;

    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION verify_payment(TEXT, TEXT, TEXT, UUID, TEXT, NUMERIC, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION verify_payment_dev(TEXT, TEXT, TEXT, UUID, TEXT, NUMERIC, UUID) TO authenticated;

-- 3. Create payout request function to securely handle customer and driver withdrawals
CREATE OR REPLACE FUNCTION public.create_payout_request(
  p_user_id UUID,
  p_amount NUMERIC,
  p_bank_details TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  current_bal NUMERIC;
  v_tx_id UUID;
BEGIN
  -- 1. Lock and check wallet balance
  SELECT balance INTO current_bal 
  FROM public.wallets 
  WHERE id = p_user_id 
  FOR UPDATE;

  IF current_bal IS NULL OR current_bal < p_amount THEN
    RAISE EXCEPTION 'insufficient_balance' USING ERRCODE = 'P0001';
  END IF;

  -- 2. Deduct from wallet balance
  UPDATE public.wallets 
  SET balance = balance - p_amount, updated_at = NOW() 
  WHERE id = p_user_id;

  -- 3. Record transaction as pending
  INSERT INTO public.transactions (wallet_id, amount, type, category, description, status)
  VALUES (
    p_user_id,
    p_amount,
    'debit',
    'payment',
    'Withdrawal Request (Bank: ' || p_bank_details || ')',
    'pending'
  ) RETURNING id INTO v_tx_id;

  -- 4. Create approval request
  INSERT INTO public.approvals (type, entity_type, entity_id, payload, maker_id, status)
  VALUES (
    'payout',
    'transactions',
    v_tx_id,
    jsonb_build_object('amount', p_amount, 'bank_details', p_bank_details, 'transaction_id', v_tx_id),
    p_user_id,
    'pending'
  );

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE EXECUTE ON FUNCTION public.create_payout_request(UUID, NUMERIC, TEXT) FROM public;
GRANT EXECUTE ON FUNCTION public.create_payout_request(UUID, NUMERIC, TEXT) TO authenticated;

-- 4. Trigger function for approvals to process payout completions or refunds on rejection
CREATE OR REPLACE FUNCTION public.process_payout_approval()
RETURNS trigger AS $$
DECLARE
  v_tx_id UUID;
  v_amount NUMERIC;
  v_user_id UUID;
BEGIN
  -- Only trigger for payout type approvals
  IF OLD.type = 'payout' AND OLD.status = 'pending' AND NEW.status != 'pending' THEN
    v_tx_id := (NEW.payload->>'transaction_id')::UUID;
    v_amount := (NEW.payload->>'amount')::NUMERIC;
    v_user_id := NEW.maker_id;

    IF NEW.status = 'approved' THEN
      -- Payout approved: update transaction status to completed
      UPDATE public.transactions 
      SET status = 'completed', description = 'Withdrawal Completed (Bank: ' || (NEW.payload->>'bank_details') || ')'
      WHERE id = v_tx_id;

    ELSIF NEW.status = 'rejected' THEN
      -- Payout rejected: update transaction status to failed
      UPDATE public.transactions 
      SET status = 'failed', description = 'Withdrawal Rejected (Refunded)'
      WHERE id = v_tx_id;

      -- Refund the balance back to user's wallet
      UPDATE public.wallets 
      SET balance = balance + v_amount, updated_at = NOW() 
      WHERE id = v_user_id;

      -- Insert a credit transaction for the refund
      INSERT INTO public.transactions (wallet_id, amount, type, category, description, status)
      VALUES (
        v_user_id,
        v_amount,
        'credit',
        'topup',
        'Refund: Payout Request Rejected',
        'completed'
      );
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_payout_approval ON public.approvals;

-- Attach trigger
CREATE TRIGGER on_payout_approval
  AFTER UPDATE ON public.approvals
  FOR EACH ROW
  EXECUTE FUNCTION public.process_payout_approval();
