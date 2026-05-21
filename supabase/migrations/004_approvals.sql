-- APPROVAL ENGINE & AUDIT LOGS FOR ROADROBOS
-- This script enables maker-checker workflows for enterprise operations

-- 1. Approvals Table
CREATE TABLE IF NOT EXISTS public.approvals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT NOT NULL, -- 'refund', 'pricing', 'partner_kyc', 'payout'
  entity_type TEXT NOT NULL, -- 'transactions', 'service_items', 'profiles', 'payout_requests'
  entity_id UUID, -- ID of the target record
  payload JSONB NOT NULL, -- Data to be applied upon approval
  maker_id UUID REFERENCES auth.users(id),
  checker_id UUID REFERENCES auth.users(id),
  status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL, -- 'CREATE', 'UPDATE', 'DELETE', 'APPROVE', 'REJECT'
  entity_type TEXT NOT NULL,
  entity_id UUID,
  changes JSONB, -- { "field": [old_val, new_val] }
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. RLS Policies
ALTER TABLE public.approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Approvals: Viewable by admins or the maker
CREATE POLICY "Approvals are viewable by admins and makers" ON public.approvals 
FOR SELECT USING (
  auth.uid() = maker_id OR 
  EXISTS (
    SELECT 1 FROM public.user_roles ur 
    JOIN public.roles r ON ur.role_id = r.id 
    WHERE ur.user_id = auth.uid() AND r.name IN ('super_admin', 'admin', 'ops_head', 'finance_manager')
  )
);

-- Approvals: Insertable by anyone (authenticated) but restricted by app logic
CREATE POLICY "Authenticated users can create approval requests" ON public.approvals 
FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = maker_id);

-- Audit Logs: Viewable only by specific admin roles
CREATE POLICY "Audit logs are viewable by auditors and super_admins" ON public.audit_logs 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur 
    JOIN public.roles r ON ur.role_id = r.id 
    WHERE ur.user_id = auth.uid() AND r.name IN ('super_admin', 'auditor')
  )
);

-- 4. Function to automatically record audit logs for approvals
CREATE OR REPLACE FUNCTION public.log_approval_action()
RETURNS trigger AS $$
BEGIN
  IF (OLD.status != NEW.status) THEN
    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id, changes)
    VALUES (
      auth.uid(), 
      NEW.status, 
      'approvals', 
      NEW.id, 
      jsonb_build_object('status', jsonb_build_array(OLD.status, NEW.status))
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_approval_status_change
  AFTER UPDATE ON public.approvals
  FOR EACH ROW EXECUTE PROCEDURE public.log_approval_action();
