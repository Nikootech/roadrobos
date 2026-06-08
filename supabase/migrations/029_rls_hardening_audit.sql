-- ========================================================
-- Migration: 029_rls_hardening_audit.sql
-- Description: Enable RLS and define access policies for remaining tables 
--              (chat_rooms, chat_messages, trigger_errors, payment_audit_log)
--              to ensure a clean RLS audit check.
-- ========================================================

-- 1. CHAT ROOMS (Obsolete/Starter Table)
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view chat rooms they participate in" ON public.chat_rooms;
CREATE POLICY "Users can view chat rooms they participate in" ON public.chat_rooms
    FOR SELECT TO authenticated
    USING (auth.uid() = ANY(participants));

DROP POLICY IF EXISTS "Admins can manage all chat rooms" ON public.chat_rooms;
CREATE POLICY "Admins can manage all chat rooms" ON public.chat_rooms
    FOR ALL TO authenticated
    USING (public.is_admin(auth.uid()));

-- 2. CHAT MESSAGES (Obsolete/Starter Table)
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view messages in their rooms" ON public.chat_messages;
CREATE POLICY "Users can view messages in their rooms" ON public.chat_messages
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.chat_rooms r
            WHERE r.id = room_id AND auth.uid() = ANY(r.participants)
        )
    );

DROP POLICY IF EXISTS "Users can insert messages in their rooms" ON public.chat_messages;
CREATE POLICY "Users can insert messages in their rooms" ON public.chat_messages
    FOR INSERT TO authenticated
    WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.chat_rooms r
            WHERE r.id = room_id AND auth.uid() = ANY(r.participants)
        )
    );

DROP POLICY IF EXISTS "Admins can manage all chat messages" ON public.chat_messages;
CREATE POLICY "Admins can manage all chat messages" ON public.chat_messages
    FOR ALL TO authenticated
    USING (public.is_admin(auth.uid()));

-- 3. TRIGGER ERRORS (Operational / Triggers log)
ALTER TABLE public.trigger_errors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view trigger errors" ON public.trigger_errors;
CREATE POLICY "Admins can view trigger errors" ON public.trigger_errors
    FOR SELECT TO authenticated
    USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins can delete trigger errors" ON public.trigger_errors;
CREATE POLICY "Admins can delete trigger errors" ON public.trigger_errors
    FOR DELETE TO authenticated
    USING (public.is_admin(auth.uid()));

-- 4. PAYMENT AUDIT LOG (Payment Verification log)
ALTER TABLE public.payment_audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view payment audit logs" ON public.payment_audit_log;
CREATE POLICY "Admins can view payment audit logs" ON public.payment_audit_log
    FOR SELECT TO authenticated
    USING (public.is_admin(auth.uid()));
