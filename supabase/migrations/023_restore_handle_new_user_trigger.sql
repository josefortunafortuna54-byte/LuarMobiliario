-- Migration 023: Restaurar o trigger handle_new_user (perfil em public.users no signup)
--
-- Contexto: a migration 007 define public.handle_new_user() e o trigger
-- on_auth_user_created em auth.users, mas estes objetos não existem no projeto
-- de produção (verificado via `supabase db dump` e por testes de signup em que
-- o auth.users é criado sem a linha correspondente em public.users).
--
-- Embora a aplicação compense com um upsert em public.users após o signup
-- (auth_service.dart), o trigger é o mecanismo documentado (docs/SUPABASE.md,
-- docs/DATABASE.md) e cobre caminhos que não passam pela app (ex.: criação de
-- utilizador via Admin API). Esta migração garante a sua (re)criação de forma
-- idempotente e faz backfill de eventuais utilizadores órfãos.

-- ════════════════════════════════════════════════════════════════════════
-- 1. Função — cria o perfil em public.users no signup
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, name, email, role, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Utilizador'),
    NEW.email,
    'client',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ════════════════════════════════════════════════════════════════════════
-- 2. Trigger — liga auth.users a public.users
-- ════════════════════════════════════════════════════════════════════════

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ════════════════════════════════════════════════════════════════════════
-- 3. Backfill — perfis em falta para utilizadores auth existentes
-- ════════════════════════════════════════════════════════════════════════

INSERT INTO public.users (id, name, email, role, created_at, updated_at)
SELECT
  u.id,
  COALESCE(u.raw_user_meta_data->>'name', 'Utilizador'),
  u.email,
  'client',
  COALESCE(u.created_at, NOW()),
  NOW()
FROM auth.users u
LEFT JOIN public.users p ON p.id = u.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;
