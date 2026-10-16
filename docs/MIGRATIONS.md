# Guia de Migrações

Como aplicar as migrações SQL ao projeto Supabase de produção.

As migrações vivem em `luar_company/supabase/migrations/` e são aplicadas **por ordem** (`001` → `026`). São idempotentes na sua maioria (`IF NOT EXISTS`, `DROP POLICY IF EXISTS`), pelo que reaplicar é seguro.

> O projeto já está ligado (`supabase link`) ao ref `vgwaxjxkknogmwnmuiux`; o pipe `.env`/CLI usa a ligação guardada.

---

## Estado

Todas as migrações (`001`–`026`) estão aplicadas e em sync com o projeto de produção (`vgwaxjxkknogmwnmuiux`), confirmado por `supabase migration list --linked`. As últimas aplicadas foram:

| Migration | Ficheiro | O que faz | Estado |
|---|---|---|---|
| 015 | `015_fix_bookings_target_and_rls.sql` | Adiciona `bookings.land_id` (agendar terrenos), torna `property_id` opcional com `CHECK` de alvo único, e corrige as policies de `SELECT`/`UPDATE` para agentes/admins gerirem marcações | Aplicada |
| 016 | `016_add_property_land_videos.sql` | Cria `property_videos` / `land_videos`, o bucket `property-videos` (50 MB) e as respetivas policies RLS | Aplicada |
| 017 | `017_fix_storage_delete_policies_owner_cast.sql` | Recria as policies de DELETE de `property-images`/`avatars` com `owner_id::text` (o `owner_id` do storage é TEXT e as policies da 007 comparavam com uuid) | Aplicada |
| 018 | `018_security_trust_foundation.sql` | Base de segurança/confiança: remove leitura anónima de marcações de convidados (PII) e de NIF de parceiros, restringe upload de media a agentes/admins, limita `send_notification`, valida posse no `register_guest_client` e adiciona `province` a properties/lands | Aplicada |
| 019 | `019_device_tokens.sql` | Cria a tabela dedicada `device_tokens` (o token FCM era gravado em `notifications`, sem chave única, falhando o upsert) | Aplicada |
| 020 | `020_saved_searches.sql` | Cria `saved_searches` — snapshot dos filtros de pesquisa por utilizador | Aplicada |
| 021 | `021_rls_app_fixes.sql` | Correções RLS app↔BD: view `users_public` sem PII, contagens de favoritos e proteção de verificação | Aplicada |
| 022 | `022_reviews.sql` | Cria `reviews` — avaliações de imóveis (1–5 estrelas + comentário), uma por utilizador | Aplicada |
| 023 | `023_restore_handle_new_user_trigger.sql` | Restaura o trigger `handle_new_user` (perfil em `public.users` no signup), ausente em produção | Aplicada |
| 024 | `024_user_delete_integrity.sql` | Adiciona FK `public.users.id → auth.users` com `ON DELETE CASCADE` (evita perfis órfãos e bloqueio de novo registo com o mesmo email) | Aplicada |
| 025 | `025_query_optimization.sql` | Índices compostos/parciais para listagens públicas, mensagens, notificações e admin/analytics | Aplicada |
| 026 | `026_analytics_views.sql` | Adiciona `views` a properties/lands e o RPC `register_listing_view` para métricas de anúncios mais vistos | Aplicada |

> Sem a 015: agendar visita a um **terreno** falha e o admin não confirma/cancela marcações.
> Sem a 016: **publicação de vídeos falha** (tabelas e bucket inexistentes).
> Sem a 017: apagar **imagens de imóvel** ou **avatares** pode falhar (`operator does not exist: text = uuid`).
> Sem a 019: a entrega de **notificações push** pode falhar silenciosamente.
> Sem a 023: novos registos ficam sem perfil em `public.users`.
> Sem a 024: perfis órfãos impedem novo registo com o mesmo email.

### Dependências

As migrações 015/016 assumem o schema já aplicado (001–014), em particular:

- função `public.get_user_role()` — migrations 002/006
- tabelas `properties` e `lands` — migrations 001/003

> **Nota sobre UUIDs:** a extensão `uuid-ossp` vive no schema `extensions` e `uuid_generate_v4()` não resolve durante as migrações. Use `gen_random_uuid()` (nativo do PostgreSQL, sempre resolvível), como nas migrations 014 e 016.

---

## Método A — Supabase CLI (recomendado)

```bash
# 1. Instalar a CLI (se necessário)
npm install -g supabase

# 2. Autenticar
supabase login

# 3. Ligar ao projeto de produção (dentro de luar_company/)
supabase link --project-ref <PROJECT_REF>

# 4. Ver o que será aplicado (sem alterar nada)
supabase migration list --linked

# 5. Aplicar as migrações pendentes
supabase db push
```

`supabase db push` aplica apenas as migrações ainda não registadas em `supabase_migrations.schema_migrations`.

`PROJECT_REF` é o identificador do projeto (Dashboard → Settings → General → Reference ID), também visível no URL `https://<PROJECT_REF>.supabase.co`.

---

## Método B — SQL Editor (sem CLI)

1. Abra o projeto em [supabase.com/dashboard](https://supabase.com/dashboard) → **SQL Editor**.
2. Cole e execute o conteúdo de cada ficheiro de `supabase/migrations/` ainda **não** aplicado (comece no primeiro em falta).
3. Repita para cada migração seguinte, por ordem numérica.

> Execute sempre pela ordem numérica. Cada ficheiro é transacional quando executado num único lote.

---

## Verificação

Após aplicar, confirme no **SQL Editor**:

```sql
-- 015: coluna land_id e CHECK do alvo
SELECT column_name, is_nullable
FROM information_schema.columns
WHERE table_name = 'bookings' AND column_name IN ('property_id', 'land_id');

-- 016: tabelas e bucket
SELECT to_regclass('public.property_videos') AS property_videos,
       to_regclass('public.land_videos')     AS land_videos;

SELECT id, public, file_size_limit, allowed_mime_types
FROM storage.buckets WHERE id = 'property-videos';
```

Resultado esperado: `property_id` anulável, `land_id` presente, as duas tabelas existentes e o bucket `property-videos` público com limite `52428800`.

Teste funcional (na app): criar um imóvel/terreno **com vídeo**, e agendar uma visita a um **terreno** — ambos devem concluir sem erro.

---

## Rollback

Se necessário reverter a 016:

```sql
DROP TABLE IF EXISTS property_videos;
DROP TABLE IF EXISTS land_videos;
DELETE FROM storage.buckets WHERE id = 'property-videos';
```

A 015 só deve ser revertida em último recurso (remove `land_id` e restaura as policies anteriores definidas na migration 007).
