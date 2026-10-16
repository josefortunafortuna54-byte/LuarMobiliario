-- Migration 018: base de segurança e confiança (Trust)
-- Corrige riscos identificados na auditoria e prepara as fases 3/5 do plano:
--   1. bookings  — remove leitura anónima de marcações de convidados (PII)
--   2. partners  — remove leitura pública de NIF/licença (expõe view pública)
--   3. storage   — restringe upload de imagens/vídeos a agentes/admins
--   4. send_notification — limita abuso (rate limit por destinatário)
--   5. register_guest_client — valida posse da marcação (telefone)
--   6. properties/lands — coluna `province` (filtro hierárquico Angola)
--   7. users — verificação de anunciante (`verified`) + sincronização
--   8. reports + moderation_log — moderação e registo de ações
-- Idempotente: pode ser reaplicada com segurança.

-- ════════════════════════════════════════════════════════════════════════
-- 0. Geografia: província em imóveis e terrenos
-- ════════════════════════════════════════════════════════════════════════

ALTER TABLE properties ADD COLUMN IF NOT EXISTS province TEXT NOT NULL DEFAULT '';
ALTER TABLE lands      ADD COLUMN IF NOT EXISTS province TEXT NOT NULL DEFAULT '';

-- Backfill: assume a província = cidade quando não definida (ex.: Luanda).
UPDATE properties SET province = city WHERE province = '' AND city <> '';
UPDATE lands      SET province = city WHERE province = '' AND city <> '';

CREATE INDEX IF NOT EXISTS idx_properties_province ON properties(province);
CREATE INDEX IF NOT EXISTS idx_lands_province ON lands(province);

-- ════════════════════════════════════════════════════════════════════════
-- 1. BOOKINGS — remover leitura anónima de marcações de convidados
-- A app passa a criar marcações de convidado via RPC SECURITY DEFINER
-- (create_guest_booking), que devolve apenas a marcação criada.
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Bookings: read own or agent" ON bookings;
CREATE POLICY "Bookings: read own or agent" ON bookings
  FOR SELECT USING (
    auth.uid() = user_id
    OR public.get_user_role() IN ('agent', 'admin')
  );

-- RPC de criação de marcação de convidado (sem conta).
CREATE OR REPLACE FUNCTION public.create_guest_booking(
  p_property_id UUID,
  p_land_id     UUID,
  p_user_name   TEXT,
  p_user_phone  TEXT,
  p_date        DATE,
  p_time        TIME,
  p_notes       TEXT
)
RETURNS public.bookings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_phone TEXT;
  v_row   public.bookings;
BEGIN
  IF ((p_property_id IS NOT NULL)::int + (p_land_id IS NOT NULL)::int) <> 1 THEN
    RAISE EXCEPTION 'A marcação deve apontar para um imóvel OU um terreno';
  END IF;

  IF length(trim(COALESCE(p_user_name, ''))) < 3 THEN
    RAISE EXCEPTION 'Nome demasiado curto';
  END IF;

  v_phone := regexp_replace(COALESCE(p_user_phone, ''), '[^0-9+]', '', 'g');
  IF length(v_phone) < 9 THEN
    RAISE EXCEPTION 'Telefone inválido';
  END IF;

  INSERT INTO public.bookings (
    property_id, land_id, user_id, user_name, user_phone,
    date, time, status, notes
  )
  VALUES (
    p_property_id, p_land_id, NULL, trim(p_user_name), v_phone,
    p_date, COALESCE(p_time, '10:00'), 'pending', COALESCE(p_notes, '')
  )
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

