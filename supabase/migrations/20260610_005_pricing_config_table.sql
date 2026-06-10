-- ============================================================
-- Migration: 20260610_005_pricing_config_table.sql
-- Purpose:   Move hardcoded pricing constants from PricingService
--            into a database table for runtime configuration.
--            See lib/core/services/pricing_service.dart for usage.
-- ============================================================

CREATE TABLE IF NOT EXISTS pricing_config (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  service_type    text        NOT NULL,  -- 'ride', 'service', 'delivery', 'rental'
  key             text        NOT NULL,  -- e.g. 'gst_rate', 'platform_fee', 'handling_charges'
  value           numeric     NOT NULL,
  effective_from  timestamptz NOT NULL DEFAULT NOW(),
  effective_until timestamptz,
  is_active       boolean     NOT NULL DEFAULT TRUE,
  created_at      timestamptz NOT NULL DEFAULT NOW(),
  updated_at      timestamptz NOT NULL DEFAULT NOW(),

  CONSTRAINT pricing_config_unique_active UNIQUE (service_type, key, effective_from)
);

-- Seed initial pricing values (mirror the current hardcoded constants)
INSERT INTO pricing_config (service_type, key, value) VALUES
  ('all',      'gst_rate',           0.18),
  ('all',      'platform_fee',      20.00),
  ('all',      'handling_charges',  10.00);

-- ── RLS ────────────────────────────────────────────────────────────────────────
ALTER TABLE pricing_config ENABLE ROW LEVEL SECURITY;

-- Public read access — pricing rates are not sensitive
CREATE POLICY "pricing_config_select_all"
  ON pricing_config FOR SELECT
  USING (is_active = TRUE);

-- Only service-role (admin) can insert/update/delete
-- (no client-side write access)
CREATE POLICY "pricing_config_write_service_role"
  ON pricing_config FOR ALL
  USING (auth.role() = 'service_role');

-- ── Helper function ────────────────────────────────────────────────────────────
-- Used by the Flutter app to fetch the latest active config in one call.
CREATE OR REPLACE FUNCTION get_active_pricing_config(p_service_type text DEFAULT 'all')
RETURNS TABLE (
  key   text,
  value numeric
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT key, value
  FROM pricing_config
  WHERE is_active = TRUE
    AND (service_type = p_service_type OR service_type = 'all')
    AND (effective_until IS NULL OR effective_until > NOW())
  ORDER BY service_type DESC, effective_from DESC;
$$;

GRANT EXECUTE ON FUNCTION get_active_pricing_config(text) TO authenticated;
GRANT EXECUTE ON FUNCTION get_active_pricing_config(text) TO anon;
