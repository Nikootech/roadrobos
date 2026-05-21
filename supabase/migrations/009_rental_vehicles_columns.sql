-- Migration: 009_rental_vehicles_columns.sql
-- Adds missing columns to the rental_vehicles table that the Flutter app
-- expects (price text, rating, seats, category, spec, is_bike, is_coming_soon).
-- The original 001_base_schema.sql only had id, name, type, price_per_hour,
-- image_url, and is_available.

ALTER TABLE public.rental_vehicles
  ADD COLUMN IF NOT EXISTS price        TEXT,
  ADD COLUMN IF NOT EXISTS rating       TEXT DEFAULT '4.8',
  ADD COLUMN IF NOT EXISTS seats        TEXT,
  ADD COLUMN IF NOT EXISTS category     TEXT DEFAULT 'Popular',
  ADD COLUMN IF NOT EXISTS spec         TEXT,
  ADD COLUMN IF NOT EXISTS is_bike      BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_coming_soon BOOLEAN DEFAULT false;

-- Enable RLS if not already enabled
ALTER TABLE public.rental_vehicles ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read rental vehicles (public catalog)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'rental_vehicles'
      AND policyname = 'Anyone can read rental vehicles'
  ) THEN
    CREATE POLICY "Anyone can read rental vehicles"
      ON public.rental_vehicles
      FOR SELECT
      USING (true);
  END IF;
END $$;

-- Allow admins to insert/update/delete rental vehicles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'rental_vehicles'
      AND policyname = 'Admins can manage rental vehicles'
  ) THEN
    CREATE POLICY "Admins can manage rental vehicles"
      ON public.rental_vehicles
      FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.profiles
          WHERE id = auth.uid()
            AND role IN ('admin', 'super_admin')
        )
      );
  END IF;
END $$;

-- Seed sample data so the app shows real content immediately.
-- Uses ON CONFLICT DO NOTHING so it is safe to re-run.
INSERT INTO public.rental_vehicles
  (name, type, price, rating, seats, image_url, category, is_bike, is_coming_soon)
VALUES
  ('Maruti Baleno',   'Hatchback', '₹159/hr', '4.9', '5 Seats', 'assets/icons/baleno.png',    'Popular', false, false),
  ('Honda City',      'Sedan',     '₹179/hr', '4.9', '5 Seats', 'assets/icons/city.png',       'Luxury',  false, false),
  ('Maruti Swift',    'Hatchback', '₹129/hr', '4.8', '5 Seats', 'assets/icons/swift.png',      'Popular', false, false),
  ('Mahindra Scorpio','SUV',       '₹219/hr', '4.7', '7 Seats', 'assets/icons/scorpio.png',    'Popular', false, false),
  ('Ather 450X',      'EV Scooter','₹55/hr',  '4.9', NULL,      'assets/rentals/ather_450x_premium.png',   'EV',     true,  true),
  ('Zelio Eeva E (Black)', 'EV Bike', '₹45/hr','4.9',NULL,    'assets/rentals/zeeoneevaeblack1.jpg',  'EV',     true,  false),
  ('Zelio Eeva E (Blue)',  'EV Bike', '₹45/hr','4.8',NULL,    'assets/rentals/zeeoneevaeblue1.jpg',   'EV',     true,  false),
  ('Zelio Eeva E (Red)',   'EV Bike', '₹45/hr','4.8',NULL,    'assets/rentals/zeeoneevaered1.jpg',    'EV',     true,  false),
  ('Zelio Eeva E (Silver)','EV Bike', '₹45/hr','4.8',NULL,    'assets/rentals/zeeoneevaesilver1.jpg', 'EV',     true,  false),
  ('Zelio Eeva E (White)', 'EV Bike', '₹45/hr','4.9',NULL,    'assets/rentals/zeeoneevaewhite1.jpg',  'EV',     true,  false),
  ('Honda Activa 6G', 'Scooter',   '₹35/hr',  '4.8', NULL,    'assets/rentals/tvs_jupiter_125_premium.png', 'Bikes', true, true),
  ('Royal Enfield Classic 350','Cruiser','₹95/hr','4.9',NULL, 'assets/rentals/re_classic_350_premium.png',  'Bikes', true, true),
  ('BMW G310 R',      'Superbike', '₹145/hr', '4.9', NULL,    'assets/rentals/bmw_g310r_premium.png',       'Bikes', true, true),
  ('Yamaha MT-15',    'Gear',      '₹85/hr',  '4.8', NULL,    'assets/rentals/yamaha_mt15_premium.png',     'Bikes', true, true),
  ('Kawasaki Ninja 400','Superbike','₹195/hr','5.0', NULL,    'assets/rentals/kawasaki_ninja_400_premium.png','Bikes',true, true),
  ('KTM Duke 390',    'Street',    '₹125/hr', '4.7', NULL,    'assets/rentals/ktm_duke_390_premium.png',    'Bikes', true, true)
ON CONFLICT DO NOTHING;
