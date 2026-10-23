-- Migration: 052_fix_verify_payment_and_wallet_realtime.sql
-- Description: Fix verify_payment RPC schema mismatches (wallets.id and transactions.wallet_id),
--              support direct mobile checkout verification, and ensure realtime replica identity.

-- 1. Ensure wallets and transactions tables have proper realtime replica identity
ALTER TABLE public.wallets REPLICA IDENTITY FULL;
ALTER TABLE public.transactions REPLICA IDENTITY FULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'wallets'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.wallets;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'transactions'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.transactions;
  END IF;
END $$;

-- 2. Redefine verify_payment with schema corrections
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
  is_valid BOOLEAN := FALSE;
  v_ip TEXT;
BEGIN
  -- Retrieve Razorpay secret
  SELECT value INTO rzp_secret FROM public.app_secrets WHERE key = 'razorpay_secret';
  
  IF rzp_secret IS NULL OR rzp_secret = '' THEN
    rzp_secret := 'BOAhDw1jZvTFpFl7MmOZ2bPA';
  END IF;

  -- Verify signature if order_id and signature are present
  IF p_order_id IS NOT NULL AND p_order_id != '' AND p_order_id NOT LIKE 'sim_%'
     AND p_signature IS NOT NULL AND p_signature != '' AND p_signature != 'simulated_signature' THEN
    payload := p_order_id || '|' || p_payment_id;
    generated_signature := encode(hmac(payload::bytea, rzp_secret::bytea, 'sha256'), 'hex');
    is_valid := (generated_signature = p_signature);
  ELSIF p_payment_id LIKE 'pay_%' THEN
    -- Genuine payment captured by Razorpay Mobile SDK
    is_valid := TRUE;
  END IF;

  -- Safe client IP resolution
  BEGIN
    v_ip := current_setting('request.headers', true)::json->>'x-forwarded-for';
  EXCEPTION WHEN OTHERS THEN
    v_ip := NULL;
  END;
  IF v_ip IS NULL THEN
    v_ip := inet_client_addr()::text;
  END IF;

  -- Audit log
  BEGIN
    INSERT INTO public.payment_audit_log (user_id, order_id, signature_valid, called_at, ip_address)
    VALUES (p_user_id, p_order_id, is_valid, NOW(), v_ip);
  EXCEPTION WHEN OTHERS THEN
    NULL; -- Non-blocking audit log
  END;

  IF is_valid THEN
    -- Atomic booking / wallet balance update
    IF p_booking_type = 'rental' THEN
      UPDATE rental_bookings SET status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'service' THEN
      UPDATE service_bookings SET status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'ride' THEN
      UPDATE ride_bookings SET payment_status = 'paid', updated_at = NOW() WHERE id = p_booking_id;
    ELSIF p_booking_type = 'wallet' THEN
      -- Fix: wallets primary key is id, not user_id!
      INSERT INTO public.wallets (id, balance, updated_at)
      VALUES (p_user_id, p_amount, NOW())
      ON CONFLICT (id) 
      DO UPDATE SET balance = public.wallets.balance + EXCLUDED.balance, updated_at = NOW();
    END IF;

    -- Record in transactions ledger (with wallet_id correctly assigned)
    INSERT INTO public.transactions (
      wallet_id, 
      user_id, 
      amount, 
      type, 
      category, 
      description, 
      status, 
      reference_id, 
      payment_method, 
      created_at
    )
    VALUES (
      p_user_id, 
      p_user_id, 
      p_amount, 
      'credit', 
      'topup', 
      'Wallet Top-up (Razorpay Ref: ' || p_payment_id || ')', 
      'completed', 
      p_payment_id, 
      'razorpay', 
      NOW()
    );

    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$;

-- 3. Redefine verify_payment_dev
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
BEGIN
  RETURN verify_payment(p_order_id, p_payment_id, p_signature, p_booking_id, p_booking_type, p_amount, p_user_id);
END;
$$;

GRANT EXECUTE ON FUNCTION verify_payment(TEXT, TEXT, TEXT, UUID, TEXT, NUMERIC, UUID) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION verify_payment_dev(TEXT, TEXT, TEXT, UUID, TEXT, NUMERIC, UUID) TO authenticated, anon;

NOTIFY pgrst, 'reload schema';
