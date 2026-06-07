-- Migration: 016_missing_rls.sql

-- 1. RENTAL BOOKINGS
ALTER TABLE public.rental_bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Customers can view own rental bookings" ON public.rental_bookings;
CREATE POLICY "Customers can view own rental bookings" ON public.rental_bookings 
FOR SELECT USING (customer_id = auth.uid());

DROP POLICY IF EXISTS "Customers can create rental bookings" ON public.rental_bookings;
CREATE POLICY "Customers can create rental bookings" ON public.rental_bookings 
FOR INSERT WITH CHECK (customer_id = auth.uid());

DROP POLICY IF EXISTS "Admins can manage all rental bookings" ON public.rental_bookings;
CREATE POLICY "Admins can manage all rental bookings" ON public.rental_bookings 
FOR ALL USING (public.is_admin(auth.uid()));


-- 2. TECHNICIAN JOBS
ALTER TABLE public.technician_jobs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Technicians can view assigned jobs" ON public.technician_jobs;
CREATE POLICY "Technicians can view assigned jobs" ON public.technician_jobs 
FOR SELECT USING (tech_id = auth.uid());

DROP POLICY IF EXISTS "Technicians can update assigned jobs" ON public.technician_jobs;
CREATE POLICY "Technicians can update assigned jobs" ON public.technician_jobs 
FOR UPDATE USING (tech_id = auth.uid());

DROP POLICY IF EXISTS "Admins can manage all technician jobs" ON public.technician_jobs;
CREATE POLICY "Admins can manage all technician jobs" ON public.technician_jobs 
FOR ALL USING (public.is_admin(auth.uid()));
