-- ════════════════════════════════════════════════════════════════════════
-- Luar Company — Definir passe de acesso (6 dígitos) do administrador
-- ════════════════════════════════════════════════════════════════════════
-- Correr UMA VEZ no SQL Editor do Supabase (Dashboard → SQL Editor).
-- Este ficheiro NÃO é uma migration (não é aplicado por `supabase db push`),
-- para não repor a passe a cada deploy.
--
-- ALTERA o email e a passe antes de correr.
-- ════════════════════════════════════════════════════════════════════════

do $$
declare
  v_email text := 'josefortunafortuna54@gmail.com';
  v_pass  text := '123456';
  v_user_id uuid;
begin
  -- 1) O perfil tem de existir em public.users
  select id into v_user_id from public.users where email = v_email;
  if v_user_id is null then
    raise exception 'Nao existe utilizador % na tabela public.users', v_email;
  end if;

  -- 2) Criar (ou atualizar) o utilizador em auth.users com o MESMO id do perfil,
  --    password = passe de 6 dígitos e email confirmado (sem enviar email).
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data
  )
  values (
    '00000000-0000-0000-0000-000000000000',
    v_user_id,
    'authenticated',
    'authenticated',
    v_email,
    extensions.crypt(v_pass, extensions.gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('name', (select name from public.users where id = v_user_id))
  )
  on conflict (id) do update set
    email              = excluded.email,
    encrypted_password = extensions.crypt(v_pass, extensions.gen_salt('bf')),
    email_confirmed_at = coalesce(auth.users.email_confirmed_at, now()),
    updated_at         = now();

  -- 3) Garantir a identidade 'email' (algumas versões do GoTrue exigem-na)
  insert into auth.identities (
    id, user_id, provider_id, identity_data, provider,
    last_sign_in_at, created_at, updated_at
  )
  select
    gen_random_uuid(), v_user_id, v_user_id::text,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email),
    'email', now(), now(), now()
  where not exists (
    select 1 from auth.identities
    where user_id = v_user_id and provider = 'email'
  );

  raise notice 'Passe de 6 digitos definida para %', v_email;
end $$;
