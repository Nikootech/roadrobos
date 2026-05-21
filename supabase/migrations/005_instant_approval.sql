-- ROADROBOS INSTANT APPROVAL ENGINE
-- This script ensures that once an admin approves a request, the changes go live instantly.

-- 1. Function to handle approval outcomes
CREATE OR REPLACE FUNCTION public.handle_approval_outcome()
RETURNS trigger AS $$
DECLARE
  v_entity_id UUID;
  v_payload JSONB;
BEGIN
  -- Only trigger on status change to 'approved'
  IF (NEW.status = 'approved' AND OLD.status = 'pending') THEN
    v_entity_id := NEW.entity_id;
    v_payload := NEW.payload;

    CASE NEW.type
      -- A. Driver / Technician KYC Approval
      WHEN 'partner_kyc' THEN
        UPDATE public.profiles 
        SET is_verified = true,
            status = 'active',
            metadata = metadata || v_payload
        WHERE id = v_entity_id;

      -- B. Pricing Update Approval
      WHEN 'pricing' THEN
        UPDATE public.service_items
        SET price = (v_payload->>'new_price')::NUMERIC,
            updated_at = NOW()
        WHERE id = v_entity_id;

      -- C. Refund Approval
      WHEN 'refund' THEN
        -- Logic to insert into transactions or trigger a payment gateway hook
        INSERT INTO public.transactions (user_id, amount, type, status, description)
        VALUES (
          (SELECT user_id FROM public.bookings WHERE id = v_entity_id),
          (v_payload->>'amount')::NUMERIC,
          'REFUND',
          'COMPLETED',
          'Refund approved for booking: ' || v_entity_id
        );

      -- D. Vehicle Attachment Approval
      WHEN 'vehicle_attachment' THEN
        UPDATE public.vehicles
        SET status = 'verified',
            verified_at = NOW()
        WHERE id = v_entity_id;

      ELSE
        -- Fallback or log unknown type
        RAISE NOTICE 'Unknown approval type: %', NEW.type;
    END CASE;

    -- Update the checker_id if not already set (safety check)
    NEW.checker_id := auth.uid();
    NEW.updated_at := NOW();

  ELSIF (NEW.status = 'rejected' AND OLD.status = 'pending') THEN
    -- Optional: Notify the user about rejection
    -- This could be handled by a separate trigger or edge function listening to this table
    NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Create the trigger
DROP TRIGGER IF EXISTS tr_on_approval_outcome ON public.approvals;
CREATE TRIGGER tr_on_approval_outcome
  BEFORE UPDATE ON public.approvals
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_approval_outcome();

-- 3. RLS Policy for instant approval
-- Only users with 'ops_head', 'super_admin' or 'finance_manager' roles can approve
CREATE OR REPLACE FUNCTION public.can_approve_requests()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON ur.role_id = r.id
    WHERE ur.user_id = auth.uid() 
    AND r.name IN ('super_admin', 'ops_head', 'finance_manager', 'admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the approvals policy
DROP POLICY IF EXISTS "Admins can update approval status" ON public.approvals;
CREATE POLICY "Admins can update approval status" ON public.approvals
  FOR UPDATE
  USING (public.can_approve_requests())
  WITH CHECK (public.can_approve_requests());
