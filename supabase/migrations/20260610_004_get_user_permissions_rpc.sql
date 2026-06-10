-- ============================================================
-- Migration: 20260610_004_get_user_permissions_rpc.sql
-- Purpose:   Single-query RPC for fetching user permissions.
--            Replaces the N+1 pattern (3 sequential DB calls) in
--            rbac_service.dart with one JOIN across user_roles,
--            role_permissions, and permissions.
-- ============================================================

CREATE OR REPLACE FUNCTION get_user_permissions(p_user_id uuid)
RETURNS TABLE (
  permission_name text,
  resource        text,
  action          text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    p.name        AS permission_name,
    p.resource,
    p.action
  FROM user_roles ur
  JOIN role_permissions rp ON rp.role_id = ur.role_id
  JOIN permissions p       ON p.id = rp.permission_id
  WHERE ur.user_id = p_user_id;
$$;

-- ── Grant rights ──────────────────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION get_user_permissions(uuid) TO authenticated;
REVOKE EXECUTE ON FUNCTION get_user_permissions(uuid) FROM anon;
