-- ROADROBOS INSTANT APPROVAL ENGINE
-- This script ensures that once an admin approves a request, the changes go live instantly.

-- Create table to log trigger errors so they don't block main transactions
CREATE TABLE IF NOT EXISTS public.trigger_errors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  trigger_name TEXT NOT NULL,
  entity_id UUID,
  error_message TEXT NOT NULL,
  error_detail TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1. Function to handle approval outcomes
CREATE OR REPLACE FUNCTION public.handle_approval_outcome()
RETURNS trigger AS $$
DECLARE
  v_entity_id UUID;
  v_payload JSONB;
  v_customer_id UUID;
BEGIN
  -- Only trigger on status change to 'approved'
  IF (NEW.status = 'approved' AND OLD.status = 'pending') THEN
    v_entity_id := NEW.entity_id;
    v_payload := NEW.payload;

    CASE NEW.type
      -- A. Driver / Technician KYC Approval
      WHEN 'partner_kyc' THEN
        BEGIN
          UPDATE public.profiles 
          SET kyc_status = 'verified',
              updated_at = NOW()
          WHERE id = v_entity_id;
        EXCEPTION WHEN OTHERS THEN
          INSERT INTO public.trigger_errors (trigger_name, entity_id, error_message, error_detail)
          VALUES ('partner_kyc_approval', v_entity_id, SQLERRM, SQLSTATE);
        END;

      -- B. Pricing Update Approval
      WHEN 'pricing' THEN
        BEGIN
          UPDATE public.service_items
          SET base_price = (v_payload->>'new_price')::NUMERIC
          WHERE id = v_entity_id;
        EXCEPTION WHEN OTHERS THEN
          INSERT INTO public.trigger_errors (trigger_name, entity_id, error_message, error_detail)
          VALUES ('pricing_approval', v_entity_id, SQLERRM, SQLSTATE);
        END;

      -- C. Refund Approval
      WHEN 'refund' THEN
        BEGIN
          -- Find the customer_id from service_bookings or ride_bookings
          SELECT customer_id INTO v_customer_id FROM public.service_bookings WHERE id = v_entity_id;
          IF v_customer_id IS NULL THEN
            SELECT customer_id INTO v_customer_id FROM public.ride_bookings WHERE id = v_entity_id;
          END IF;

          IF v_customer_id IS NOT NULL THEN
            INSERT INTO public.transactions (wallet_id, amount, type, status, description)
            VALUES (
              v_customer_id,
              (v_payload->>'amount')::NUMERIC,
              'credit',
              'completed',
              'Refund approved for booking: ' || v_entity_id
            );
          ELSE
            RAISE EXCEPTION 'Customer not found for booking ID %', v_entity_id;
          END IF;
        EXCEPTION WHEN OTHERS THEN
          INSERT INTO public.trigger_errors (trigger_name, entity_id, error_message, error_detail)
          VALUES ('refund_approval', v_entity_id, SQLERRM, SQLSTATE);
        END;

      -- D. Vehicle Attachment Approval
      WHEN 'vehicle_attachment' THEN
        BEGIN
          UPDATE public.rental_vehicles
          SET is_available = true
          WHERE id = v_entity_id;
        EXCEPTION WHEN OTHERS THEN
          INSERT INTO public.trigger_errors (trigger_name, entity_id, error_message, error_detail)
          VALUES ('vehicle_attachment_approval', v_entity_id, SQLERRM, SQLSTATE);
        END;

      ELSE
        -- Fallback or log unknown type
        RAISE NOTICE 'Unknown approval type: %', NEW.type;
    END CASE;

    -- Update the checker_id if not already set (safety check)
    NEW.checker_id := COALESCE(NEW.checker_id, auth.uid());
    NEW.updated_at := NOW();

  ELSIF (NEW.status = 'rejected' AND OLD.status = 'pending') THEN
    -- Optional: Notify the user about rejection
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
