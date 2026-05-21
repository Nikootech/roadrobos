-- DATABASE FIXES FOR ROADROBOS
-- Use this in the Supabase SQL Editor to align schema with implementation

-- 1. Profiles Table Fixes
ALTER TABLE public.profiles 
  ADD COLUMN IF NOT EXISTS deletion_requested BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS deletion_requested_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS kyc_status TEXT DEFAULT 'not_started',
  ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 2. Ride Bookings Fixes
-- Aligning with RideBooking model which uses lat/lng for locations
ALTER TABLE public.ride_bookings
  ADD COLUMN IF NOT EXISTS pickup_location_name TEXT,
  ADD COLUMN IF NOT EXISTS destination_location_name TEXT;

-- 3. Technician Jobs Fixes
-- The implementation expects a flatter structure for quick access, 
-- or we need to update the model to be relational.
-- To ensure the app doesn't crash on insert, we add the missing columns.
ALTER TABLE public.technician_jobs
  ADD COLUMN IF NOT EXISTS estimated_completion TEXT,
  ADD COLUMN IF NOT EXISTS vehicle_model TEXT,
  ADD COLUMN IF NOT EXISTS vehicle_plate TEXT,
  ADD COLUMN IF NOT EXISTS service_type TEXT DEFAULT 'General Service',
  ADD COLUMN IF NOT EXISTS package_name TEXT DEFAULT 'Basic',
  ADD COLUMN IF NOT EXISTS date TEXT,
  ADD COLUMN IF NOT EXISTS time TEXT,
  ADD COLUMN IF NOT EXISTS progress DECIMAL(5,2) DEFAULT 0.0,
  ADD COLUMN IF NOT EXISTS checklist JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS parts JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS price TEXT DEFAULT '₹0',
  ADD COLUMN IF NOT EXISTS assigned_tech_id UUID REFERENCES auth.users(id), -- Renaming tech_id to assigned_tech_id for consistency with code
  ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS service_booking_id UUID REFERENCES public.service_bookings(id);

-- 4. Storage Buckets
-- Ensure buckets exist
INSERT INTO storage.buckets (id, name, public) VALUES ('profiles', 'profiles', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('roadrobos-media', 'roadrobos-media', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('kyc-documents', 'kyc-documents', false) ON CONFLICT (id) DO NOTHING;
-- 5. Realtime for all tables (Idempotent)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'profiles') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'wallets') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.wallets;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'transactions') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.transactions;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'service_bookings') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.service_bookings;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'technician_jobs') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.technician_jobs;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'approvals') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.approvals;
  END IF;
END $$;

-- 6. Rental Bookings Fixes
ALTER TABLE public.rental_bookings
  ADD COLUMN IF NOT EXISTS vehicle_name TEXT,
  ADD COLUMN IF NOT EXISTS rental_type TEXT,
  ADD COLUMN IF NOT EXISTS duration INTEGER,
  ADD COLUMN IF NOT EXISTS details TEXT;

-- 7. Service Bookings Fixes
ALTER TABLE public.service_bookings
  ADD COLUMN IF NOT EXISTS tech_id UUID REFERENCES auth.users(id);

-- 8. Atomic Wallet RPC
-- This prevents race conditions when multiple transactions occur simultaneously
CREATE OR REPLACE FUNCTION public.update_wallet_balance(
  user_id UUID,
  amount_change DECIMAL,
  trans_type TEXT,
  trans_category TEXT,
  trans_description TEXT
) RETURNS VOID AS $$
DECLARE
  current_bal DECIMAL;
BEGIN
  -- Get current balance and lock row for update
  SELECT balance INTO current_bal FROM public.wallets WHERE id = user_id FOR UPDATE;
  
  IF current_bal IS NULL THEN
    INSERT INTO public.wallets (id, balance) VALUES (user_id, amount_change);
  ELSE
    UPDATE public.wallets SET balance = balance + amount_change, updated_at = NOW() WHERE id = user_id;
  END IF;

  -- Log transaction
  INSERT INTO public.transactions (wallet_id, amount, type, category, description)
  VALUES (user_id, ABS(amount_change), trans_type, trans_category, trans_description);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
