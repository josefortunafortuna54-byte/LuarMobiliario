-- Migration 032: favoritos — RLS estrito e suporte a `upsert`.
-- Idempotente: pode ser reaplicada com segurança.
--
-- Problema: a tabela `favorites` mantinha as policies legacy da 001/002
-- ("Favorites read for anon" e "Favorites all for authenticated") em
-- conjunto com as policies próprias. As legacy eram permissivas: qualquer
-- visitante anónimo lia todos os favoritos de todos os utilizadores e
-- qualquer conta autenticada podia escrever em qualquer linha.
--
-- Esta migration:
--   1. remove as policies legacy permissivas;
--   2. mantém as policies "own" já existentes (read/insert/delete);
--   3. acrescenta a policy de UPDATE, necessária porque o `upsert` do
--      repositório usa ON CONFLICT DO UPDATE e isso exige permissão de
--      UPDATE sobre a linha em conflito;
--   4. acrescenta acesso total para admins.

-- ════════════════════════════════════════════════════════════════════════
-- 1. Remover policies legacy permissivas
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Favorites read for anon" ON public.favorites;
DROP POLICY IF EXISTS "Favorites all for authenticated" ON public.favorites;

-- ════════════════════════════════════════════════════════════════════════
-- 2. Policies "own" (recriadas para garantir o estado pretendido)
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Favorites: read own" ON public.favorites;
CREATE POLICY "Favorites: read own" ON public.favorites
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Favorites: insert own" ON public.favorites;
CREATE POLICY "Favorites: insert own" ON public.favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- O `upsert` do repositório (favorites_repository.add) resolve conflitos com
-- ON CONFLICT DO UPDATE — sem esta policy o upsert é recusado com
-- "permission denied for table favorites".
DROP POLICY IF EXISTS "Favorites: update own" ON public.favorites;
CREATE POLICY "Favorites: update own" ON public.favorites
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Favorites: delete own" ON public.favorites;
CREATE POLICY "Favorites: delete own" ON public.favorites
  FOR DELETE USING (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════════════════
-- 3. Admins — acesso total
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Favorites: admin all" ON public.favorites;
CREATE POLICY "Favorites: admin all" ON public.favorites
  FOR ALL USING (public.get_user_role() = 'admin');
