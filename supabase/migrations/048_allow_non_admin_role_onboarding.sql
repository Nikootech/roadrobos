-- Migration: 048_allow_non_admin_role_onboarding.sql
-- Description: Allow users to set or switch their own role between non-admin roles ('customer', 'driver', 'technician') during onboarding/registration.

-- 1. Redefine the trigger function to allow changing roles between non-admin roles
CREATE OR REPLACE FUNCTION public.prevent_sensitive_profile_modification()
RETURNS TRIGGER AS $$
BEGIN
  -- If the updater is not an admin, revert modifications to sensitive fields
  IF NOT public.is_admin(auth.uid()) THEN
    -- Lock role changes unless switching between non-admin roles (customer, driver, technician)
    IF OLD.role IS DISTINCT FROM NEW.role THEN
      IF OLD.role IN (
        'admin', 'super_admin', 'founder_admin', 'superAdmin', 'founderAdmin', 
        'ops_head', 'city_manager', 'area_manager', 'finance_manager', 
        'support_manager', 'marketing_admin'
      ) OR NEW.role IN (
        'admin', 'super_admin', 'founder_admin', 'superAdmin', 'founderAdmin', 
        'ops_head', 'city_manager', 'area_manager', 'finance_manager', 
        'support_manager', 'marketing_admin'
      ) THEN
        NEW.role := OLD.role;
      END IF;
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

-- 2. Drop and recreate the INSERT RLS policy on profiles to allow non-admin roles on creation
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;

CREATE POLICY "Users can insert their own profile" ON public.profiles 
  FOR INSERT WITH CHECK (
    auth.uid() = id 
    AND (role IS NULL OR role IN ('customer', 'driver', 'technician'))
    AND (points IS NULL OR points = 0)
    AND (total_rides IS NULL OR total_rides = 0)
    AND (kyc_status IS NULL OR kyc_status = 'not_started')
  );
