-- SUPABASE SCHEMA FOR ROADROBOS
-- Use this in the Supabase SQL Editor

-- 1. Users Profile (Extends suapbase.auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  role TEXT DEFAULT 'customer',
  profile_pic TEXT,
  points INTEGER DEFAULT 0,
  total_rides INTEGER DEFAULT 0,
  emergency_contacts JSONB DEFAULT '[]'::jsonb,
  referral_code TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Wallets
CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  balance DECIMAL(12,2) DEFAULT 0.00,
  currency TEXT DEFAULT 'INR',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Transactions
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  wallet_id UUID REFERENCES public.wallets(id) ON DELETE CASCADE,
  amount DECIMAL(12,2) NOT NULL,
  type TEXT NOT NULL, -- 'credit', 'debit'
  category TEXT, -- 'topup', 'ride', 'service', 'referral'
  description TEXT,
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Service Catalog
CREATE TABLE IF NOT EXISTS public.service_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.service_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID REFERENCES public.service_categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  base_price DECIMAL(10,2),
  duration_minutes INTEGER,
  image_url TEXT
);

-- 5. Service Bookings
CREATE TABLE IF NOT EXISTS public.service_bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES auth.users(id),
  vehicle_name TEXT,
  vehicle_plate TEXT,
  package_name TEXT,
  booking_date DATE,
  booking_time TEXT,
  total_cost DECIMAL(10,2),
  status TEXT DEFAULT 'pending',
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Ride Bookings (Taxi)
CREATE TABLE IF NOT EXISTS public.ride_bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES auth.users(id),
  driver_id UUID, -- Will link to profiles.id later
  pickup_address TEXT,
  destination_address TEXT,
  pickup_lat DOUBLE PRECISION,
  pickup_lng DOUBLE PRECISION,
  dest_lat DOUBLE PRECISION,
  dest_lng DOUBLE PRECISION,
  status TEXT DEFAULT 'searching',
  fare DECIMAL(10,2),
  vehicle_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Rental Catalog & Bookings
CREATE TABLE IF NOT EXISTS public.rental_vehicles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT,
  price_per_hour DECIMAL(10,2),
  image_url TEXT,
  is_available BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.rental_bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES auth.users(id),
  vehicle_id UUID REFERENCES public.rental_vehicles(id),
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  total_cost DECIMAL(10,2),
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Technician Jobs
CREATE TABLE IF NOT EXISTS public.technician_jobs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tech_id UUID REFERENCES auth.users(id),
  booking_id UUID REFERENCES public.service_bookings(id),
  status TEXT DEFAULT 'assigned',
  notes TEXT,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Chat System
CREATE TABLE IF NOT EXISTS public.chat_rooms (
  id TEXT PRIMARY KEY, -- e.g. user1_user2
  participants UUID[] NOT NULL,
  last_message TEXT,
  last_timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id TEXT REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id),
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Banners
CREATE TABLE IF NOT EXISTS public.banners (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  image_url TEXT NOT NULL,
  link_url TEXT,
  title TEXT,
  is_active BOOLEAN DEFAULT true
);

-- Row Level Security (RLS) - Simple Starter Rules
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile." ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own wallet." ON public.wallets FOR SELECT USING (auth.uid() = id);

-- Setup Trigger for Profile Creation
-- This function automatically creates a profile entry when a new user signs up via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email)
  VALUES (new.id, COALESCE(new.raw_user_meta_data->>'full_name', 'New User'), new.email);
  
  INSERT INTO public.wallets (id, balance)
  VALUES (new.id, 0.00);
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
