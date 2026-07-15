-- Migration 047: Add missing columns to ride_bookings table and update constraints

ALTER TABLE public.ride_bookings
  ADD COLUMN IF NOT EXISTS otp TEXT,
  ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'Cash',
  ADD COLUMN IF NOT EXISTS razorpay_payment_id TEXT,
  ADD COLUMN IF NOT EXISTS scheduled_for TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'unpaid',
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Reload schema cache to apply immediately
NOTIFY pgrst, 'reload schema';
