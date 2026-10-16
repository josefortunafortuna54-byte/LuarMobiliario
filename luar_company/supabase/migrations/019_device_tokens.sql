-- Migration 019: tokens FCM por dispositivo
-- A entrega push falhava porque o token era gravado na tabela `notifications`
-- (sem chave única e com `title` NOT NULL), pelo que o upsert do cliente
-- falhava silenciosamente. Passa a existir uma tabela dedicada `device_tokens`.

CREATE TABLE IF NOT EXISTS public.device_tokens (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  token      TEXT NOT NULL,
  platform   TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT device_tokens_token_unique UNIQUE (token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON public.device_tokens(user_id);

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Device tokens: read own or admin" ON public.device_tokens;
CREATE POLICY "Device tokens: read own or admin" ON public.device_tokens
  FOR SELECT USING (
    auth.uid() = user_id OR public.get_user_role() = 'admin'
  );

DROP POLICY IF EXISTS "Device tokens: insert own" ON public.device_tokens;
CREATE POLICY "Device tokens: insert own" ON public.device_tokens
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Device tokens: update own" ON public.device_tokens;
CREATE POLICY "Device tokens: update own" ON public.device_tokens
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Device tokens: delete own" ON public.device_tokens;
CREATE POLICY "Device tokens: delete own" ON public.device_tokens
  FOR DELETE USING (auth.uid() = user_id OR public.get_user_role() = 'admin');
