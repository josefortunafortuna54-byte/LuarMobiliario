-- Migration 006: Reforçar RLS admin-only na tabela users

-- Drop agressivo: todas as variantes possíveis de nomes de policies
DROP POLICY IF EXISTS "Users read for anon" ON users;
DROP POLICY IF EXISTS "Users all for authenticated" ON users;
DROP POLICY IF EXISTS "Users: public read" ON users;
DROP POLICY IF EXISTS "Users: update own profile" ON users;
DROP POLICY IF EXISTS "Users: admin full access" ON users;
DROP POLICY IF EXISTS "Users: admin insert" ON users;
DROP POLICY IF EXISTS "Users: leitura publica" ON users;
DROP POLICY IF EXISTS "Utilizadores: leitura publica" ON users;
DROP POLICY IF EXISTS "Utilizadores: update proprio perfil" ON users;
DROP POLICY IF EXISTS "Utilizadores: admin acesso total" ON users;
DROP POLICY IF EXISTS "Utilizadores: admin full access" ON users;

-- Função helper
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Policies
CREATE POLICY "Users: public read" ON users
  FOR SELECT USING (true);

CREATE POLICY "Users: update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users: admin full access" ON users
  FOR ALL USING (public.get_user_role() = 'admin');

-- Trigger
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
