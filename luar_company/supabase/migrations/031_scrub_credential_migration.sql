-- Migration 031: remover o hash da palavra-passe do historico de migracoes
--
-- O CLI da Supabase guarda o SQL completo de cada migracao aplicada na tabela
-- supabase_migrations.schema_migrations (coluna statements, do tipo text[]).
-- A migration 030 (definicao pontual das credenciais do administrador) foi
-- executada com o hash bcrypt da palavra-passe, pelo que esse hash ficou
-- retido nessa tabela para alem de auth.users.encrypted_password.
--
-- Esta migration substitui as statements registadas da 030 por um placeholder:
-- o hash passa a existir apenas onde deve estar, em auth.users.encrypted_password.
-- Nao altera dados, funcoes, tabelas ou politicas.

update supabase_migrations.schema_migrations
   set statements = array[
         '-- 030: definicao pontual das credenciais do administrador (2026-10-22). '
         || 'Hash da palavra-passe removido do historico de migracoes pela 031.'
       ]
 where version = '030';
