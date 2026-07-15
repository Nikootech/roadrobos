-- Migration 050: Add missing rating and cancellation fields to ride_bookings
-- Description: Adds customer_rating, cancellation_reason, and cancelled_at columns to public.ride_bookings.

ALTER TABLE public.ride_bookings
  ADD COLUMN IF NOT EXISTS customer_rating INT,
  ADD COLUMN IF NOT EXISTS cancellation_reason TEXT,
  ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;

-- Reload schema cache to apply immediately
NOTIFY pgrst, 'reload schema';
