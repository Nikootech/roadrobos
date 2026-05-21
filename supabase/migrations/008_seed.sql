-- ==============================================================================
-- PRODUCTION-READY SEED DATA FOR ROADROBOS (V2)
-- Execute this script in your Supabase SQL Editor
-- This script ensures tables match the Dart models perfectly.
-- ==============================================================================

-- 1. FIX SCHEMA MISMATCHES (Optional but recommended for consistency)
DO $$
BEGIN
    -- Fix categories table (Ensure it matches ServiceCategory model)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'service_categories') THEN
        ALTER TABLE public.service_categories RENAME TO categories;
    END IF;

    IF EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'categories' AND column_name = 'name') THEN
        ALTER TABLE public.categories RENAME COLUMN name TO label;
    END IF;

    -- Ensure count column exists in categories (even if virtual in some apps, we'll store it for demo)
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'categories' AND column_name = 'count') THEN
        ALTER TABLE public.categories ADD COLUMN count INTEGER DEFAULT 0;
    END IF;

    -- Fix rental_vehicles table (Ensure it matches RentalVehicle model)
    IF EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'rental_vehicles' AND column_name = 'price_per_hour') THEN
        ALTER TABLE public.rental_vehicles RENAME COLUMN price_per_hour TO price;
        ALTER TABLE public.rental_vehicles ALTER COLUMN price TYPE TEXT;
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'rental_vehicles' AND column_name = 'category') THEN
        ALTER TABLE public.rental_vehicles ADD COLUMN category TEXT;
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'rental_vehicles' AND column_name = 'rating') THEN
        ALTER TABLE public.rental_vehicles ADD COLUMN rating TEXT DEFAULT '5.0';
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'rental_vehicles' AND column_name = 'is_bike') THEN
        ALTER TABLE public.rental_vehicles ADD COLUMN is_bike BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'rental_vehicles' AND column_name = 'is_coming_soon') THEN
        ALTER TABLE public.rental_vehicles ADD COLUMN is_coming_soon BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'rental_vehicles' AND column_name = 'spec') THEN
        ALTER TABLE public.rental_vehicles ADD COLUMN spec TEXT;
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'rental_vehicles' AND column_name = 'seats') THEN
        ALTER TABLE public.rental_vehicles ADD COLUMN seats TEXT;
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'quick_actions') THEN
        CREATE TABLE public.quick_actions (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            label TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            route TEXT NOT NULL,
            is_active BOOLEAN DEFAULT true,
            display_order INTEGER DEFAULT 0
        );
    END IF;

    -- Fix banners table (Ensure it matches BannerOffer model)
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'banners') THEN
        CREATE TABLE public.banners (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            title TEXT NOT NULL,
            subtitle TEXT,
            image_url TEXT NOT NULL,
            cta TEXT,
            is_active BOOLEAN DEFAULT true,
            display_order INTEGER DEFAULT 0
        );
    ELSE
        -- Ensure subtitle column exists
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'banners' AND column_name = 'subtitle') THEN
            ALTER TABLE public.banners ADD COLUMN subtitle TEXT;
        END IF;
        -- Ensure cta column exists
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'banners' AND column_name = 'cta') THEN
            ALTER TABLE public.banners ADD COLUMN cta TEXT;
        END IF;
    END IF;

    -- Enable RLS and add public read policy for banners
    ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'banners' AND policyname = 'Allow public read access for banners') THEN
        CREATE POLICY "Allow public read access for banners" ON public.banners
            FOR SELECT USING (true);
    END IF;

    -- Enable RLS and add public read policy for quick_actions
    ALTER TABLE public.quick_actions ENABLE ROW LEVEL SECURITY;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'quick_actions' AND policyname = 'Allow public read access for quick_actions') THEN
        CREATE POLICY "Allow public read access for quick_actions" ON public.quick_actions
            FOR SELECT USING (true);
    END IF;

END $$;

-- 2. CLEAR OLD DATA
TRUNCATE public.categories RESTART IDENTITY CASCADE;
TRUNCATE public.banners RESTART IDENTITY CASCADE;
TRUNCATE public.rental_vehicles RESTART IDENTITY CASCADE;
TRUNCATE public.quick_actions RESTART IDENTITY CASCADE;

