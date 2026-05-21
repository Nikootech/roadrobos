-- Migration: 012_technician_assigned_jobs.sql
-- Unifies tech_id and assigned_tech_id columns on public.technician_jobs

-- 1. If assigned_tech_id is empty, copy from tech_id
UPDATE public.technician_jobs
SET assigned_tech_id = tech_id
WHERE assigned_tech_id IS NULL AND tech_id IS NOT NULL;

-- 2. Update index for performance
DROP INDEX IF EXISTS idx_technician_jobs_tech_id;
CREATE INDEX IF NOT EXISTS idx_technician_jobs_assigned_tech_id 
  ON public.technician_jobs(assigned_tech_id);

-- 3. Update the RLS policy on service_bookings to use assigned_tech_id
DROP POLICY IF EXISTS "Assigned Techs can view their bookings" ON public.service_bookings;
CREATE POLICY "Assigned Techs can view their bookings" 
  ON public.service_bookings 
  FOR SELECT 
  USING (
    id IN (SELECT booking_id FROM public.technician_jobs WHERE assigned_tech_id = auth.uid())
  );
