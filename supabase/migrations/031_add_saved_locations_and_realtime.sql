-- Migration: 031_add_saved_locations_and_realtime.sql
-- Description: Adds saved_locations column to profiles and enables realtime for profiles and user_vehicles.

-- 1. Add saved_locations column to profiles table if not exists
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS saved_locations JSONB DEFAULT '[]'::jsonb;

-- 2. Enable Realtime for profiles table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
      AND schemaname = 'public' 
      AND tablename = 'profiles'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
  END IF;
END;
$$;

-- 3. Enable Realtime for user_vehicles table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
      AND schemaname = 'public' 
      AND tablename = 'user_vehicles'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.user_vehicles;
  END IF;
END;
$$;
