-- 026_ratings.sql

CREATE TABLE IF NOT EXISTS public.ratings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL UNIQUE,
    reviewer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reviewee_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('driver', 'technician')),
    score SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- View to get average ratings per partner
CREATE OR REPLACE VIEW public.partner_avg_rating AS
SELECT 
    reviewee_id,
    ROUND(AVG(score)::numeric, 1) as avg_score,
    COUNT(id) as total_reviews
FROM public.ratings
GROUP BY reviewee_id;

-- Enable RLS
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Anyone can read ratings (necessary for displaying average ratings)
CREATE POLICY "Ratings are viewable by everyone"
    ON public.ratings FOR SELECT
    USING (true);

-- Users can insert their own reviews
CREATE POLICY "Users can insert their own reviews"
    ON public.ratings FOR INSERT
    WITH CHECK (auth.uid() = reviewer_id);

-- Admins can update/delete reviews (assuming a role check via jwt or simple generic rule for now, 
-- or we rely on backend admin service role, but let's provide a basic delete for admins if we have a way)
-- We'll allow deletion by the reviewer for now, and admin via service key.
CREATE POLICY "Users can delete their own reviews"
    ON public.ratings FOR DELETE
    USING (auth.uid() = reviewer_id);
