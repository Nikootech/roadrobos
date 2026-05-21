-- Migration: 010_banners_columns.sql
-- Ensures the banners table has all columns that BannerOffer.fromMap() expects.
-- The original 001_base_schema.sql schema had: id, image_url, link_url, title, is_active.
-- BannerOffer.fromMap() also reads: subtitle, cta.

ALTER TABLE public.banners
  ADD COLUMN IF NOT EXISTS subtitle TEXT,
  ADD COLUMN IF NOT EXISTS cta      TEXT;

-- Enable RLS if not already enabled
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read active banners (public content)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'banners'
      AND policyname = 'Anyone can read active banners'
  ) THEN
    CREATE POLICY "Anyone can read active banners"
      ON public.banners
      FOR SELECT
      USING (is_active = true);
  END IF;
END $$;

-- Allow admins to manage banners
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'banners'
      AND policyname = 'Admins can manage banners'
  ) THEN
    CREATE POLICY "Admins can manage banners"
      ON public.banners
      FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.profiles
          WHERE id = auth.uid()
            AND role IN ('admin', 'super_admin')
        )
      );
  END IF;
END $$;

-- Seed demo banners from MockData so the home screen carousel shows real content.
INSERT INTO public.banners (title, subtitle, image_url, cta, is_active)
VALUES
  (
    'Free AC Check-up',
    'Book any service & get AC inspection free',
    'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=600',
    'ACFREE',
    true
  ),
  (
    '20% Off First Ride',
    'Use code FIRST20 on your maiden journey',
    'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600',
    'FIRST20',
    true
  ),
  (
    'Gold Membership',
    'Unlock priority service & exclusive perks',
    'https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=600',
    'GOLD',
    true
  )
ON CONFLICT DO NOTHING;
