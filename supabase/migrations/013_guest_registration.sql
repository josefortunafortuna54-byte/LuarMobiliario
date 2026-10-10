-- Migration 013: Registo automático do cliente após a marcação
-- O login/criação de conta foi removido. Após uma marcação de visitante
-- (user_id nulo), a app regista o cliente na tabela users pedindo apenas
-- nome + telefone, e liga a marcação ao novo utilizador.
--
--   1. RPC register_guest_client (SECURITY DEFINER) cria o perfil em users
--      com email sintético (não usado para login) e liga a marcação.
--   2. O trigger prevent_other_user_insert passa a permitir estes perfis
--      criados pela RPC (email no domínio @guest.luar), que não têm auth.uid().

-- Email sintético: o cliente não tem email real (login removido). O domínio
-- @guest.luar identifica perfis criados por marcação e usados só para gestão.
CREATE OR REPLACE FUNCTION public.is_guest_profile_email(p_email TEXT)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT p_email LIKE '%@guest.luar';
$$;

-- Cria o perfil do cliente (nome + telefone) e liga a marcação de visitante.
CREATE OR REPLACE FUNCTION public.register_guest_client(
  p_name TEXT,
  p_phone TEXT,
  p_booking_id UUID
)
RETURNS public.users
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_phone   TEXT;
  v_email   TEXT;
  v_user    public.users;
BEGIN
  IF length(trim(COALESCE(p_name, ''))) < 3 THEN
    RAISE EXCEPTION 'Nome demasiado curto';
  END IF;

  v_phone := regexp_replace(COALESCE(p_phone, ''), '[^0-9+]', '', 'g');
  IF length(v_phone) < 9 THEN
    RAISE EXCEPTION 'Telefone inválido';
  END IF;

  -- Email sintético único (o cliente nunca usa login).
  v_email := 'guest_' || replace(uuid_generate_v4()::text, '-', '') || '@guest.luar';

  INSERT INTO public.users (id, name, email, phone, role, created_at, updated_at)
  VALUES (uuid_generate_v4(), trim(p_name), v_email, v_phone, 'client', NOW(), NOW())
  RETURNING * INTO v_user;

  -- Ligar a marcação de visitante ao utilizador criado.
  IF p_booking_id IS NOT NULL THEN
    UPDATE public.bookings
    SET user_id    = v_user.id,
        user_name  = trim(p_name),
        user_phone = v_phone
    WHERE id = p_booking_id
      AND user_id IS NULL;
  END IF;

  RETURN v_user;
END;
$$;

REVOKE ALL ON FUNCTION public.register_guest_client(TEXT, TEXT, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.register_guest_client(TEXT, TEXT, UUID) TO anon, authenticated;

-- Permitir que a RPC crie perfis de visitantes (sem auth.uid()).
CREATE OR REPLACE FUNCTION public.prevent_other_user_insert()
RETURNS TRIGGER AS $$
BEGIN
  IF public.is_guest_profile_email(NEW.email) THEN
    RETURN NEW;
  END IF;
  IF public.get_user_role() != 'admin' AND NEW.id <> auth.uid() THEN
    RAISE EXCEPTION 'Não autorizado a criar perfis de outros utilizadores';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;