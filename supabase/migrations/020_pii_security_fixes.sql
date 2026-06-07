-- Migration: 020_pii_security_fixes.sql
-- Fixes critical PII exposure on profiles, drivers, and technicians tables.

-- 1. Restrict profiles SELECT access to own profile only
DROP POLICY IF EXISTS "Authenticated users can view profiles" ON public.profiles;

CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (id = auth.uid());

-- 2. Create security definer RPC for wallet lookup
CREATE OR REPLACE FUNCTION public.lookup_user_by_phone(phone_param TEXT)
RETURNS TABLE (
  id UUID,
  full_name TEXT,
  avatar_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.name AS full_name, p.profile_pic AS avatar_url
  FROM public.profiles p
  WHERE p.phone = phone_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE EXECUTE ON FUNCTION public.lookup_user_by_phone(TEXT) FROM public;
GRANT EXECUTE ON FUNCTION public.lookup_user_by_phone(TEXT) TO authenticated, service_role;

-- 3. Restrict drivers SELECT access and create restricted view (conditional on table existence)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'drivers') THEN
    -- Drop policy
    DROP POLICY IF EXISTS "Drivers viewable by everyone (for tracking)" ON public.drivers;
    
    -- Create policy
    CREATE POLICY "Drivers select policy" ON public.drivers
      FOR SELECT USING (id = auth.uid() OR current_setting('role') = 'service_role');
      
    -- Create view
    EXECUTE 'CREATE OR REPLACE VIEW public.public_driver_locations AS
             SELECT id, lat AS latitude, lng AS longitude, is_online, vehicle_model AS vehicle_type
             FROM public.drivers';
  END IF;
END $$;

-- 4. Restrict technicians SELECT access and create restricted view (conditional on table existence)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'technicians') THEN
    -- Drop policy
    DROP POLICY IF EXISTS "Technicians viewable by everyone" ON public.technicians;
    
    -- Create policy
    CREATE POLICY "Technicians select policy" ON public.technicians
      FOR SELECT USING (id = auth.uid() OR current_setting('role') = 'service_role');
      
    -- Create view
    EXECUTE 'CREATE OR REPLACE VIEW public.public_technician_locations AS
             SELECT id, lat AS latitude, lng AS longitude, is_online, ''technician''::text AS vehicle_type
             FROM public.technicians';
  END IF;
END $$;

