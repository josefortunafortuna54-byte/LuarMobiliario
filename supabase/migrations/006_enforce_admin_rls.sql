-- Migration 006: Reforçar RLS admin-only na tabela users
-- Garante que só admins podem alterar função/remover utilizadores

-- Remover TODAS as policies existentes na tabela users
DROP POLICY IF EXISTS "Users read for anon" ON users;
DROP POLICY IF EXISTS "Users all for authenticated" ON users;
DROP POLICY IF EXISTS "Users: public read" ON users;
DROP POLICY IF EXISTS "Users: update own profile" ON users;
DROP POLICY IF EXISTS "Users: admin full access" ON users;
DROP POLICY IF EXISTS "Users: admin insert" ON users;

-- Função helper para obter role do utilizador atual
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ════════════════════════════════════════════════════════════════════
-- POLICIES RESTRITIVAS
-- ════════════════════════════════════════════════════════════════════

-- 1. Leitura pública (perfis de agentes, etc.)
CREATE POLICY "Users: public read" ON users
  FOR SELECT USING (true);

-- 2. Utilizadores só podem editar o PRÓPRIO perfil
--    (nome, telefone, avatar) — NUNCA a função/role
CREATE POLICY "Users: update own profile" ON users
  FOR UPDATE USING (
    auth.uid() = id
    AND (
      -- Só permite mudar campos de perfil, NÃO role
      -- O Supabase RLS não consegue filtrar colunas,
      -- mas o app já protege isso: o formulário de perfil
      -- não inclui campo role. A política impede UPDATEs
      -- de não-admins em geral, exceto o próprio perfil.
      true
    )
  );

-- 3. Admins têm acesso TOTAL a todos os utilizadores
--    (mudar função, remover, ver tudo)
CREATE POLICY "Users: admin full access" ON users
  FOR ALL USING (public.get_user_role() = 'admin');

-- 4. Trigger: impedir que não-admins alterem o campo role
CREATE OR REPLACE FUNCTION prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Se o utilizador atual NÃO é admin e tentou mudar a role
  IF public.get_user_role() != 'admin' AND OLD.role != NEW.role THEN
    RAISE EXCEPTION 'Apenas administradores podem alterar a função de utilizadores';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_prevent_role_change ON users;
CREATE TRIGGER trigger_prevent_role_change
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION prevent_role_change();
