-- Migration 024: Integridade ao apagar utilizadores
--
-- Corrige dois problemas descobertos nos testes de escrita:
--
-- 1. public.users.id não tinha qualquer foreign key para auth.users. Ao apagar
--    um utilizador (Admin API / auth.admin.deleteUser), o perfil em public.users
--    ficava órfão — e como public.users.email é UNIQUE, impedia novo registo com
--    o mesmo email. Esta migração adiciona a FK com ON DELETE CASCADE.
--
-- 2. A aplicação apagava utilizadores via `auth.admin.deleteUser`, que exige a
--    service_role key (indisponível no cliente). Substitui-se por um RPC
--    SECURITY DEFINER `public.delete_user(uuid)` que verifica o papel de admin e
--    apaga de auth.users (cascade para public.users e restantes tabelas).

-- ════════════════════════════════════════════════════════════════════════
-- 1. Limpar perfis órfãos (sem utilizador correspondente em auth.users)
-- ════════════════════════════════════════════════════════════════════════

DELETE FROM public.users p
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users u WHERE u.id = p.id
);

-- ════════════════════════════════════════════════════════════════════════
-- 2. FK public.users.id -> auth.users.id com ON DELETE CASCADE
-- ════════════════════════════════════════════════════════════════════════

ALTER TABLE public.users
  DROP CONSTRAINT IF EXISTS users_id_auth_fkey;

ALTER TABLE public.users
  ADD CONSTRAINT users_id_auth_fkey
  FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- ════════════════════════════════════════════════════════════════════════
-- 3. RPC — apagar utilizador (apenas admins)
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.delete_user(p_user_id UUID)
RETURNS void AS $$
BEGIN
  IF public.get_user_role() <> 'admin' THEN
    RAISE EXCEPTION 'Apenas administradores podem apagar utilizadores';
  END IF;

  IF p_user_id = auth.uid() THEN
    RAISE EXCEPTION 'Não é possível apagar a própria conta';
  END IF;

  DELETE FROM auth.users WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.delete_user(UUID) TO authenticated;
