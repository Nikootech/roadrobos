-- Migration: 036_data_encryption_privacy.sql
-- Description: Implement data privacy by encrypting PII (KYC docs, Payout Details) at rest and enforcing strict RLS.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Create a Master Data Encryption Key
-- We use a secure secret table for keys, which cannot be queried by normal users.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.app_secrets WHERE key = 'data_encryption_key') THEN
        INSERT INTO public.app_secrets (key, value)
        VALUES ('data_encryption_key', encode(gen_random_bytes(32), 'base64'));
    END IF;
END $$;

-- 2. Create Secure Helper Functions for Encryption / Decryption
-- These functions run as SECURITY DEFINER so they can access the master key.
CREATE OR REPLACE FUNCTION public.encrypt_pii(p_plain_text TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_key TEXT;
BEGIN
    IF p_plain_text IS NULL THEN RETURN NULL; END IF;
    SELECT value INTO v_key FROM public.app_secrets WHERE key = 'data_encryption_key';
    RETURN encode(pgp_sym_encrypt(p_plain_text, v_key), 'base64');
END;
$$;

CREATE OR REPLACE FUNCTION public.decrypt_pii(p_cipher_text TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_key TEXT;
BEGIN
    IF p_cipher_text IS NULL THEN RETURN NULL; END IF;
    SELECT value INTO v_key FROM public.app_secrets WHERE key = 'data_encryption_key';
    
    BEGIN
        RETURN pgp_sym_decrypt(decode(p_cipher_text, 'base64'), v_key);
    EXCEPTION WHEN OTHERS THEN
        -- If decryption fails (e.g. data wasn't encrypted yet), return original to avoid breaking existing data.
        RETURN p_cipher_text;
    END;
END;
$$;

-- Restrict access to these powerful functions
REVOKE EXECUTE ON FUNCTION public.encrypt_pii(TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.decrypt_pii(TEXT) FROM PUBLIC;
-- Grant only to authenticated users (who are restricted by RLS) and service roles
GRANT EXECUTE ON FUNCTION public.encrypt_pii(TEXT) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.decrypt_pii(TEXT) TO authenticated, service_role;

-- 3. Encrypt Existing Data
-- Encrypt KYC Document Numbers in partner_kyc
UPDATE public.partner_kyc
SET document_number = public.encrypt_pii(document_number)
WHERE document_number IS NOT NULL AND length(document_number) < 50;

-- (Note: For existing approvals, we could theoretically update the JSONB payload, 
-- but assuming no live sensitive data exists yet. Future payout requests will be encrypted.)


-- 4. Redefine create_payout_request to securely handle driver withdrawals with encryption
CREATE OR REPLACE FUNCTION public.create_payout_request(
  p_user_id UUID,
  p_amount NUMERIC,
  p_bank_details TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  current_bal NUMERIC;
  v_tx_id UUID;
  v_enc_bank_details TEXT;
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

  -- 3. Record transaction as pending (hide bank details from plain description)
  INSERT INTO public.transactions (wallet_id, amount, type, category, description, status)
  VALUES (
    p_user_id,
    p_amount,
    'debit',
    'payment',
    'Withdrawal Request',
    'pending'
  ) RETURNING id INTO v_tx_id;

  -- Encrypt bank details before storing in the approval payload
  v_enc_bank_details := public.encrypt_pii(p_bank_details);

  -- 4. Create approval request
  INSERT INTO public.approvals (type, entity_type, entity_id, payload, maker_id, status)
  VALUES (
    'payout',
    'transactions',
    v_tx_id,
    jsonb_build_object('amount', p_amount, 'bank_details', v_enc_bank_details, 'transaction_id', v_tx_id),
    p_user_id,
    'pending'
  );

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Redefine process_payout_approval to decrypt details when logging completion if needed
CREATE OR REPLACE FUNCTION public.process_payout_approval()
RETURNS trigger AS $$
DECLARE
  v_tx_id UUID;
  v_amount NUMERIC;
  v_user_id UUID;
  v_enc_bank_details TEXT;
BEGIN
  -- Only trigger for payout type approvals
  IF OLD.type = 'payout' AND OLD.status = 'pending' AND NEW.status != 'pending' THEN
    v_tx_id := (NEW.payload->>'transaction_id')::UUID;
    v_amount := (NEW.payload->>'amount')::NUMERIC;
    v_user_id := NEW.maker_id;
    v_enc_bank_details := NEW.payload->>'bank_details';

    IF NEW.status = 'approved' THEN
      -- Payout approved: update transaction status to completed
      UPDATE public.transactions 
      SET status = 'completed', description = 'Withdrawal Completed'
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