REVOKE ALL ON FUNCTION public.create_guest_booking(
  UUID, UUID, TEXT, TEXT, DATE, TIME, TEXT
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.create_guest_booking(
  UUID, UUID, TEXT, TEXT, DATE, TIME, TEXT
) TO anon, authenticated;

-- ════════════════════════════════════════════════════════════════════════
-- 2. register_guest_client — validar posse da marcação (telefone coincide)
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.register_guest_client(
  p_name TEXT,
  p_phone TEXT,
  p_booking_id UUID
)
RETURNS public.users
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_phone   TEXT;
  v_email   TEXT;
  v_user    public.users;
  v_booking public.bookings;
BEGIN
  IF length(trim(COALESCE(p_name, ''))) < 3 THEN
    RAISE EXCEPTION 'Nome demasiado curto';
  END IF;

  v_phone := regexp_replace(COALESCE(p_phone, ''), '[^0-9+]', '', 'g');
  IF length(v_phone) < 9 THEN
    RAISE EXCEPTION 'Telefone inválido';
  END IF;

  -- A marcação tem de existir, não ter dono e o telefone tem de coincidir.
  IF p_booking_id IS NOT NULL THEN
    SELECT * INTO v_booking FROM public.bookings WHERE id = p_booking_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Marcação não encontrada';
    END IF;
    IF v_booking.user_id IS NOT NULL THEN
      RAISE EXCEPTION 'Marcação já associada a um utilizador';
    END IF;
    IF regexp_replace(COALESCE(v_booking.user_phone, ''), '[^0-9+]', '', 'g')
       <> v_phone THEN
      RAISE EXCEPTION 'Telefone não corresponde à marcação';
    END IF;
  END IF;

  v_email := 'guest_' || replace(gen_random_uuid()::text, '-', '') || '@guest.luar';

  INSERT INTO public.users (id, name, email, phone, role, created_at, updated_at)
  VALUES (gen_random_uuid(), trim(p_name), v_email, v_phone, 'client', NOW(), NOW())
  RETURNING * INTO v_user;

  IF p_booking_id IS NOT NULL THEN
    UPDATE public.bookings
    SET user_id = v_user.id
    WHERE id = p_booking_id AND user_id IS NULL;
  END IF;

  RETURN v_user;
END;
$$;

REVOKE ALL ON FUNCTION public.register_guest_client(TEXT, TEXT, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.register_guest_client(TEXT, TEXT, UUID) TO anon, authenticated;

-- ════════════════════════════════════════════════════════════════════════
-- 3. PARTNERS — deixar de expor NIF/licença publicamente (via view)
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Partners: public read" ON partners;

DROP POLICY IF EXISTS "Partners: read own" ON partners;
CREATE POLICY "Partners: read own" ON partners
  FOR SELECT USING (auth.uid() = user_id OR public.get_user_role() = 'admin');

-- View pública com apenas campos não sensíveis (nif e license omitidos).
-- Corre como owner (bypass RLS) para servir de diretório de empresas.
DROP VIEW IF EXISTS public.partners_public;
CREATE VIEW public.partners_public AS
  SELECT id, user_id, company_name, business_type, address, whatsapp,
         created_at, updated_at
  FROM public.partners;

GRANT SELECT ON public.partners_public TO anon, authenticated;

-- ════════════════════════════════════════════════════════════════════════
-- 4. STORAGE — uploads de imóveis/vídeos só por agentes/admins
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Property images: authenticated upload" ON storage.objects;
CREATE POLICY "Property images: authenticated upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'property-images'
    AND public.get_user_role() IN ('agent', 'admin')
  );

DROP POLICY IF EXISTS "Property videos: authenticated upload" ON storage.objects;
CREATE POLICY "Property videos: authenticated upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'property-videos'
    AND public.get_user_role() IN ('agent', 'admin')
  );

DROP POLICY IF EXISTS "Property images: update own" ON storage.objects;
CREATE POLICY "Property images: update own" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'property-images' AND owner_id::text = auth.uid()::text)
  WITH CHECK (bucket_id = 'property-images' AND owner_id::text = auth.uid()::text);

DROP POLICY IF EXISTS "Property videos: update own" ON storage.objects;
CREATE POLICY "Property videos: update own" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'property-videos' AND owner_id::text = auth.uid()::text)
  WITH CHECK (bucket_id = 'property-videos' AND owner_id::text = auth.uid()::text);

-- ════════════════════════════════════════════════════════════════════════
-- 5. send_notification — rate limit por destinatário (anti-spam)
-- ════════════════════════════════════════════════════════════════════════

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
DECLARE
  v_recent INT;
BEGIN
  IF public.get_user_role() NOT IN ('agent', 'admin')
     AND auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'Não autorizado a notificar este utilizador';
  END IF;

  IF length(COALESCE(p_title, '')) > 255 THEN
    RAISE EXCEPTION 'Título demasiado longo';
  END IF;
  IF length(COALESCE(p_body, '')) > 2000 THEN
    RAISE EXCEPTION 'Corpo demasiado longo';
  END IF;

  SELECT count(*) INTO v_recent
  FROM public.notifications
  WHERE user_id = p_user_id
    AND created_at > now() - interval '10 minutes';

  IF v_recent >= 20 THEN
    RAISE EXCEPTION 'Demasiadas notificações. Tente novamente mais tarde';
  END IF;

  INSERT INTO public.notifications (user_id, title, body)
  VALUES (p_user_id, p_title, COALESCE(p_body, ''));
