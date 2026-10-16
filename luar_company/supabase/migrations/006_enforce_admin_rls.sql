-- Migration 006: Reforçar RLS admin-only na tabela users

-- Drop dinâmico via DO block (garante execução antes do CREATE)
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'users' AND schemaname = 'public')
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON users';
  END LOOP;
END $$;

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
