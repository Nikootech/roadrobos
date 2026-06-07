-- Create messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL, -- references service_bookings or ride_bookings (application level FK)
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add index on booking_id and created_at
CREATE INDEX IF NOT EXISTS idx_messages_booking_created 
ON public.messages (booking_id, created_at DESC);

-- Add index on receiver_id and is_read for unread badges
CREATE INDEX IF NOT EXISTS idx_messages_receiver_read 
ON public.messages (receiver_id, is_read);

-- Enable RLS
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Policies
-- Users can view their own messages (either as sender or receiver)
CREATE POLICY "Users can view their own messages"
ON public.messages
FOR SELECT
TO authenticated
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Users can insert messages where they are the sender
CREATE POLICY "Users can insert messages"
ON public.messages
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = sender_id);

-- Users can update messages they received (e.g., to mark as read)
CREATE POLICY "Users can update received messages"
ON public.messages
FOR UPDATE
TO authenticated
USING (auth.uid() = receiver_id);
