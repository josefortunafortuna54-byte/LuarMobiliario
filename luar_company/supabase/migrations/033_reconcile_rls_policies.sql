-- Migration 033: reconcilia as policies de RLS de produção com a cadeia de migrations
--
-- Contexto: as migrations 002 e 007 foram editadas depois de já estarem aplicadas
-- em produção. O CLI regista version+name e nunca volta a executar uma migration
-- já aplicada, pelo que os DROP POLICY dessas versões nunca correram em
-- produção: ficou lá o conjunto legacy da migration 001 ("X read for anon" com
-- USING (true) e "X all for authenticated" com FOR ALL). Efeito em produção:
--   - qualquer visitante anónimo lia todas as mensagens e todos os agendamentos;
--   - qualquer conta autenticada (mesmo um cliente) podia escrever ou apagar
--     qualquer linha de properties, lands, messages, bookings, notifications,
--     property_images, land_images, categories e locations;
--   - qualquer visitante anónimo lia todas as linhas de users (email, telefone).
--
-- Esta migration volta a aplicar o estado final pretendido pela cadeia
-- (002 + 007 + 021): remove as policies legacy e recria as policies de "users"
-- que faltam. Os substitutos granulares já existem em produção:
--   - "X: public read"          → leitura anónima de listagens (002, 005, 018)
--   - "X: read own" / "own or agent" / "own or admin" → leitura por dono
--   - "X: admin manage" / "agents and admins manage" → escrita restrita
-- A leitura pública de dados de agente sem PII continua disponível pela view
-- public.users_public (id, name, avatar_url, role, verified, verified_at).
--
-- Idempotente: DROP POLICY IF EXISTS torna-a um no-op numa base nova (onde a
-- cadeia já produz o estado final) e a reconciliação em produção.

-- ════════════════════════════════════════════════════════════════════════
-- 1. BOOKINGS — leitura só do dono/agente, escrita por dono ou guest
-- ════════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Bookings all for authenticated" ON bookings;
DROP POLICY IF EXISTS "Bookings read for anon" ON bookings;

-- ════════════════════════════════════════════════════════════════════════
-- 2. MESSAGES — leitura só das conversas do próprio utilizador
-- ════════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Messages all for authenticated" ON messages;
DROP POLICY IF EXISTS "Messages read for anon" ON messages;

-- ════════════════════════════════════════════════════════════════════════
-- 3. NOTIFICATIONS — leitura só das próprias notificações
-- ════════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Notifications all for authenticated" ON notifications;
DROP POLICY IF EXISTS "Notifications read for anon" ON notifications;

-- ════════════════════════════════════════════════════════════════════════
-- 4. PROPERTIES / LANDS — escrita restrita ao agente dono ou admin
-- ════════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Properties all for authenticated" ON properties;
DROP POLICY IF EXISTS "Properties read for anon" ON properties;

DROP POLICY IF EXISTS "Lands all for authenticated" ON lands;
DROP POLICY IF EXISTS "Lands read for anon" ON lands;

-- ════════════════════════════════════════════════════════════════════════
-- 5. IMAGENS — escrita restrita ao agente dono ou admin
-- ════════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Property images all for authenticated" ON property_images;
DROP POLICY IF EXISTS "Property images read for anon" ON property_images;

DROP POLICY IF EXISTS "Land images all for authenticated" ON land_images;
DROP POLICY IF EXISTS "Land images read for anon" ON land_images;

-- ════════════════════════════════════════════════════════════════════════
-- 6. CATEGORIES / LOCATIONS — escrita restrita ao admin
-- ════════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Categories all for authenticated" ON categories;
DROP POLICY IF EXISTS "Categories read for anon" ON categories;

DROP POLICY IF EXISTS "Locations all for authenticated" ON locations;
DROP POLICY IF EXISTS "Locations read for anon" ON locations;

-- ════════════════════════════════════════════════════════════════════════
-- 7. USERS — leitura só do próprio ou admin; inserção do próprio perfil
-- (o trigger prevent_other_user_insert continua a impedir perfis alheios)
-- ════════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Users: public read" ON users;

DROP POLICY IF EXISTS "Users: read own or admin" ON users;
CREATE POLICY "Users: read own or admin" ON users
  FOR SELECT USING (
    auth.uid() = id OR public.get_user_role() = 'admin'
  );

DROP POLICY IF EXISTS "Users: insert own" ON users;
CREATE POLICY "Users: insert own" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);
