-- Migration: 032_2fa_mfa_support.sql
-- Description: Adds TOTP 2FA tracking columns to profiles table.
-- The actual TOTP secret is managed entirely by Supabase Auth MFA (NOT stored here).
-- We only track whether 2FA is active per user for display purposes.

-- 1. Add mfa_enabled flag and enrollment timestamp
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS mfa_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS mfa_enrolled_at TIMESTAMPTZ;

-- 2. Index for fast lookup when enforcing 2FA on login
CREATE INDEX IF NOT EXISTS idx_profiles_mfa_enabled
  ON public.profiles(mfa_enabled)
  WHERE mfa_enabled = true;

-- 3. RLS: Users can read and update their own MFA status
--    (The existing "Users can update own profile." policy already covers this.)
--    No extra RLS policy needed.

-- 4. Ensure Supabase Realtime is still publishing profiles
--    (already added in migration 031, safe to re-run idempotently)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'profiles'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
  END IF;
END;
$$;
