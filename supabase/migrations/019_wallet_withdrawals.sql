-- Migration: 019_wallet_withdrawals.sql
-- Description: Creates the wallet_withdrawal_requests table and its RLS policies.

CREATE TABLE IF NOT EXISTS public.wallet_withdrawal_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ DEFAULT NULL
);

-- RLS Enforcement
ALTER TABLE public.wallet_withdrawal_requests ENABLE ROW LEVEL SECURITY;

-- SELECT: Drivers can view their own requests, admins can view all
DROP POLICY IF EXISTS "Drivers can view their own withdrawal requests" ON public.wallet_withdrawal_requests;
CREATE POLICY "Drivers can view their own withdrawal requests" 
  ON public.wallet_withdrawal_requests 
  FOR SELECT 
  USING (auth.uid() = driver_id OR public.is_admin(auth.uid()));

-- INSERT: Drivers can insert their own requests
DROP POLICY IF EXISTS "Drivers can create their own withdrawal requests" ON public.wallet_withdrawal_requests;
CREATE POLICY "Drivers can create their own withdrawal requests" 
  ON public.wallet_withdrawal_requests 
  FOR INSERT 
  WITH CHECK (auth.uid() = driver_id);

-- UPDATE: Admins can update all requests
DROP POLICY IF EXISTS "Admins can manage withdrawal requests" ON public.wallet_withdrawal_requests;
CREATE POLICY "Admins can manage withdrawal requests" 
  ON public.wallet_withdrawal_requests 
  FOR UPDATE 
  USING (public.is_admin(auth.uid()));
