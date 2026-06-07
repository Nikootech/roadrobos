-- Migration: 019_fix_tech_rls.sql
-- Description: Fixes RLS policies on technician_jobs that incorrectly reference tech_id instead of assigned_tech_id.

-- 1. Drop the broken policies from 016_missing_rls.sql
DROP POLICY IF EXISTS "Technicians can view assigned jobs" ON public.technician_jobs;
DROP POLICY IF EXISTS "Technicians can update assigned jobs" ON public.technician_jobs;

-- 2. Recreate them referencing assigned_tech_id = auth.uid()
CREATE POLICY "Technicians can view assigned jobs" ON public.technician_jobs 
  FOR SELECT USING (assigned_tech_id = auth.uid());

CREATE POLICY "Technicians can update assigned jobs" ON public.technician_jobs 
  FOR UPDATE USING (assigned_tech_id = auth.uid());

-- 3. Data fix: copy assigned_tech_id to tech_id in case both columns exist as a legacy artifact
UPDATE public.technician_jobs 
SET tech_id = assigned_tech_id 
WHERE tech_id IS NULL AND assigned_tech_id IS NOT NULL;

-- Note: If the tech_id column still exists and is redundant in public.technician_jobs,
-- it should be dropped in a future migration after verifying all client applications and backend APIs
-- have migrated to using assigned_tech_id exclusively.
