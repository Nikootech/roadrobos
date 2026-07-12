-- ============================================================
-- RoadRobos Supabase RLS Policies
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- ① PROFILES TABLE
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Each user can only read/write their own profile
CREATE POLICY "profiles: own row" ON profiles
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ② RIDE_BOOKINGS TABLE
ALTER TABLE ride_bookings ENABLE ROW LEVEL SECURITY;

-- Customers can read their own bookings
CREATE POLICY "ride_bookings: customer reads own" ON ride_bookings
  FOR SELECT
  USING (auth.uid() = customer_id);

-- Drivers can read bookings assigned to them OR open 'searching' rides
CREATE POLICY "ride_bookings: driver reads assigned or open" ON ride_bookings
  FOR SELECT
  USING (
    auth.uid() = driver_id
    OR status = 'searching'
  );

-- Customers can create bookings
CREATE POLICY "ride_bookings: customer inserts" ON ride_bookings
  FOR INSERT
  WITH CHECK (auth.uid() = customer_id);

-- Drivers can update (accept) rides that are searching
CREATE POLICY "ride_bookings: driver accepts searching" ON ride_bookings
  FOR UPDATE
  USING (status = 'searching')
  WITH CHECK (auth.uid() = driver_id);

-- Allow status updates from customer or assigned driver
CREATE POLICY "ride_bookings: participant updates" ON ride_bookings
  FOR UPDATE
  USING (auth.uid() = customer_id OR auth.uid() = driver_id);

-- ③ DRIVERS TABLE
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- Drivers can only read and update their own row
CREATE POLICY "drivers: own row" ON drivers
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Customers can read drivers assigned to their ride (needed for live tracking)
CREATE POLICY "drivers: customers can see assigned" ON drivers
  FOR SELECT
  USING (
    id IN (
      SELECT driver_id FROM ride_bookings
      WHERE customer_id = auth.uid()
        AND status IN ('accepted', 'arrived', 'started')
    )
  );

-- ④ SERVICE_BOOKINGS TABLE (if exists)
ALTER TABLE service_bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_bookings: own" ON service_bookings
  FOR ALL
  USING (auth.uid() = customer_id)
  WITH CHECK (auth.uid() = customer_id);

-- ============================================================
-- DONE. Verify in: Dashboard > Authentication > Policies
-- ============================================================
