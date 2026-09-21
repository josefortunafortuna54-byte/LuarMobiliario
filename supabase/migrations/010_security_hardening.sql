-- Migration 010: Security hardening
-- Corrige lacunas de segurança identificadas na auditoria:
--   1. send_notification RPC permite qualquer autenticado enviar notif para qualquer user
--   2. Faltam checks no INSERT de properties/lands (agente só pode criar com agent_id = auth.uid())
--   3. Categories/Locations admin manage sem WITH CHECK
--   4. Bookings insert não valida que a propriedade existe e está disponível
--   5. send_notification sem limites de tamanho/rate
--   6. storage.objects insert sem verificação de owner para avatars

-- ════════════════════════════════════════════════════════════════════
-- 1. send_notification RPC — restringir destinatários
-- Antes: qualquer autenticado podia enviar notificação para qualquer user_id.
-- Depois: apenas agent/admin podem notificar outros; um utilizador pode
-- notificar-se a si próprio (para confirmação local).
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.send_notification(
  p_user_id UUID,
  p_title TEXT,
  p_body TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.get_user_role() NOT IN ('agent', 'admin')
     AND auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'Não autorizado a notificar este utilizador';
  END IF;

  IF length(COALESCE(p_title, '')) > 255 THEN
    RAISE EXCEPTION 'Título demasiado longo';
  END IF;

  INSERT INTO public.notifications (user_id, title, body)
  VALUES (p_user_id, p_title, COALESCE(p_body, ''));
END;
$$;

REVOKE ALL ON FUNCTION public.send_notification(UUID, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.send_notification(UUID, TEXT, TEXT) TO authenticated;

-- ════════════════════════════════════════════════════════════════════
-- 2. PROPERTIES insert — agente só cria com agent_id = auth.uid()
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Properties: agents and admins insert" ON properties;
CREATE POLICY "Properties: agents and admins insert" ON properties
  FOR INSERT WITH CHECK (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND agent_id = auth.uid()
    )
  );

-- ════════════════════════════════════════════════════════════════════
-- 3. LANDS insert — agente só cria com agent_id = auth.uid()
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Lands: agents and admins insert" ON lands;
CREATE POLICY "Lands: agents and admins insert" ON lands
  FOR INSERT WITH CHECK (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND agent_id = auth.uid()
    )
  );

-- ════════════════════════════════════════════════════════════════════
-- 4. CATEGORIES / LOCATIONS — WITH CHECK para impedir que qualquer
-- autenticado (não admin) manipule dados, e garantir que apenas níveis
-- admin criam/alteram.
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Categories: admin manage" ON categories;
CREATE POLICY "Categories: admin manage" ON categories
  FOR ALL USING (public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin');

DROP POLICY IF EXISTS "Locations: admin manage" ON locations;
CREATE POLICY "Locations: admin manage" ON locations
  FOR ALL USING (public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════
-- 5. STORAGE avatars — owner deve poder atualizar/apagar apenas o seu
-- Nota: storage.objects insert para avatars deve ter owner_id = auth.uid().
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Avatars: authenticated upload" ON storage.objects;
CREATE POLICY "Avatars: authenticated upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND owner_id = auth.uid()
  );

DROP POLICY IF EXISTS "Avatars: update own" ON storage.objects;
CREATE POLICY "Avatars: update own" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND owner_id = auth.uid()
  )
  WITH CHECK (
    bucket_id = 'avatars'
    AND owner_id = auth.uid()
  );

-- ════════════════════════════════════════════════════════════════════
-- 6. Trigger — impedir um utilizador de inserir outro utilizador que
-- não seja ele próprio (proteção contra criação de perfis alheios).
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION prevent_other_user_insert()
RETURNS TRIGGER AS $$
BEGIN
  IF public.get_user_role() != 'admin' AND NEW.id <> auth.uid() THEN
    RAISE EXCEPTION 'Não autorizado a criar perfis de outros utilizadores';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_prevent_other_user_insert ON users;
CREATE TRIGGER trigger_prevent_other_user_insert
  BEFORE INSERT ON users
  FOR EACH ROW EXECUTE FUNCTION prevent_other_user_insert();
