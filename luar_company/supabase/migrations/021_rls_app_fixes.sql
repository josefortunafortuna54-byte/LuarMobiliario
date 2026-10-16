-- Migration 021: correções de ligação app ↔ BD (leitura pública não-PII,
-- contagens de favoritos e proteção de verificação).
-- Idempotente: pode ser reaplicada com segurança.

-- ════════════════════════════════════════════════════════════════════════
-- 1. USERS_PUBLIC — view de leitura pública sem PII
-- A migration 007 previa "leitura pública de campos não-PII via uma VIEW
-- restrita" mas nunca a criou: o ecrã de mensagens (message_repository)
-- lê name/avatar_url de parceiros e recebia 0 linhas pela policy
-- "read own or admin". A view fica com os campos não sensíveis;
-- email/phone continuam protegidos pela policy da tabela.
-- (A view mantém o comportamento por omissão: invocada pelo role do
--  PostgREST, sem security_invoker, para expor só os campos da view.)
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW public.users_public AS
  SELECT id,
         name,
         avatar_url,
         role,
         verified,
         verified_at
  FROM public.users;

GRANT SELECT ON public.users_public TO anon, authenticated;

-- ════════════════════════════════════════════════════════════════════════
-- 2. FAVORITE_COUNTS — contagem pública de gostos por imóvel
-- A policy "Favorites: read own" (002) fazia o contador de gostos do
-- feed Discover devolver 0 para utilizadores anónimos. A RPC devolve
-- apenas agregados (sem expor quem favoritou o quê).
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.favorite_counts(p_property_ids UUID[])
RETURNS TABLE (property_id UUID, likes BIGINT)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT f.property_id, count(*)::BIGINT
  FROM public.favorites f
  WHERE f.property_id = ANY(p_property_ids)
  GROUP BY f.property_id;
$$;

REVOKE ALL ON FUNCTION public.favorite_counts(UUID[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.favorite_counts(UUID[]) TO anon, authenticated;

-- ════════════════════════════════════════════════════════════════════════
-- 3. REPORTS — permitir DELETE a admins (a 018 só criou INSERT/SELECT/UPDATE)
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Reports: admin delete" ON public.reports;
CREATE POLICY "Reports: admin delete" ON public.reports
  FOR DELETE USING (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════════
-- 4. USERS — proteger também os campos de moderação da verificação
-- O trigger da 018 só travava `verified`; `verification_note`,
-- `verified_at` e `verified_by` continuavam editáveis pelo próprio.
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.prevent_self_verification()
RETURNS TRIGGER AS $$
BEGIN
  IF public.get_user_role() <> 'admin' AND (
    NEW.verified IS DISTINCT FROM OLD.verified
    OR NEW.verification_note IS DISTINCT FROM OLD.verification_note
    OR NEW.verified_at IS DISTINCT FROM OLD.verified_at
    OR NEW.verified_by IS DISTINCT FROM OLD.verified_by
  ) THEN
    RAISE EXCEPTION 'Apenas administradores podem alterar a verificação';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
