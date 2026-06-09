-- Migration: 033_notification_preferences.sql
-- Description: Adds a notification_preferences JSONB column to the profiles table.
-- Default values match the UI settings.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
    "push": true,
    "email": true,
    "sms": false,
    "whatsapp": true,
    "rides": true,
    "offers": true,
    "maintenance": true,
    "wallet": false,
    "quiet": false,
    "sound": true
  }'::jsonb;
