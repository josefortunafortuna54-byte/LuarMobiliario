-- Migration 030 (operacional, one-off): credenciais do administrador
--
-- ATENCAO: este ficheiro e um NO-OP intencional. A definicao das credenciais
-- do administrador (email -> luarcompany@gmail.com e nova palavra-passe) foi
-- executada em 2026-10-22 directamente na base de dados, e o registo 030 que
-- ficou no historico remoto guardava o hash da palavra-passe. A migration 031
-- removeu esse hash do historico (supabase_migrations.schema_migrations).
--
-- Este ficheiro existe apenas para manter o historico de migracoes alinhado
-- entre o repositorio e a base de dados: sem ele, `supabase db push` aborta com
-- "Remote migration versions not found in local migrations directory".
--
-- Regra (igual a supabase/set_admin_passcode.sql): definicao de credenciais
-- NAO e migracao de schema e nunca deve ficar em claro neste ficheiro.
-- Para alterar credenciais, usar o SQL Editor com supabase/set_admin_passcode.sql.

do $$
begin
  -- no-op intencional: nao altera nada
  null;
end $$;
