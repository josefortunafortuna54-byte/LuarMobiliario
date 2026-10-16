-- Migration 014: Corrige o RPC de registo de clientes (guest)
-- A migration 013 criava o perfil com uuid_generate_v4(), mas a função tem
-- SET search_path = public e a extensão uuid-ossp vive no schema `extensions`
-- (padrão do Supabase), pelo que a chamada falhava em runtime com
-- "function uuid_generate_v4() does not exist".
--
-- gen_random_uuid() é nativo do PostgreSQL (pg_catalog) e resolve sempre,
-- independentemente do search_path.

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
  v_email := 'guest_' || replace(gen_random_uuid()::text, '-', '') || '@guest.luar';

  INSERT INTO public.users (id, name, email, phone, role, created_at, updated_at)
  VALUES (gen_random_uuid(), trim(p_name), v_email, v_phone, 'client', NOW(), NOW())
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
