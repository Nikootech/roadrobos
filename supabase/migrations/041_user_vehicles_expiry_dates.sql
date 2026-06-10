-- Migration: 041_user_vehicles_expiry_dates.sql
-- Description: Adds expiry date columns (fc_expiry, insurance_expiry, tax_expiry) to user_vehicles.

ALTER TABLE public.user_vehicles 
ADD COLUMN IF NOT EXISTS fc_expiry TIMESTAMPTZ DEFAULT NULL,
ADD COLUMN IF NOT EXISTS insurance_expiry TIMESTAMPTZ DEFAULT NULL,
ADD COLUMN IF NOT EXISTS tax_expiry TIMESTAMPTZ DEFAULT NULL;
