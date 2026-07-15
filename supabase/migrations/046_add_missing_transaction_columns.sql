-- Migration 046: Add missing payment transaction columns to transactions table

-- 1. Add user_id referencing profiles(id)
ALTER TABLE public.transactions 
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;

-- 2. Add payment reference and method columns
ALTER TABLE public.transactions 
  ADD COLUMN IF NOT EXISTS reference_id TEXT,
  ADD COLUMN IF NOT EXISTS payment_method TEXT;

-- 3. Add razorpay payment specific columns
ALTER TABLE public.transactions 
  ADD COLUMN IF NOT EXISTS razorpay_payment_id TEXT,
  ADD COLUMN IF NOT EXISTS razorpay_order_id TEXT,
  ADD COLUMN IF NOT EXISTS razorpay_signature TEXT;

-- 4. Add breakdown amounts
ALTER TABLE public.transactions 
  ADD COLUMN IF NOT EXISTS base_amount DECIMAL(12,2),
  ADD COLUMN IF NOT EXISTS gst_amount DECIMAL(12,2),
  ADD COLUMN IF NOT EXISTS platform_fee DECIMAL(12,2),
  ADD COLUMN IF NOT EXISTS handling_charges DECIMAL(12,2),
  ADD COLUMN IF NOT EXISTS total_amount DECIMAL(12,2);

-- 5. Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);

-- 6. Update SELECT policy to allow viewing by user_id or wallet_id
DROP POLICY IF EXISTS "Users can view own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can read own transactions" ON public.transactions;

CREATE POLICY "Users can view own transactions" ON public.transactions 
  FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR wallet_id IN (SELECT id FROM public.wallets WHERE id = auth.uid())
  );

-- 7. Add INSERT policy for users to insert their own transactions (required by Flutter client logs)
DROP POLICY IF EXISTS "Users can insert own transactions" ON public.transactions;
CREATE POLICY "Users can insert own transactions" ON public.transactions 
  FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id 
    OR wallet_id IN (SELECT id FROM public.wallets WHERE id = auth.uid())
  );

-- 8. Reload Postgrest schema cache so Supabase immediately recognizes the new columns
NOTIFY pgrst, 'reload schema';
