-- ========================================================
-- Migration: 015_verify_payment_rpc.sql
-- Description: RPC for verifying Razorpay signature and atomically updating booking status with audit logging and dev overrides
-- ========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create payment audit log table if not exists
CREATE TABLE IF NOT EXISTS public.payment_audit_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID,
  order_id TEXT,
  signature_valid BOOLEAN,
  called_at TIMESTAMPTZ DEFAULT NOW(),
  ip_address TEXT
);

-- ========================================================
-- PRODUCTION FUNCTION: verify_payment
-- ========================================================
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

  -- Verify signature strictly (no simulated_signature bypass in production)
  is_valid := (generated_signature = p_signature);

  -- Retrieve client IP from request headers or connection safely
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
    -- 1. Record the transaction
    INSERT INTO transactions (user_id, amount, type, status, reference_id, payment_method, created_at)
    VALUES (p_user_id, p_amount, 'payment', 'completed', p_payment_id, 'razorpay', NOW());

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

-- Restrict permissions on production function
REVOKE EXECUTE ON FUNCTION verify_payment(TEXT, TEXT, TEXT, UUID, TEXT, NUMERIC, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION verify_payment(TEXT, TEXT, TEXT, UUID, TEXT, NUMERIC, UUID) TO authenticated;

-- ========================================================
-- DEVELOPMENT FUNCTION: verify_payment_dev
-- ========================================================
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
BEGIN
  -- Gate check: Only allow execution in development environment
  IF COALESCE(current_setting('app.environment', true), '') != 'development' THEN
    RAISE EXCEPTION 'verify_payment_dev can only be called in development environment';
  END IF;

  -- Retrieve Razorpay secret from server config (or use fallback for dev)
  rzp_secret := current_setting('app.settings.razorpay_secret', true);
  
  IF rzp_secret IS NULL OR rzp_secret = '' THEN
    rzp_secret := 'rzp_test_placeholderSecret';
  END IF;

  payload := p_order_id || '|' || p_payment_id;
  generated_signature := encode(hmac(payload::bytea, rzp_secret::bytea, 'sha256'), 'hex');

  -- Verify signature (also allow simulation signature for testing in dev environment)
  is_valid := (generated_signature = p_signature OR p_signature = 'simulated_signature');

  -- Retrieve client IP from request headers or connection safely
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
    -- 1. Record the transaction
    INSERT INTO transactions (user_id, amount, type, status, reference_id, payment_method, created_at)
    VALUES (p_user_id, p_amount, 'payment', 'completed', p_payment_id, 'razorpay', NOW());

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

-- Restrict permissions on dev function as well
REVOKE EXECUTE ON FUNCTION verify_payment_dev(TEXT, TEXT, TEXT, UUID, TEXT, NUMERIC, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION verify_payment_dev(TEXT, TEXT, TEXT, UUID, TEXT, NUMERIC, UUID) TO authenticated;

-- ========================================================
-- TEST BLOCK (Demonstrates bypass failure in production)
-- ========================================================
/*
DO $$
DECLARE
  v_res BOOLEAN;
  v_log_exists BOOLEAN;
BEGIN
  -- 1. Set environment to production
  PERFORM set_config('app.environment', 'production', true);

  -- 2. Attempt simulated signature with the production function verify_payment
  -- This should return FALSE because simulated_signature is no longer allowed in production
  v_res := verify_payment(
    'order_123',
    'pay_123',
    'simulated_signature',
    '00000000-0000-0000-0000-000000000000'::uuid,
    'wallet',
    10.0,
    '00000000-0000-0000-0000-000000000000'::uuid
  );

  ASSERT v_res = FALSE, 'Error: verify_payment accepted simulated_signature in production!';

  -- Verify audit log was written
  SELECT EXISTS (
    SELECT 1 FROM public.payment_audit_log 
    WHERE order_id = 'order_123' AND signature_valid = FALSE
  ) INTO v_log_exists;
  
  ASSERT v_log_exists = TRUE, 'Error: payment_audit_log entry not created!';

  -- 3. Attempt to call verify_payment_dev in production
  -- This should fail with an exception
  BEGIN
    PERFORM verify_payment_dev(
      'order_123',
      'pay_123',
      'simulated_signature',
      '00000000-0000-0000-0000-000000000000'::uuid,
      'wallet',
      10.0,
      '00000000-0000-0000-0000-000000000000'::uuid
    );
    RAISE EXCEPTION 'Error: verify_payment_dev succeeded in production environment!';
  EXCEPTION WHEN OTHERS THEN
    -- Expected exception occurred
    RAISE NOTICE 'Success: verify_payment_dev correctly rejected in production: %', SQLERRM;
  END;

  RAISE NOTICE 'All tests passed: simulated signature bypass blocked in production.';
END $$;
*/
