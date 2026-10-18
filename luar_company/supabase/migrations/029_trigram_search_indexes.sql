-- Migration 029: índices trigram para as pesquisas ilike
--
-- As pesquisas da app usam `ilike '%valor%'` em province/city/municipality/
-- neighborhood e na pesquisa livre (title/description/address). Esses padrões
-- com curingas à esquerda não usam índices btree (a 025 já cobre filtros de
-- igualdade/ordenação), pelo que esta migração adiciona índices GIN com
-- pg_trgm para manter a pesquisa rápida à medida que o catálogo cresce.

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Localização (filtros da folha de filtros)
CREATE INDEX IF NOT EXISTS idx_properties_province_trgm
  ON public.properties USING gin (province gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_properties_municipality_trgm
  ON public.properties USING gin (municipality gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_properties_neighborhood_trgm
  ON public.properties USING gin (neighborhood gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_lands_province_trgm
  ON public.lands USING gin (province gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_lands_municipality_trgm
  ON public.lands USING gin (municipality gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_lands_neighborhood_trgm
  ON public.lands USING gin (neighborhood gin_trgm_ops);

-- Pesquisa livre (title/description/address) — usada por `search()`
CREATE INDEX IF NOT EXISTS idx_properties_title_trgm
  ON public.properties USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_properties_description_trgm
  ON public.properties USING gin (description gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_properties_address_trgm
  ON public.properties USING gin (address gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_lands_title_trgm
  ON public.lands USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_lands_description_trgm
  ON public.lands USING gin (description gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_lands_address_trgm
  ON public.lands USING gin (address gin_trgm_ops);
