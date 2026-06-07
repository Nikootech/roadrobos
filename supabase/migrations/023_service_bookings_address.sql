-- Migration: 023_service_bookings_address.sql
-- Description: Adds address fields to service_bookings table for service location tracking.

ALTER TABLE public.service_bookings 
  ADD COLUMN IF NOT EXISTS address TEXT,
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
