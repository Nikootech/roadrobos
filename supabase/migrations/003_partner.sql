-- PARTNER (DRIVER/TECH) SCHEMA FOR ROADROBOS
-- This script adds detailed partner profiles

-- 1. Drivers Table
CREATE TABLE IF NOT EXISTS public.drivers (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  vehicle_model TEXT,
  chassis_number TEXT,
  license_number TEXT,
  approval_status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  is_online BOOLEAN DEFAULT false,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  last_active TIMESTAMPTZ DEFAULT NOW(),
  fcm_token TEXT,
  today_earnings DECIMAL(10,2) DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Technicians Table
CREATE TABLE IF NOT EXISTS public.technicians (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  expertise TEXT[], -- ['electric', 'engine', 'body']
  approval_status TEXT DEFAULT 'pending',
  is_online BOOLEAN DEFAULT false,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  last_active TIMESTAMPTZ DEFAULT NOW(),
  fcm_token TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. RLS Policies
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.technicians ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Drivers viewable by everyone (for tracking)" ON public.drivers;
CREATE POLICY "Drivers viewable by everyone (for tracking)" ON public.drivers FOR SELECT USING (true);

DROP POLICY IF EXISTS "Drivers can update their own data" ON public.drivers;
CREATE POLICY "Drivers can update their own data" ON public.drivers FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Technicians viewable by everyone" ON public.technicians;
CREATE POLICY "Technicians viewable by everyone" ON public.technicians FOR SELECT USING (true);

DROP POLICY IF EXISTS "Technicians can update their own data" ON public.technicians;
CREATE POLICY "Technicians can update their own data" ON public.technicians FOR UPDATE USING (auth.uid() = id);

-- 4. Enable Realtime
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'drivers') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.drivers;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'technicians') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.technicians;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'ride_bookings') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.ride_bookings;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'service_bookings') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.service_bookings;
  END IF;
END;
$$;
-- PARTNER KYC SCHEMA FOR ROADROBOS
-- This script manages partner document verification

-- 1. Partner KYC Table
CREATE TABLE IF NOT EXISTS public.partner_kyc (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL, -- 'aadhar', 'driving_license', 'pan_card', 'vehicle_rc'
  document_number TEXT,
  document_url TEXT NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending', 'verified', 'rejected'
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, document_type)
);

-- 2. Add KYC Status to Profiles (Denormalized for quick checks)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS kyc_status TEXT DEFAULT 'not_started';

-- 3. RLS Policies
ALTER TABLE public.partner_kyc ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Partners can view their own KYC docs" ON public.partner_kyc;
CREATE POLICY "Partners can view their own KYC docs" ON public.partner_kyc 
FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Partners can upload their own KYC docs" ON public.partner_kyc;
CREATE POLICY "Partners can upload their own KYC docs" ON public.partner_kyc 
FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view and update KYC docs" ON public.partner_kyc;
CREATE POLICY "Admins can view and update KYC docs" ON public.partner_kyc 
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur 
    JOIN public.roles r ON ur.role_id = r.id 
    WHERE ur.user_id = auth.uid() AND r.name IN ('super_admin', 'admin', 'ops_head')
  )
);

-- 4. Storage Bucket for KYC Documents
-- This usually needs to be done via Supabase Console or API, but we can document it here.
-- Bucket Name: 'kyc-documents'
-- RLS: auth.uid() = (storage.foldername(name))[1]
