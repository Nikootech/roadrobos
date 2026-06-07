-- Migration: 022_delivery.sql
-- Description: Creates delivery_orders table, enum, RLS policies, and delivery-proofs storage bucket.

-- ── 1. Delivery status enum ──────────────────────────────────────────────────
DO $$ BEGIN
  CREATE TYPE public.delivery_status AS ENUM (
    'pending',
    'accepted',
    'picked_up',
    'in_transit',
    'delivered',
    'cancelled'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ── 2. delivery_orders table ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.delivery_orders (
  id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id         UUID            NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  driver_id           UUID            REFERENCES auth.users(id) ON DELETE SET NULL,
  pickup_address      TEXT            NOT NULL,
  dropoff_address     TEXT            NOT NULL,
  package_description TEXT            NOT NULL DEFAULT '',
  weight_kg           NUMERIC(6, 2)   NOT NULL DEFAULT 1.0 CHECK (weight_kg BETWEEN 0.5 AND 50),
  status              public.delivery_status NOT NULL DEFAULT 'pending',
  estimated_price     NUMERIC(10, 2)  NOT NULL DEFAULT 0.00,
  final_price         NUMERIC(10, 2),
  proof_image_url     TEXT,
  created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  deleted_at          TIMESTAMPTZ
);

-- Automatically maintain updated_at
CREATE OR REPLACE FUNCTION public.set_delivery_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_delivery_updated_at
  BEFORE UPDATE ON public.delivery_orders
  FOR EACH ROW EXECUTE FUNCTION public.set_delivery_updated_at();

-- Indexes
CREATE INDEX IF NOT EXISTS idx_delivery_orders_customer_id ON public.delivery_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_delivery_orders_driver_id   ON public.delivery_orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_delivery_orders_status      ON public.delivery_orders(status);

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.delivery_orders;

-- ── 3. Row-Level Security ────────────────────────────────────────────────────
ALTER TABLE public.delivery_orders ENABLE ROW LEVEL SECURITY;

-- Customers: can see only their own non-deleted orders
CREATE POLICY "delivery_customer_select"
  ON public.delivery_orders
  FOR SELECT
  USING (auth.uid() = customer_id AND deleted_at IS NULL);

-- Customers: can create orders for themselves
CREATE POLICY "delivery_customer_insert"
  ON public.delivery_orders
  FOR INSERT
  WITH CHECK (auth.uid() = customer_id);

-- Drivers: can view orders assigned to them OR all pending orders (to accept)
CREATE POLICY "delivery_driver_select"
  ON public.delivery_orders
  FOR SELECT
  USING (
    deleted_at IS NULL AND (
      driver_id = auth.uid()
      OR (status = 'pending' AND driver_id IS NULL)
    )
  );

-- Drivers: can update only their assigned orders (accept + status transitions)
CREATE POLICY "delivery_driver_update"
  ON public.delivery_orders
  FOR UPDATE
  USING (
    driver_id = auth.uid()
    OR (status = 'pending' AND driver_id IS NULL)
  )
  WITH CHECK (true);

-- Admins: full access (role-based via app metadata)
CREATE POLICY "delivery_admin_all"
  ON public.delivery_orders
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'management')
  );

-- ── 4. Storage bucket for proof photos ──────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'delivery-proofs',
  'delivery-proofs',
  true,
  5242880,  -- 5 MB
  ARRAY['image/jpeg','image/png','image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Drivers can upload to delivery-proofs/<order_id>/
CREATE POLICY "delivery_proof_upload"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'delivery-proofs');

-- Anyone can view delivery proof images (public bucket)
CREATE POLICY "delivery_proof_select"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'delivery-proofs');
