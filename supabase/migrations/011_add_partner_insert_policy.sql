-- ── Partners: allow users to create their own partner profile ────

-- The base migration (003) only permits SELECT for everyone, UPDATE of own
-- row and admin full access. This policy allows an authenticated user to
-- INSERT a partner row that belongs to themselves.
CREATE POLICY "Partners: insert own" ON partners
  FOR INSERT WITH CHECK (auth.uid() = user_id);