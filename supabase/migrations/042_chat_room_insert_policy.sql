-- ============================================================
-- Migration: 042_chat_room_insert_policy.sql
-- Purpose:   Add INSERT and UPDATE policies for chat_rooms to 
--            allow authenticated users to start chat rooms 
--            they participate in.
-- ============================================================

DROP POLICY IF EXISTS "Users can insert chat rooms they participate in" ON public.chat_rooms;
CREATE POLICY "Users can insert chat rooms they participate in" ON public.chat_rooms
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = ANY(participants));

DROP POLICY IF EXISTS "Users can update chat rooms they participate in" ON public.chat_rooms;
CREATE POLICY "Users can update chat rooms they participate in" ON public.chat_rooms
    FOR UPDATE TO authenticated
    USING (auth.uid() = ANY(participants))
    WITH CHECK (auth.uid() = ANY(participants));
