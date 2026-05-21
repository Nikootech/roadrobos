-- ==============================================================================
-- ENTERPRISE SEED DATA FOR ROADROBOS SUPABASE
-- Execute this script in your Supabase SQL Editor to populate initial data
-- ==============================================================================

-- 1. SEED CATEGORIES
INSERT INTO public.service_categories (name, icon, is_active) VALUES
  ('Repair', 'build', true),
  ('Oil & Fluids', 'oil_barrel', true),
  ('AC & Climate', 'ac_unit', true),
  ('Tyres', 'tire_repair', true),
  ('Wash & Clean', 'car_wash', true)
ON CONFLICT DO NOTHING;

-- 2. SEED BANNERS
INSERT INTO public.banners (title, link_url, image_url, is_active) VALUES
  ('Free AC Check-up', 'Book any service & get AC inspection free', 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=600', true),
  ('20% Off First Ride', 'Use code FIRST20 on your maiden journey', 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600', true),
  ('Gold Membership', 'Unlock priority service & exclusive perks', 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=600', true)
ON CONFLICT DO NOTHING;

-- 3. SEED RENTAL VEHICLES
INSERT INTO public.rental_vehicles (name, type, price_per_hour, image_url, is_available) VALUES
  ('Maruti Baleno', 'Hatchback', 159.00, 'assets/icons/baleno.png', true),
  ('Honda City', 'Sedan', 179.00, 'assets/icons/city.png', true),
  ('Maruti Swift', 'Hatchback', 129.00, 'assets/icons/swift.png', true),
  ('Mahindra Scorpio', 'SUV', 219.00, 'assets/icons/scorpio.png', true),
  ('Ather 450X', 'EV Scooter', 55.00, 'assets/rentals/ather_450x_premium.png', true),
  ('Zelio Eeva E (Black)', 'EV Bike', 45.00, 'assets/rentals/zeeoneevaeblack1.jpg', true),
  ('Honda Activa 6G', 'Scooter', 35.00, 'assets/rentals/tvs_jupiter_125_premium.png', true),
  ('Royal Enfield Classic 350', 'Cruiser', 95.00, 'assets/rentals/re_classic_350_premium.png', true),
  ('Yamaha MT-15', 'Gear', 85.00, 'assets/rentals/yamaha_mt15_premium.png', true)
ON CONFLICT DO NOTHING;

-- 4. SEED SERVICE ITEMS
-- Using a DO block to get category IDs
DO $$
DECLARE
  cat_repair UUID;
  cat_oil UUID;
  cat_ac UUID;
  cat_tyre UUID;
  cat_wash UUID;
BEGIN
  SELECT id INTO cat_repair FROM public.service_categories WHERE name = 'Repair' LIMIT 1;
  SELECT id INTO cat_oil FROM public.service_categories WHERE name = 'Oil & Fluids' LIMIT 1;
  SELECT id INTO cat_ac FROM public.service_categories WHERE name = 'AC & Climate' LIMIT 1;
  SELECT id INTO cat_tyre FROM public.service_categories WHERE name = 'Tyres' LIMIT 1;
  SELECT id INTO cat_wash FROM public.service_categories WHERE name = 'Wash & Clean' LIMIT 1;

  INSERT INTO public.service_items (category_id, name, description, base_price, duration_minutes, image_url) VALUES
    (cat_repair, 'General Service', 'Complete car checkup with 40-point inspection', 2499.00, 240, 'https://images.unsplash.com/photo-1625047509248-ec889cbff17f?w=400'),
    (cat_oil, 'Oil Change', 'Full synthetic oil replacement with filter', 899.00, 60, 'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?w=400'),
    (cat_repair, 'Brake Pad Replacement', 'OEM grade brake pads for all 4 wheels', 3200.00, 120, 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400'),
    (cat_ac, 'AC Gas Refill', 'R134a refrigerant top-up with leak check', 1799.00, 60, 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=400'),
    (cat_repair, 'Battery Replacement', 'Amaron/Exide 12V battery with 2yr warranty', 4500.00, 30, 'https://images.unsplash.com/photo-1611348586804-61bf6c080437?w=400'),
    (cat_tyre, 'Wheel Alignment', 'Advanced 3D computerised alignment', 699.00, 45, 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=400'),
    (cat_wash, 'Full Car Wash', 'Premium foam wash, interior vacuum & dashboard polish', 599.00, 60, 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=400')
  ON CONFLICT DO NOTHING;
END $$;
