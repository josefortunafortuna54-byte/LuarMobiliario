-- Migration 025: Otimização de queries (T-039)
--
-- A base já tem índices simples (city, price, type, created_at, ...). Esta
-- migração adiciona índices compostos/parciais orientados às queries reais da
-- app: listagens públicas (is_available = true + ordenação/filtros) e consultas
-- frequentes de mensagens, notificações e admin/analytics.

-- ════════════════════════════════════════════════════════════════════════
-- 1. Listagens públicas (is_available filtrado + ordenação por data)
-- ════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_properties_available_created
  ON public.properties (created_at DESC) WHERE is_available = true;
CREATE INDEX IF NOT EXISTS idx_lands_available_created
  ON public.lands (created_at DESC) WHERE is_available = true;

-- Filtros combinados mais usados na pesquisa
CREATE INDEX IF NOT EXISTS idx_properties_available_type
  ON public.properties (type, created_at DESC) WHERE is_available = true;
CREATE INDEX IF NOT EXISTS idx_properties_available_transaction
  ON public.properties (transaction_type, created_at DESC) WHERE is_available = true;
CREATE INDEX IF NOT EXISTS idx_properties_available_city
  ON public.properties (city, created_at DESC) WHERE is_available = true;
CREATE INDEX IF NOT EXISTS idx_lands_available_type
  ON public.lands (type, created_at DESC) WHERE is_available = true;
CREATE INDEX IF NOT EXISTS idx_lands_available_transaction
  ON public.lands (transaction_type, created_at DESC) WHERE is_available = true;
CREATE INDEX IF NOT EXISTS idx_lands_available_city
  ON public.lands (city, created_at DESC) WHERE is_available = true;

-- Destaques da Home / landing page
CREATE INDEX IF NOT EXISTS idx_properties_featured_available
  ON public.properties (created_at DESC)
  WHERE is_available = true AND is_featured = true;
CREATE INDEX IF NOT EXISTS idx_lands_featured_available
  ON public.lands (created_at DESC)
  WHERE is_available = true AND is_featured = true;

-- ════════════════════════════════════════════════════════════════════════
-- 2. Mensagens — conversas e caixa de entrada
-- ════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_messages_sender_receiver_created
  ON public.messages (sender_id, receiver_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_created
  ON public.messages (receiver_id, created_at DESC);

-- ════════════════════════════════════════════════════════════════════════
-- 3. Notificações não lidas / avaliações por utilizador
-- ════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
  ON public.notifications (user_id, created_at DESC) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_reviews_user_id
  ON public.reviews (user_id);

-- ════════════════════════════════════════════════════════════════════════
-- 4. Admin / analytics — utilizadores recentes por papel
-- ════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_users_created_at
  ON public.users (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_users_role
  ON public.users (role);
