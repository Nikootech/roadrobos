-- ==============================================================================
-- ENTERPRISE RLS SECURITY HARDENING & INDEXING FOR ROADROBOS
-- Execute this script in your Supabase SQL Editor
-- ==============================================================================

-- 1. DROP INSECURE DEFAULT POLICIES
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;

-- 2. HELPER FUNCTION: Check if user is SuperAdmin or Admin
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = user_id AND role IN ('admin', 'superAdmin', 'founderAdmin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. PROFILES: Strict RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles" ON public.profiles FOR SELECT USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
CREATE POLICY "Admins can update all profiles" ON public.profiles FOR UPDATE USING (public.is_admin(auth.uid()));

-- 4. TRANSACTIONS & WALLETS: Strict RLS
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view all wallets" ON public.wallets;
CREATE POLICY "Admins can view all wallets" ON public.wallets FOR SELECT USING (public.is_admin(auth.uid()));

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own transactions" ON public.transactions;
CREATE POLICY "Users can view own transactions" ON public.transactions FOR SELECT USING (
  wallet_id IN (SELECT id FROM public.wallets WHERE id = auth.uid())
);

DROP POLICY IF EXISTS "Admins can view all transactions" ON public.transactions;
CREATE POLICY "Admins can view all transactions" ON public.transactions FOR SELECT USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "System only can insert transactions" ON public.transactions;
CREATE POLICY "System only can insert transactions" ON public.transactions FOR INSERT WITH CHECK (false); -- Handled via Edge Functions/DB Triggers only

-- 5. SERVICE & RIDE BOOKINGS: Field Staff & Customer Matrix
ALTER TABLE public.service_bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Customers can view own bookings" ON public.service_bookings;
CREATE POLICY "Customers can view own bookings" ON public.service_bookings FOR SELECT USING (customer_id = auth.uid());

DROP POLICY IF EXISTS "Customers can create bookings" ON public.service_bookings;
CREATE POLICY "Customers can create bookings" ON public.service_bookings FOR INSERT WITH CHECK (customer_id = auth.uid());

DROP POLICY IF EXISTS "Assigned Techs can view their bookings" ON public.service_bookings;
CREATE POLICY "Assigned Techs can view their bookings" ON public.service_bookings FOR SELECT USING (
  id IN (SELECT booking_id FROM public.technician_jobs WHERE tech_id = auth.uid())
);

DROP POLICY IF EXISTS "Admins can manage all service bookings" ON public.service_bookings;
CREATE POLICY "Admins can manage all service bookings" ON public.service_bookings FOR ALL USING (public.is_admin(auth.uid()));

ALTER TABLE public.ride_bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Customers can view own rides" ON public.ride_bookings;
CREATE POLICY "Customers can view own rides" ON public.ride_bookings FOR SELECT USING (customer_id = auth.uid());

DROP POLICY IF EXISTS "Customers can create rides" ON public.ride_bookings;
CREATE POLICY "Customers can create rides" ON public.ride_bookings FOR INSERT WITH CHECK (customer_id = auth.uid());

DROP POLICY IF EXISTS "Drivers can view assigned rides" ON public.ride_bookings;
CREATE POLICY "Drivers can view assigned rides" ON public.ride_bookings FOR SELECT USING (driver_id = auth.uid());

DROP POLICY IF EXISTS "Drivers can accept pending rides" ON public.ride_bookings;
CREATE POLICY "Drivers can accept pending rides" ON public.ride_bookings FOR UPDATE USING (status = 'searching' OR driver_id = auth.uid());

DROP POLICY IF EXISTS "Admins can manage all rides" ON public.ride_bookings;
CREATE POLICY "Admins can manage all rides" ON public.ride_bookings FOR ALL USING (public.is_admin(auth.uid()));

-- 6. PUBLIC CATALOGS: Read-only for everyone, Admin write
-- Create tables if they don't exist yet (safety net if 001_base_schema was not fully applied)
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

CREATE TABLE IF NOT EXISTS public.rental_vehicles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT,
  price_per_hour DECIMAL(10,2),
  image_url TEXT,
  is_available BOOLEAN DEFAULT true
);

ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view categories" ON public.service_categories;
CREATE POLICY "Anyone can view categories" ON public.service_categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage categories" ON public.service_categories;
CREATE POLICY "Admins can manage categories" ON public.service_categories FOR ALL USING (public.is_admin(auth.uid()));

ALTER TABLE public.service_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view items" ON public.service_items;
CREATE POLICY "Anyone can view items" ON public.service_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage items" ON public.service_items;
CREATE POLICY "Admins can manage items" ON public.service_items FOR ALL USING (public.is_admin(auth.uid()));

ALTER TABLE public.rental_vehicles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view rental vehicles" ON public.rental_vehicles;
CREATE POLICY "Anyone can view rental vehicles" ON public.rental_vehicles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage rental vehicles" ON public.rental_vehicles;
CREATE POLICY "Admins can manage rental vehicles" ON public.rental_vehicles FOR ALL USING (public.is_admin(auth.uid()));

-- 7. PERFORMANCE INDEXING
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON public.transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON public.transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_service_bookings_customer_id ON public.service_bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_ride_bookings_customer_driver ON public.ride_bookings(customer_id, driver_id);
CREATE INDEX IF NOT EXISTS idx_ride_bookings_status ON public.ride_bookings(status);
CREATE INDEX IF NOT EXISTS idx_rental_bookings_customer ON public.rental_bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_technician_jobs_tech_id ON public.technician_jobs(tech_id);
