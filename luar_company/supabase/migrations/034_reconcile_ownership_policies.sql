-- Migration 034: reconcilia as policies de posse de imagens e de atualização
-- de imóveis/terrenos em produção
--
-- Contexto: a migration 007 que a produção executou era uma versão anterior
-- (a mesma que continha OLD/NEW e foi corrigida em fresco). As policies de
-- gestão de imagens nasceram em 002 sem qualquer verificação de posse e a 007
-- passou a limitá-las ao anúncio do próprio agente — mas essa alteração nunca
-- chegou à produção, que ficou com a versão de 002:
--   "Property images: agents and admins manage" → USING (role IN ('agent','admin'))
--   "Land images: agents and admins manage"    → USING (role IN ('agent','admin'))
-- Ou seja, em produção qualquer agente podia alterar ou apagar as imagens de
-- announcements de outros agentes.
--
-- Esta migration volta a aplicar as definições da 007 (o estado final
-- pretendido pela cadeia). As policies de UPDATE de properties/lands também
-- são recriadas com o WITH CHECK explícito da 007, para que a produção e a
-- cadeia fiquem idênticas.
--
-- Idempotente: DROP POLICY IF EXISTS torna-a um no-op numa base nova.

-- ════════════════════════════════════════════════════════════════════════
-- 1. IMAGENS — o agente gere apenas as imagens dos seus próprios anúncios
-- ════════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Property images: agents and admins manage" ON property_images;
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
-- 2. UPDATE de imóveis/terrenos — o agente não pode transferir a posse
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
-- 3. ÍNDICES de bookings — a 007 cria-os, mas a versão executada em produção
--    não os tinha; o dump de produção não os contém. Recriam-se aqui.
-- ════════════════════════════════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_bookings_user_created ON bookings(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bookings_property_status ON bookings(property_id, status);
