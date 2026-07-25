-- Migration 006: Reforçar RLS admin-only na tabela users
-- Garante que só admins podem alterar função/remover utilizadores

-- Remover TODAS as policies existentes na tabela users (nomes variam entre PT/EN)
DO $$ DECLARE
  pol record;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'users' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON users', pol.policyname);
  END LOOP;
END $$;

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
CREATE POLICY "Users: update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- 3. Admins têm acesso TOTAL a todos os utilizadores
CREATE POLICY "Users: admin full access" ON users
  FOR ALL USING (public.get_user_role() = 'admin');

-- 4. Trigger: impedir que não-admins alterem o campo role
CREATE OR REPLACE FUNCTION prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
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
