-- 028_employee_approvals.sql
-- Add is_approved column to profiles table and trigger logic for employee approvals.

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_approved BOOLEAN DEFAULT true;

-- Update existing profiles to be approved by default
UPDATE public.profiles SET is_approved = true WHERE is_approved IS NULL;

-- Trigger to automatically manage employee approvals
CREATE OR REPLACE FUNCTION public.set_profile_approval()
RETURNS trigger AS $$
BEGIN
  -- If inserting, or updating the role:
  IF (TG_OP = 'INSERT') THEN
    IF NEW.role NOT IN ('customer', 'driver') THEN
      NEW.is_approved := false;
    ELSE
      NEW.is_approved := true;
    END IF;
  ELSIF (TG_OP = 'UPDATE') THEN
    -- If role changed, and it's changed to a non-customer/non-driver role
    IF OLD.role IS DISTINCT FROM NEW.role THEN
      IF NEW.role NOT IN ('customer', 'driver') THEN
        NEW.is_approved := false;
      ELSE
        NEW.is_approved := true;
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_set_profile_approval ON public.profiles;
CREATE TRIGGER tr_set_profile_approval
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.set_profile_approval();
