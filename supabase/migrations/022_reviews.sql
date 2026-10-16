-- Migration 022: avaliações de imóveis
-- Permite aos utilizadores autenticados avaliar (1-5 estrelas) um imóvel com
-- comentário. Cada utilizador pode avaliar um imóvel uma única vez (pode
-- depois atualizar ou remover a sua avaliação).

CREATE TABLE IF NOT EXISTS public.reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT NOT NULL DEFAULT '' CHECK (char_length(comment) <= 1000),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (property_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_property_id
  ON public.reviews(property_id, created_at DESC);

-- Resumo agregado por imóvel (média e nº de avaliações) para a listagem.
CREATE OR REPLACE VIEW public.property_review_summary AS
SELECT
  property_id,
  ROUND(AVG(rating)::numeric, 1) AS average_rating,
  COUNT(*)                       AS review_count
FROM public.reviews
GROUP BY property_id;

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Leitura pública das avaliações (como os anúncios são públicos).
DROP POLICY IF EXISTS "Reviews: public read" ON public.reviews;
CREATE POLICY "Reviews: public read" ON public.reviews
  FOR SELECT USING (true);

-- O utilizador autenticado cria, atualiza e remove as suas próprias avaliações.
DROP POLICY IF EXISTS "Reviews: own insert" ON public.reviews;
CREATE POLICY "Reviews: own insert" ON public.reviews
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Reviews: own update" ON public.reviews;
CREATE POLICY "Reviews: own update" ON public.reviews
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Reviews: own delete" ON public.reviews;
CREATE POLICY "Reviews: own delete" ON public.reviews
  FOR DELETE USING (auth.uid() = user_id);
