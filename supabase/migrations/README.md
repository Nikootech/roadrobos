# Supabase Migrations — RoadRobos

This directory contains all Supabase database migrations for the RoadRobos project.
Each migration file follows strict ordering and naming conventions to ensure
safe, repeatable deployments across all environments.

---

## Naming Convention

```
YYYYMMDD_NNN_description.sql
```

- `YYYYMMDD` — Date (UTC) the migration was authored
- `NNN` — 3-digit sequence number (001, 002…) scoped to that day
- `description` — Snake_case lowercase description of the change

**Examples:**
- `20260610_001_wallet_rls.sql`
- `20260610_002_chat_rls.sql`
- `20260610_003_transfer_funds_atomic.sql`

---

## Migration Files (Current)

| File | Date | Description |
|------|------|-------------|
| `20260610_001_wallet_rls.sql` | 2026-06-10 | Enable RLS on wallets table |
| `20260610_002_chat_rls.sql` | 2026-06-10 | Enable RLS on chat_messages + 4 policies |
| `20260610_003_transfer_funds_atomic.sql` | 2026-06-10 | Atomic fund transfer RPC with SELECT FOR UPDATE locking |
| `20260610_004_get_user_permissions_rpc.sql` | 2026-06-10 | Single-JOIN RBAC permissions RPC |
| `20260610_005_pricing_config_table.sql` | 2026-06-10 | DB-driven pricing config table and active helper RPC |

---

## Applying Migrations

### Local Development
```bash
cd "android app"
supabase db reset   # re-runs all migrations from scratch
supabase db push    # apply new migrations to local DB
```

### Production (CI/CD)
Migrations are run automatically by the `migrate-db` job in `.github/workflows/ci.yml`
on every push to `main`. See the CI file for the exact `supabase db push` command.

### Manual Production Apply
```bash
supabase db push \
  --project-ref YOUR_PROJECT_REF \
  --db-url "postgresql://postgres:PASSWORD@db.YOUR_PROJECT_REF.supabase.co:5432/postgres"
```

---

## Rules

1. **Never edit a committed migration.** If you need to change something, write a new migration.
2. **Always test migrations in a local Supabase instance first** (`supabase start` → `supabase db push`).
3. **Include ROLLBACK SQL in a comment** for any destructive changes.
4. **Use `IF NOT EXISTS` / `IF EXISTS`** to make migrations idempotent where possible.
5. **SECURITY DEFINER functions** must include `SET search_path = public` to prevent injection.
6. **RLS policies** must be tested against the anon and authenticated roles before pushing.
