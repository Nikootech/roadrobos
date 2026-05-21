-- Migration: 014_profiles_user_rls.sql

-- 1. Fix is_admin() function to support snake_case role names
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = user_id AND role IN (
      'admin', 
      'super_admin', 
      'founder_admin', 
      'superAdmin', 
      'founderAdmin',
      'ops_head',
      'city_manager',
      'area_manager',
      'finance_manager',
      'support_manager',
      'marketing_admin'
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Grant profiles SELECT access to all authenticated users (required for Wallet transfer lookup by phone)
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Authenticated users can view profiles" ON public.profiles;

CREATE POLICY "Authenticated users can view profiles" ON public.profiles 
  FOR SELECT USING (auth.role() = 'authenticated');

-- 3. Grant profiles UPDATE access to own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile." ON public.profiles;

CREATE POLICY "Users can update own profile" ON public.profiles 
  FOR UPDATE USING (auth.uid() = id);

-- 4. Grant profiles INSERT access (fallback for upsert)
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile." ON public.profiles;

CREATE POLICY "Users can insert their own profile" ON public.profiles 
  FOR INSERT WITH CHECK (
    auth.uid() = id 
    AND (role IS NULL OR role = 'customer')
    AND (points IS NULL OR points = 0)
    AND (total_rides IS NULL OR total_rides = 0)
    AND (kyc_status IS NULL OR kyc_status = 'not_started')
  );

-- 5. Trigger to prevent non-admins from updating sensitive columns (role, points, total_rides, kyc_status)
CREATE OR REPLACE FUNCTION public.prevent_sensitive_profile_modification()
RETURNS TRIGGER AS $$
BEGIN
  -- If the updater is not an admin, revert modifications to sensitive fields
  IF NOT public.is_admin(auth.uid()) THEN
    -- Lock role changes
    IF OLD.role IS DISTINCT FROM NEW.role THEN
      NEW.role := OLD.role;
    END IF;
    
    -- Lock loyalty points
    IF OLD.points IS DISTINCT FROM NEW.points THEN
      NEW.points := OLD.points;
    END IF;
    
    -- Lock ride counts
    IF OLD.total_rides IS DISTINCT FROM NEW.total_rides THEN
      NEW.total_rides := OLD.total_rides;
    END IF;
    
    -- Restrict KYC updates (Only allow standard user to submit for pending)
    IF OLD.kyc_status IS DISTINCT FROM NEW.kyc_status THEN
      IF NOT (OLD.kyc_status IN ('not_started', 'rejected') AND NEW.kyc_status = 'pending') THEN
        NEW.kyc_status := OLD.kyc_status;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_prevent_sensitive_profile_modification ON public.profiles;
CREATE TRIGGER tr_prevent_sensitive_profile_modification
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.prevent_sensitive_profile_modification();
