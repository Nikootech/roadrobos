-- Migration 024: FCM Notifications & DB Webhooks

-- 1. Ensure pg_net extension is enabled
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 2. Add FCM token to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- (Optional) If there is a separate drivers table, add it there too, 
-- but in our schema drivers use profiles as well (roles).

-- 3. Create Notification Log table
CREATE TABLE IF NOT EXISTS public.notification_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  type TEXT NOT NULL,
  title TEXT,
  body TEXT,
  status TEXT DEFAULT 'pending',
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.notification_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own notification logs" ON public.notification_log
  FOR SELECT USING (auth.uid() = user_id);

-- 4. Generic Webhook Trigger Function using pg_net
CREATE OR REPLACE FUNCTION public.trigger_edge_function()
RETURNS trigger AS $$
DECLARE
  v_url TEXT;
  v_payload JSONB;
BEGIN
  -- Assuming Edge Function base URL is set in a custom setting or defaulting to localhost for dev
  -- In production, replace the fallback URL with your actual project URL: https://[PROJECT_REF].supabase.co/functions/v1/
  v_url := COALESCE(
    current_setting('app.settings.edge_function_base_url', true),
    'http://host.docker.internal:54321/functions/v1'
  ) || '/' || TG_ARGV[0];

  v_payload := jsonb_build_object(
    'type', TG_OP,
    'table', TG_TABLE_NAME,
    'schema', TG_TABLE_SCHEMA,
    'record', row_to_json(NEW),
    'old_record', row_to_json(OLD)
  );

  PERFORM net.http_post(
      url := v_url,
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || COALESCE(current_setting('app.settings.anon_key', true), 'fallback_anon_key')
      ),
      body := v_payload
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Webhook: notify-booking-accepted
CREATE TRIGGER on_ride_booking_accepted
  AFTER UPDATE OF status ON public.ride_bookings
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM 'accepted' AND NEW.status = 'accepted')
  EXECUTE FUNCTION public.trigger_edge_function('notify-booking-accepted');

-- 6. Webhook: notify-driver-assigned (using technician_jobs tech_id as driver assignment)
CREATE TRIGGER on_technician_job_assigned
  AFTER UPDATE OF tech_id ON public.technician_jobs
  FOR EACH ROW
  WHEN (OLD.tech_id IS NULL AND NEW.tech_id IS NOT NULL)
  EXECUTE FUNCTION public.trigger_edge_function('notify-driver-assigned');

-- Also adding trigger on delivery_orders if driver_id is set
CREATE TRIGGER on_delivery_driver_assigned
  AFTER UPDATE OF driver_id ON public.delivery_orders
  FOR EACH ROW
  WHEN (OLD.driver_id IS NULL AND NEW.driver_id IS NOT NULL)
  EXECUTE FUNCTION public.trigger_edge_function('notify-driver-assigned');

-- 7. Webhook: notify-kyc-approved
CREATE TRIGGER on_kyc_approved
  AFTER UPDATE OF status ON public.approvals
  FOR EACH ROW
  WHEN (NEW.type = 'partner_kyc' AND OLD.status IS DISTINCT FROM 'approved' AND NEW.status = 'approved')
  EXECUTE FUNCTION public.trigger_edge_function('notify-kyc-approved');

-- 8. Webhook: notify-payment-success
CREATE TRIGGER on_payment_success
  AFTER INSERT ON public.transactions
  FOR EACH ROW
  WHEN (NEW.type = 'payment' AND NEW.status = 'completed')
  EXECUTE FUNCTION public.trigger_edge_function('notify-payment-success');
