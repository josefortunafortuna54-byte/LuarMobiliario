-- ── Partners table ─────────────────────────────────────────────────

DO $$ BEGIN
  CREATE TYPE partner_business_type AS ENUM (
    'imobiliaria', 'construtora', 'corretor', 'administrador', 'outro'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS partners (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  company_name  TEXT NOT NULL DEFAULT '',
  nif           TEXT NOT NULL DEFAULT '',
  business_type partner_business_type NOT NULL DEFAULT 'outro',
  address       TEXT NOT NULL DEFAULT '',
  whatsapp      TEXT NOT NULL DEFAULT '',
  license       TEXT NOT NULL DEFAULT '',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT partners_user_id_unique UNIQUE (user_id)
);

-- ── Indexes ──────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_partners_user_id ON partners(user_id);
CREATE INDEX IF NOT EXISTS idx_partners_business_type ON partners(business_type);

-- ── RLS ──────────────────────────────────────────────────────────

ALTER TABLE partners ENABLE ROW LEVEL SECURITY;

-- Public can read partners (for agent profiles)
CREATE POLICY "Partners: public read" ON partners
  FOR SELECT USING (true);

-- Partners can update their own profile
CREATE POLICY "Partners: update own" ON partners
  FOR UPDATE USING (auth.uid() = user_id);

-- Admins can do everything with partners
CREATE POLICY "Partners: admin full access" ON partners
  FOR ALL USING (public.get_user_role() = 'admin');
