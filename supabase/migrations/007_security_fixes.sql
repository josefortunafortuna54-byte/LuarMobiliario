-- Migration 007: Security fixes — RLS and storage hardening
-- Corrige lacunas de segurança identificadas na auditoria:
--   1. Bookings insert sem validar user_id = auth.uid()
--   2. Storage DELETE policies sem verificação de owner
--   3. Properties/Lands UPDATE sem WITH CHECK (reatribuição de agent_id)
--   4. Users public read expõe PII (email/phone)
--   5. Sem trigger handle_new_user (perfil users não criado no signup)
--   6. Property/Land images geríveis por qualquer agent (sem vínculo à propriedade própria)

-- ════════════════════════════════════════════════════════════════════════
-- 1. BOOKINGS — validar user_id = auth.uid() no INSERT
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Bookings: authenticated insert" ON bookings;
CREATE POLICY "Bookings: authenticated insert" ON bookings
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

-- Restringir UPDATE: utilizador não pode mudar o status de si mesmo
-- (agentes/admins são os únicos que confirmam/cancelam definitivamente).
-- O próprio utilizador mantém o direito de cancelar o seu agendamento (pending -> cancelled),
-- mas não pode auto-confirmar.
DROP POLICY IF EXISTS "Bookings: update own" ON bookings;
CREATE POLICY "Bookings: update own" ON bookings
  FOR UPDATE USING (
    auth.uid() = user_id
    OR public.get_user_role() IN ('agent', 'admin')
  )
  WITH CHECK (
    (
      public.get_user_role() IN ('agent', 'admin')
      AND auth.uid() = user_id
    )
    OR (
      auth.uid() = user_id
      AND (
        OLD.status = 'pending'
        AND NEW.status = 'cancelled'
        AND NEW.user_id = OLD.user_id
        AND NEW.property_id = OLD.property_id
      )
    )
  );

-- ════════════════════════════════════════════════════════════════════════
-- 2. PROPERTIES / LANDS — UPDATE com WITH CHECK para impedir reatribuição
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Properties: update own or admin" ON properties;
CREATE POLICY "Properties: update own or admin" ON properties
  FOR UPDATE USING (
    auth.uid() = agent_id OR public.get_user_role() = 'admin'
  )
  WITH CHECK (
    public.get_user_role() = 'admin'
    OR auth.uid() = agent_id
  );

DROP POLICY IF EXISTS "Lands: update own or admin" ON lands;
CREATE POLICY "Lands: update own or admin" ON lands
  FOR UPDATE USING (
    auth.uid() = agent_id OR public.get_user_role() = 'admin'
  )
  WITH CHECK (
    public.get_user_role() = 'admin'
    OR auth.uid() = agent_id
  );

-- ════════════════════════════════════════════════════════════════════════
-- 3. USERS — não expor PII publicamente
-- O role-based UI requer o role dos agentes, mas email/phone não devem ser
-- públicos para potenciais alvos de spam. Só o próprio + admin leem tudo.
-- O app ainda necessita de dados de agente (name/role) ao listar propriedades —
-- por isso mantemos leitura pública de campos não-PII via uma VIEW restrita.
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Users: public read" ON users;
DROP POLICY IF EXISTS "Users: admin full access" ON users;

-- Leitura: admin ou o próprio utilizador vê tudo.
CREATE POLICY "Users: read own or admin" ON users
  FOR SELECT USING (
    auth.uid() = id OR public.get_user_role() = 'admin'
  );

-- Inserção: ao registar (via app), o utilizador cria o seu próprio perfil.
CREATE POLICY "Users: insert own" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Admins gerem tudo.
CREATE POLICY "Users: admin full access" ON users
  FOR ALL USING (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════════
-- 4. PROPERTY/LAND IMAGES — vincular à propriedade própria do agente
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Property images: agents and admins manage" ON property_images;
-- Agents/admins gerem imagens de propriedades próprias (ou todas, se admin)
CREATE POLICY "Property images: agents and admins manage" ON property_images
  FOR ALL USING (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND EXISTS (
        SELECT 1 FROM properties p
        WHERE p.id = property_images.property_id
          AND p.agent_id = auth.uid()
      )
    )
  )
  WITH CHECK (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND EXISTS (
        SELECT 1 FROM properties p
        WHERE p.id = property_images.property_id
          AND p.agent_id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "Land images: agents and admins manage" ON land_images;
CREATE POLICY "Land images: agents and admins manage" ON land_images
  FOR ALL USING (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND EXISTS (
        SELECT 1 FROM lands l
        WHERE l.id = land_images.land_id
          AND l.agent_id = auth.uid()
      )
    )
  )
  WITH CHECK (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND EXISTS (
        SELECT 1 FROM lands l
        WHERE l.id = land_images.land_id
          AND l.agent_id = auth.uid()
      )
    )
  );

-- ════════════════════════════════════════════════════════════════════════
-- 5. STORAGE — verificar ownership dos objetos
-- storage.objects usa owner_id (uuid do auth user) para objetos criados via API.
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Property images: delete own" ON storage.objects;
CREATE POLICY "Property images: delete own" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'property-images'
    AND owner_id = auth.uid()
  );

DROP POLICY IF EXISTS "Avatars: delete own" ON storage.objects;
CREATE POLICY "Avatars: delete own" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND owner_id = auth.uid()
  );

-- ════════════════════════════════════════════════════════════════════════
-- 6. TRIGGER — criar perfil users automaticamente no signup
-- Liga auth.users (Supabase Auth) a public.users.
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, name, email, role, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Utilizador'),
    NEW.email,
    'client',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ════════════════════════════════════════════════════════════════════════
-- 7. INDEX — bookings por utilizador/agente para listagens rápidas
-- ════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_bookings_user_created ON bookings(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bookings_property_status ON bookings(property_id, status);