END;
$$;

REVOKE ALL ON FUNCTION public.send_notification(UUID, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.send_notification(UUID, TEXT, TEXT) TO authenticated;

-- ════════════════════════════════════════════════════════════════════════
-- 6. USERS — verificação de anunciante + propagação para anúncios
-- ════════════════════════════════════════════════════════════════════════

ALTER TABLE users ADD COLUMN IF NOT EXISTS verified BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_note TEXT NOT NULL DEFAULT '';
ALTER TABLE users ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verified_by UUID REFERENCES users(id) ON DELETE SET NULL;

-- Coluna denormalizada nos anúncios para mostrar o badge sem joins públicos.
ALTER TABLE properties ADD COLUMN IF NOT EXISTS agent_verified BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE lands      ADD COLUMN IF NOT EXISTS agent_verified BOOLEAN NOT NULL DEFAULT false;

UPDATE properties p SET agent_verified = u.verified
  FROM users u WHERE p.agent_id = u.id;
UPDATE lands l SET agent_verified = u.verified
  FROM users u WHERE l.agent_id = u.id;

CREATE OR REPLACE FUNCTION public.sync_agent_verified()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.verified IS DISTINCT FROM OLD.verified THEN
    UPDATE public.properties SET agent_verified = NEW.verified WHERE agent_id = NEW.id;
    UPDATE public.lands      SET agent_verified = NEW.verified WHERE agent_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trigger_sync_agent_verified ON users;
CREATE TRIGGER trigger_sync_agent_verified
  AFTER UPDATE OF verified ON users
  FOR EACH ROW EXECUTE FUNCTION public.sync_agent_verified();

-- Impedir que o próprio utilizador altere o seu estado de verificação.
CREATE OR REPLACE FUNCTION public.prevent_self_verification()
RETURNS TRIGGER AS $$
BEGIN
  IF public.get_user_role() <> 'admin'
     AND NEW.verified IS DISTINCT FROM OLD.verified THEN
    RAISE EXCEPTION 'Apenas administradores podem alterar a verificação';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trigger_prevent_self_verification ON users;
CREATE TRIGGER trigger_prevent_self_verification
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION public.prevent_self_verification();

-- ════════════════════════════════════════════════════════════════════════
-- 7. REPORTS — denúncia de anúncios/utilizadores
-- ════════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  CREATE TYPE report_target AS ENUM ('property', 'land', 'user');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
  CREATE TYPE report_status AS ENUM ('pending', 'reviewing', 'resolved', 'dismissed');
EXCEPTION WHEN duplicate_object THEN null; END $$;

CREATE TABLE IF NOT EXISTS public.reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  target_type report_target NOT NULL,
  target_id   UUID NOT NULL,
  reason      TEXT NOT NULL,
  details     TEXT NOT NULL DEFAULT '',
  status      report_status NOT NULL DEFAULT 'pending',
  reviewed_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_target ON public.reports(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON public.reports(reporter_id);

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Reports: insert own" ON public.reports;
CREATE POLICY "Reports: insert own" ON public.reports
  FOR INSERT WITH CHECK (auth.uid() = reporter_id);

DROP POLICY IF EXISTS "Reports: read own or admin" ON public.reports;
CREATE POLICY "Reports: read own or admin" ON public.reports
  FOR SELECT USING (
    auth.uid() = reporter_id OR public.get_user_role() = 'admin'
  );

DROP POLICY IF EXISTS "Reports: admin manage" ON public.reports;
CREATE POLICY "Reports: admin manage" ON public.reports
  FOR UPDATE USING (public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════════
-- 8. MODERATION LOG — registo de ações de moderação
-- ════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.moderation_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id    UUID REFERENCES public.users(id) ON DELETE SET NULL,
  action      TEXT NOT NULL,
  target_type TEXT NOT NULL DEFAULT '',
  target_id   UUID,
  metadata    JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_moderation_log_actor ON public.moderation_log(actor_id);
CREATE INDEX IF NOT EXISTS idx_moderation_log_created ON public.moderation_log(created_at DESC);

ALTER TABLE public.moderation_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Moderation log: admin only" ON public.moderation_log;
CREATE POLICY "Moderation log: admin only" ON public.moderation_log
  FOR ALL USING (public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin');
