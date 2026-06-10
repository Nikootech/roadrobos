-- ============================================================
-- Migration: 20260610_002_chat_rls.sql
-- Purpose:   Enable Row Level Security on chat_messages table.
--            Ensures users can only read/write their own messages.
-- ============================================================

-- Enable RLS on the chat_messages table
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Force RLS for table owners too (prevents accidental bypasses)
ALTER TABLE chat_messages FORCE ROW LEVEL SECURITY;

-- ── SELECT policy ─────────────────────────────────────────────────────────────
-- Users can only read messages where they are either the sender or the receiver.
-- This covers both 1:1 DMs and support chats (where receiver_id = support agent).
CREATE POLICY "chat_messages_select_own"
  ON chat_messages
  FOR SELECT
  USING (
    auth.uid() = sender_id
    OR auth.uid() = receiver_id
  );

-- ── INSERT policy ─────────────────────────────────────────────────────────────
-- Users can only insert messages where they are the sender.
-- Prevents impersonation attacks (e.g. crafting messages as another user).
CREATE POLICY "chat_messages_insert_own"
  ON chat_messages
  FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
  );

-- ── UPDATE policy ─────────────────────────────────────────────────────────────
-- Users can only update their own sent messages (e.g. edit/recall feature).
CREATE POLICY "chat_messages_update_own"
  ON chat_messages
  FOR UPDATE
  USING (auth.uid() = sender_id)
  WITH CHECK (auth.uid() = sender_id);

-- ── DELETE policy ─────────────────────────────────────────────────────────────
-- Users can only delete their own sent messages.
CREATE POLICY "chat_messages_delete_own"
  ON chat_messages
  FOR DELETE
  USING (auth.uid() = sender_id);

-- ── Verify RLS is active (informational) ──────────────────────────────────────
-- Run this query to confirm: SELECT relname, relrowsecurity FROM pg_class WHERE relname = 'chat_messages';
