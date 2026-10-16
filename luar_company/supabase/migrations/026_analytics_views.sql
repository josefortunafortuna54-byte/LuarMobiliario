-- Migration 026: Analytics — contador de visualizações (T-045)
--
-- Adiciona um contador `views` a properties/lands e um RPC público
-- `register_listing_view` que incrementa de forma segura (SECURITY DEFINER),
-- permitindo métricas de "anúncios mais vistos" no painel de administração.

ALTER TABLE public.properties
  ADD COLUMN IF NOT EXISTS views INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.lands
  ADD COLUMN IF NOT EXISTS views INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_properties_views
  ON public.properties (views DESC);
CREATE INDEX IF NOT EXISTS idx_lands_views
  ON public.lands (views DESC);

-- Incrementa as visualizações de um anúncio. Chamável por anon (visitantes).
CREATE OR REPLACE FUNCTION public.register_listing_view(
  p_kind public.category_type,
  p_id UUID
)
RETURNS void AS $$
BEGIN
  IF p_kind = 'property' THEN
    UPDATE public.properties SET views = views + 1 WHERE id = p_id;
  ELSIF p_kind = 'land' THEN
    UPDATE public.lands SET views = views + 1 WHERE id = p_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

GRANT EXECUTE ON FUNCTION public.register_listing_view(public.category_type, UUID)
  TO anon, authenticated;