-- 3. SEED SERVICE CATEGORIES
INSERT INTO public.categories (label, icon, count, is_active) VALUES
  ('Repair', 'build', 12, true),
  ('Rentals', 'car_rental', 8, true),
  ('EV Service', 'bolt', 5, true),
  ('Water Service', 'local_car_wash', 3, true),
  ('Logistics', 'local_shipping', 4, true),
  ('Oil & Fluids', 'oil_barrel', 6, true),
  ('AC & Climate', 'ac_unit', 2, true),
  ('Tyres & Wheels', 'tire_repair', 4, true),
  ('Electrical', 'electrical_services', 7, true);

-- 4. SEED BANNERS
INSERT INTO public.banners (title, subtitle, image_url, cta, is_active) VALUES
  ('Summer AC Blast', 'Get 50% off on all AC servicing packages', 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=600', 'SUMMER50', true),
  ('First Ride Free', 'Enjoy your first rental ride completely on us', 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600', 'WELCOME2026', true),
  ('Rent a Zelio EV', 'Premium electric bikes starting at just ₹45/hr', 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=600', 'ZELIO10', true);

-- 5. SEED RENTAL FLEET
INSERT INTO public.rental_vehicles (name, type, price, image_url, category, rating, is_bike, is_coming_soon, spec, seats) VALUES
  ('Maruti Baleno', 'Hatchback', '₹159/hr', 'assets/icons/baleno.png', 'Cars', '4.8', false, false, 'Manual • Petrol', '5 Seats'),
  ('Honda City', 'Sedan', '₹179/hr', 'assets/icons/city.png', 'Cars', '4.9', false, false, 'Automatic • Petrol', '5 Seats'),
  ('Mahindra Scorpio', 'SUV', '₹219/hr', 'assets/icons/scorpio.png', 'Cars', '4.7', false, false, 'Manual • Diesel', '7 Seats'),
  ('Zelio Eeva E (Black)', 'EV Bike', '₹45/hr', 'assets/rentals/zeeoneevaeblack1.jpg', 'EV', '5.0', true, false, '90 km range', null),
  ('Ather 450X', 'EV Scooter', '₹55/hr', 'assets/rentals/ather_450x_premium.png', 'EV', '4.9', true, false, '110 km range', null);

-- 6. SEED QUICK ACTIONS
INSERT INTO public.quick_actions (label, icon, color, route, display_order) VALUES
  ('Taxi', 'routing', '#FDE68A', '/taxi', 1),
  ('Rental', 'car', '#BFDBFE', '/rentals-selection', 2),
  ('Service', 'build', '#FED7AA', '/select-service-type', 3),
  ('Insurance', 'safe_home', '#BBF7D0', '/insurance-selection', 4);

-- 7. SEED USER-SPECIFIC DATA (Stats, Wallet, Bookings)
-- This block dynamically finds a user to avoid Foreign Key violations
DO $$
DECLARE
    target_user_id UUID;
BEGIN
    -- Try to find the first available user in auth.users
    SELECT id INTO target_user_id FROM auth.users LIMIT 1;
    
    IF target_user_id IS NOT NULL THEN
        -- Seed Profile Stats
        INSERT INTO public.profiles (id, name, points, total_rides)
        VALUES (target_user_id, 'Test User', 450, 12)
        ON CONFLICT (id) DO UPDATE SET points = 450, total_rides = 12;

        -- Seed Wallet
        INSERT INTO public.wallets (id, balance)
        VALUES (target_user_id, 1250.00)
        ON CONFLICT (id) DO UPDATE SET balance = 1250.00;

        -- Seed Recent Service Bookings
        -- We delete existing to avoid duplicates on re-run
        DELETE FROM public.service_bookings WHERE customer_id = target_user_id;
        
        INSERT INTO public.service_bookings (customer_id, vehicle_name, package_name, booking_date, status, total_cost)
        VALUES 
          (target_user_id, 'Honda City', 'Full Service', CURRENT_DATE - INTERVAL '2 days', 'completed', 4500.00),
          (target_user_id, 'Honda City', 'Oil Change', CURRENT_DATE - INTERVAL '15 days', 'completed', 1200.00);
          
        RAISE NOTICE 'Successfully seeded user-specific data for user ID: %', target_user_id;
    ELSE
        RAISE WARNING 'No users found in auth.users. User-specific data (Stats, Wallet, Bookings) was NOT seeded.';
    END IF;
END $$;
