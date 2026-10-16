-- Migration 008: Notifications tokens (FCM)
-- Alinha a tabela notifications com o NotificationService.saveTokenToDatabase,
-- que regista fcm_token por utilizador na tabela notifications.

-- 1. Colunas fcm_token + updated_at em notifications
ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS fcm_token TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- 2. Trigger para manter updated_at atualizado
DO $$ BEGIN
  CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- 3. Índice para lookup de token por utilizador
CREATE INDEX IF NOT EXISTS idx_notifications_fcm_token ON public.notifications(user_id, fcm_token) WHERE fcm_token <> '';