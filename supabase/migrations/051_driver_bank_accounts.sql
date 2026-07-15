-- Migration 051: Driver Bank Accounts Table
-- Description: Creates a table to store driver bank accounts dynamically and enables real-time synchronization.

CREATE TABLE IF NOT EXISTS public.driver_bank_accounts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  bank_name TEXT NOT NULL,
  account_number TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.driver_bank_accounts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own bank accounts" ON public.driver_bank_accounts;
DROP POLICY IF EXISTS "Users can insert own bank accounts" ON public.driver_bank_accounts;
DROP POLICY IF EXISTS "Users can delete own bank accounts" ON public.driver_bank_accounts;

-- Select policy
CREATE POLICY "Users can view own bank accounts" 
  ON public.driver_bank_accounts FOR SELECT 
  USING (auth.uid() = user_id);

-- Insert policy
CREATE POLICY "Users can insert own bank accounts" 
  ON public.driver_bank_accounts FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Delete policy
CREATE POLICY "Users can delete own bank accounts" 
  ON public.driver_bank_accounts FOR DELETE 
  USING (auth.uid() = user_id);

-- Enable Realtime
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
      AND schemaname = 'public' 
      AND tablename = 'driver_bank_accounts'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_bank_accounts;
  END IF;
END $$;

-- Seed default bank accounts for the test driver (Deepika)
INSERT INTO public.driver_bank_accounts (user_id, bank_name, account_number)
VALUES 
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'HDFC Bank', '**** 1234'),
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'ICICI Bank', '**** 5678'),
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'SBI Bank', '**** 9012')
ON CONFLICT DO NOTHING;
