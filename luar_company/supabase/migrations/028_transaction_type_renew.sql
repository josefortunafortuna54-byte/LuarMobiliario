-- ════════════════════════════════════════════════════════════════════════
-- 028 — TIPO DE TRANSAÇÃO "RENEW" (separador "Renovar" dos filtros)
-- O design de referência mostra três separadores em Filtros:
-- Comprar | Arrendar | Renovar. A enum só continha ('sale','rent'),
-- pelo que se acrescenta 'renew' (valor aditivo; linhas existentes
-- não são afetadas e o novo valor não é usado nesta transação).
-- ════════════════════════════════════════════════════════════════════════

ALTER TYPE public.transaction_type ADD VALUE IF NOT EXISTS 'renew';
