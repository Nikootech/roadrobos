-- 027_device_session_limit.sql
-- Add current_device_id column to profiles table to enforce single-device session limits.

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_device_id TEXT;
