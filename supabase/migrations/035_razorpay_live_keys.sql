-- Migration: 035_razorpay_live_keys.sql
-- Description: Create a secure config table and redefine RPCs to avoid ALTER DATABASE permission issues

CREATE TABLE IF NOT EXISTS public.app_secrets (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

REVOKE ALL ON public.app_secrets FROM PUBLIC;
REVOKE ALL ON public.app_secrets FROM authenticated;
REVOKE ALL ON public.app_secrets FROM anon;

INSERT INTO public.app_secrets (key, value)
VALUES ('razorpay_secret', 'BOAhDw1jZvTFpFl7MmOZ2bPA')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- Redefine verify_payment
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
  SELECT value INTO rzp_secret FROM public.app_secrets WHERE key = 'razorpay_secret';
  
  IF rzp_secret IS NULL OR rzp_secret = '' THEN
    rzp_secret := 'rzp_test_placeholderSecret';
  END IF;

  payload := p_order_id || '|' || p_payment_id;
  generated_signature := encode(hmac(payload::bytea, rzp_secret::bytea, 'sha256'), 'hex');

  is_valid := (generated_signature = p_signature);

  BEGIN
    v_ip := current_setting('request.headers', true)::json->>'x-forwarded-for';
  EXCEPTION WHEN OTHERS THEN
    v_ip := NULL;
  END;
  IF v_ip IS NULL THEN
    v_ip := inet_client_addr()::text;
  END IF;

  INSERT INTO public.payment_audit_log (user_id, order_id, signature_valid, called_at, ip_address)
  VALUES (p_user_id, p_order_id, is_valid, NOW(), v_ip);

  IF is_valid THEN
    INSERT INTO transactions (user_id, amount, type, status, reference_id, payment_method, created_at)
    VALUES (p_user_id, p_amount, 'payment', 'completed', p_payment_id, 'razorpay', NOW());

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

-- Redefine verify_payment_dev
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
  IF COALESCE(current_setting('app.environment', true), '') != 'development' THEN
    RAISE EXCEPTION 'verify_payment_dev can only be called in development environment';
  END IF;

  SELECT value INTO rzp_secret FROM public.app_secrets WHERE key = 'razorpay_secret';
  
  IF rzp_secret IS NULL OR rzp_secret = '' THEN
    rzp_secret := 'rzp_test_placeholderSecret';
  END IF;

  payload := p_order_id || '|' || p_payment_id;
  generated_signature := encode(hmac(payload::bytea, rzp_secret::bytea, 'sha256'), 'hex');

  is_valid := (generated_signature = p_signature OR p_signature = 'simulated_signature');

  BEGIN
    v_ip := current_setting('request.headers', true)::json->>'x-forwarded-for';
  EXCEPTION WHEN OTHERS THEN
    v_ip := NULL;
  END;
  IF v_ip IS NULL THEN
    v_ip := inet_client_addr()::text;
  END IF;

  INSERT INTO public.payment_audit_log (user_id, order_id, signature_valid, called_at, ip_address)
  VALUES (p_user_id, p_order_id, is_valid, NOW(), v_ip);

  IF is_valid THEN
    INSERT INTO transactions (user_id, amount, type, status, reference_id, payment_method, created_at)
    VALUES (p_user_id, p_amount, 'payment', 'completed', p_payment_id, 'razorpay', NOW());

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


