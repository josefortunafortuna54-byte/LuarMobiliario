-- ════════════════════════════════════════════════════════════════════════
-- 027 — SEGUIDORES DO PERFIL
-- A policy "read own" da tabela `favorites` impede o agente de ler os
-- favoritos de terceiros; para mostrar "Seguidores" no perfil expomos
-- um agregado (nº distinto de utilizadores que guardaram qualquer
-- anúncio do agente) via RPC SECURITY DEFINER, sem revelar quem favoritou
-- o quê.
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.agent_audience(p_agent_id UUID)
RETURNS BIGINT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT count(DISTINCT f.user_id)::BIGINT
  FROM public.favorites f
  LEFT JOIN public.properties p ON p.id = f.property_id
  LEFT JOIN public.lands l ON l.id = f.land_id
  WHERE p.agent_id = p_agent_id OR l.agent_id = p_agent_id;
$$;

REVOKE ALL ON FUNCTION public.agent_audience(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.agent_audience(UUID) TO anon, authenticated;
