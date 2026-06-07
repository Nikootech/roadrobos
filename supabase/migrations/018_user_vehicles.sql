-- Migration: 018_user_vehicles.sql
-- Description: Creates the user_vehicles table, enables RLS, adds policies, and adds partial unique index.

CREATE TABLE IF NOT EXISTS public.user_vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  plate_number TEXT NOT NULL,
  vehicle_type TEXT CHECK (vehicle_type IN ('car', 'bike', 'ev', 'truck')),
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ DEFAULT NULL
);

-- RLS Enforcement
ALTER TABLE public.user_vehicles ENABLE ROW LEVEL SECURITY;

-- SELECT Policy
DROP POLICY IF EXISTS "Users can view their own vehicles" ON public.user_vehicles;
CREATE POLICY "Users can view their own vehicles" 
  ON public.user_vehicles 
  FOR SELECT 
  USING (auth.uid() = user_id);

-- INSERT Policy
DROP POLICY IF EXISTS "Users can insert their own vehicles" ON public.user_vehicles;
CREATE POLICY "Users can insert their own vehicles" 
  ON public.user_vehicles 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- UPDATE Policy
DROP POLICY IF EXISTS "Users can update their own vehicles" ON public.user_vehicles;
CREATE POLICY "Users can update their own vehicles" 
  ON public.user_vehicles 
  FOR UPDATE 
  USING (auth.uid() = user_id);

-- DELETE Policy
DROP POLICY IF EXISTS "Users can delete their own vehicles" ON public.user_vehicles;
CREATE POLICY "Users can delete their own vehicles" 
  ON public.user_vehicles 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Partial unique index to ensure at most one primary vehicle per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_vehicles_user_primary 
  ON public.user_vehicles(user_id, is_primary) 
  WHERE (is_primary = true);
