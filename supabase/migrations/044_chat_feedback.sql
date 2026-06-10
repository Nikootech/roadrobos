-- Migration 044: Create chat_feedback Table
CREATE TABLE IF NOT EXISTS public.chat_feedback (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.chat_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_feedback FORCE ROW LEVEL SECURITY;

-- Allow inserts
DROP POLICY IF EXISTS "Anyone can insert feedback" ON public.chat_feedback;
CREATE POLICY "Anyone can insert feedback" ON public.chat_feedback
  FOR INSERT WITH CHECK (true);

-- Allow users to view their own feedback
DROP POLICY IF EXISTS "Users can view own feedback" ON public.chat_feedback;
CREATE POLICY "Users can view own feedback" ON public.chat_feedback
  FOR SELECT USING (auth.uid() = user_id);
