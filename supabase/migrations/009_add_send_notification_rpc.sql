-- Migration 009: RPC send_notification
-- Usada pelo NotificationService.sendNotification (client.rpc('send_notification', ...)).
-- Regista uma notificação na tabela notifications para o utilizador destino.

CREATE OR REPLACE FUNCTION public.send_notification(
  p_user_id UUID,
  p_title TEXT,
  p_body TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.notifications (user_id, title, body)
  VALUES (p_user_id, p_title, COALESCE(p_body, ''));
END;
$$;

-- Permitir que qualquer utilizador autenticado invoque a RPC (o SECURITY DEFINER
-- insere em nome do service role; o destino é validado pela aplicação).
REVOKE ALL ON FUNCTION public.send_notification(UUID, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.send_notification(UUID, TEXT, TEXT) TO authenticated;