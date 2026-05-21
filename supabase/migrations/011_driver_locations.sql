-- Migration: 011_driver_locations.sql
-- Creates the driver_locations table for realtime taxi map markers.
-- The Flutter app subscribes to this via Supabase Realtime and renders
-- NearbyVehicle pins on the taxi booking map.

CREATE TABLE IF NOT EXISTS public.driver_locations (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  driver_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  lat           FLOAT8 NOT NULL,
  lng           FLOAT8 NOT NULL,
  updated_at    TIMESTAMPTZ DEFAULT NOW(),
  status        TEXT DEFAULT 'available',  -- 'available' | 'busy' | 'offline'
  service_type  TEXT DEFAULT 'taxi'        -- 'taxi' | 'delivery'
);

-- Index for fast spatial queries (available taxi drivers)
CREATE INDEX IF NOT EXISTS idx_driver_locations_status_service
  ON public.driver_locations (status, service_type);

-- Trigger to auto-update updated_at on row change
CREATE OR REPLACE FUNCTION public.touch_driver_location_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_driver_location_updated_at ON public.driver_locations;
CREATE TRIGGER trg_driver_location_updated_at
  BEFORE UPDATE ON public.driver_locations
  FOR EACH ROW EXECUTE FUNCTION public.touch_driver_location_updated_at();

-- Row Level Security
ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;

-- Customers can see available driver locations (for map markers)
CREATE POLICY "Customers can read available driver locations"
  ON public.driver_locations
  FOR SELECT
  USING (status = 'available');

-- Drivers can upsert their own location
CREATE POLICY "Drivers can manage own location"
  ON public.driver_locations
  FOR ALL
  USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);

-- Enable Realtime for this table (run in Supabase dashboard if CLI not available)
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_locations;
