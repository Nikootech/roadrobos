-- ============================================================
-- Migration: 038_transfer_funds_atomic.sql
-- Purpose:   Atomic fund transfer via a single PostgreSQL function.
--            Replaces the 2-step debit+credit in wallet_repository.dart
--            which could leave funds in limbo if the app crashed mid-operation.
-- ============================================================

-- ── Custom exceptions ─────────────────────────────────────────────────────────
-- Named exceptions allow the Dart layer to map to user-friendly messages.

-- ── transfer_funds function ───────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION transfer_funds(
  sender_id   uuid,
  receiver_id uuid,
  amount      numeric,
  description text DEFAULT 'Fund Transfer'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER  -- runs with definer privileges to access wallet rows
SET search_path = public
AS $$
DECLARE
  sender_balance   numeric;
  transaction_id   uuid;
BEGIN
  -- ── 1. Validate inputs ────────────────────────────────────────────────────
  IF amount <= 0 THEN
    RAISE EXCEPTION 'invalid_amount' USING
      MESSAGE = 'Transfer amount must be greater than zero.',
      HINT    = 'Ensure amount is a positive number.';
  END IF;

  IF sender_id = receiver_id THEN
    RAISE EXCEPTION 'same_account' USING
      MESSAGE = 'Cannot transfer funds to the same account.',
      HINT    = 'sender_id and receiver_id must be different.';
  END IF;

  -- ── 2. Lock sender row to prevent race conditions ─────────────────────────
  -- FOR UPDATE ensures no concurrent transfer can read/write this row until
  -- this transaction commits or rolls back.
  SELECT balance INTO sender_balance
    FROM wallets
   WHERE user_id = sender_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'sender_not_found' USING
      MESSAGE = 'Sender wallet not found.',
      HINT    = 'Ensure the sender has a wallet record.';
  END IF;

  -- ── 3. Check sufficient balance ───────────────────────────────────────────
  IF sender_balance < amount THEN
    RAISE EXCEPTION 'insufficient_funds' USING
      MESSAGE = 'Insufficient wallet balance.',
      HINT    = 'Sender balance is ' || sender_balance || ', required ' || amount;
  END IF;

  -- ── 4. Lock receiver row ──────────────────────────────────────────────────
  PERFORM 1 FROM wallets WHERE user_id = receiver_id FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'receiver_not_found' USING
      MESSAGE = 'Receiver wallet not found.',
      HINT    = 'Ensure the receiver has a wallet record.';
  END IF;

  -- ── 5. Atomic debit + credit ──────────────────────────────────────────────
  -- Both updates happen in the same transaction; either both succeed or
  -- neither is committed. No funds can disappear between the two operations.
  UPDATE wallets SET balance = balance - amount WHERE user_id = sender_id;
  UPDATE wallets SET balance = balance + amount WHERE user_id = receiver_id;

  -- ── 6. Record transaction ─────────────────────────────────────────────────
  transaction_id := gen_random_uuid();

  INSERT INTO wallet_transactions (id, user_id, type, amount, description, reference_id, created_at)
  VALUES
    (transaction_id,         sender_id,   'debit',  amount, description, transaction_id, NOW()),
    (gen_random_uuid(), receiver_id, 'credit', amount, description, transaction_id, NOW());

  -- ── 7. Return success ─────────────────────────────────────────────────────
  RETURN json_build_object(
    'success',        true,
    'transaction_id', transaction_id,
    'sender_id',      sender_id,
    'receiver_id',    receiver_id,
    'amount',         amount
  );

EXCEPTION
  WHEN OTHERS THEN
    -- Re-raise named exceptions with their original code so the Dart layer
    -- can pattern-match on SQLSTATE or the exception message.
    RAISE;
END;
$$;

-- ── Grant execution rights ────────────────────────────────────────────────────
-- Only authenticated users can call this function via the Supabase client.
-- The service-role key (edge functions) can also call it.
GRANT EXECUTE ON FUNCTION transfer_funds(uuid, uuid, numeric, text) TO authenticated;
REVOKE EXECUTE ON FUNCTION transfer_funds(uuid, uuid, numeric, text) FROM anon;
