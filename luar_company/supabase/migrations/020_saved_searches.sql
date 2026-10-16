-- Migration 020: pesquisas guardadas
-- Guarda o conjunto de filtros da pesquisa por utilizador para reutilização
-- (Fase 3 do Documento.md). `filters` guarda o snapshot JSON dos filtros do
-- SearchProvider (query, tipo, localização, preço, área, quartos, ordenação).

CREATE TABLE IF NOT EXISTS public.saved_searches (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name       TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 60),
  filters    JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_saved_searches_user_id
  ON public.saved_searches(user_id, created_at DESC);

ALTER TABLE public.saved_searches ENABLE ROW LEVEL SECURITY;

-- Cada utilizador só vê, cria, renomeia e apaga as suas próprias pesquisas.
DROP POLICY IF EXISTS "Saved searches: own read" ON public.saved_searches;
CREATE POLICY "Saved searches: own read" ON public.saved_searches
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Saved searches: own insert" ON public.saved_searches;
CREATE POLICY "Saved searches: own insert" ON public.saved_searches
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Saved searches: own update" ON public.saved_searches;
CREATE POLICY "Saved searches: own update" ON public.saved_searches
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Saved searches: own delete" ON public.saved_searches;
CREATE POLICY "Saved searches: own delete" ON public.saved_searches
  FOR DELETE USING (auth.uid() = user_id);
