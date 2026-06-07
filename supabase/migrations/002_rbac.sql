-- RBAC SCHEMA FOR ROADROBOS ENTERPRISE
-- This script adds granular Role-Based Access Control

-- 1. Roles Table
CREATE TABLE IF NOT EXISTS public.roles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Permissions Table
CREATE TABLE IF NOT EXISTS public.permissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT UNIQUE NOT NULL, -- e.g. 'ride.create', 'refund.approve'
  module TEXT NOT NULL,       -- e.g. 'mobility', 'finance', 'admin'
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Role Permissions (Many-to-Many)
CREATE TABLE IF NOT EXISTS public.role_permissions (
  role_id UUID REFERENCES public.roles(id) ON DELETE CASCADE,
  permission_id UUID REFERENCES public.permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. User Roles (Many-to-Many, though usually 1 role per user in this app)
CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id UUID REFERENCES public.roles(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Seed Initial Roles
INSERT INTO public.roles (name, description) VALUES
  ('super_admin', 'Full system access'),
  ('founder_admin', 'Executive level access'),
  ('ops_head', 'Operations management'),
  ('city_manager', 'City-level operations'),
  ('area_manager', 'Area-specific management'),
  ('finance_manager', 'Financial controls and approvals'),
  ('support_manager', 'Customer support oversight'),
  ('marketing_admin', 'Campaign and rewards management'),
  ('auditor', 'Read-only audit access'),
  ('analyst', 'Data analysis access'),
  ('customer', 'Standard end-user'),
  ('driver', 'Partner driver'),
  ('technician', 'Service provider')
ON CONFLICT (name) DO NOTHING;

-- 6. RLS Policies for RBAC
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Roles are viewable by authenticated users" ON public.roles FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Permissions are viewable by authenticated users" ON public.permissions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "User roles are viewable by the user or admins" ON public.user_roles FOR SELECT USING (
  auth.uid() = user_id OR public.is_admin(auth.uid())
);

-- 7. Helper Function to check permissions (for RLS and Edge Functions)
CREATE OR REPLACE FUNCTION public.has_permission(p_user_id UUID, p_permission_name TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = p_user_id AND p.name = p_permission_name
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
