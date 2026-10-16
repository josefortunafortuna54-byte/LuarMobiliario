# Configuração do Supabase

Guia completo de configuração do Supabase para a plataforma Luar Company Imobiliária.

---

## Visão Geral

O Supabase é a plataforma backend (BaaS) utilizada no projeto, fornecendo:

- **PostgreSQL** — Base de dados relacional
- **Supabase Auth** — Autenticação e gestão de utilizadores
- **Supabase Storage** — Armazenamento de ficheiros (imagens e vídeos)
- **Row Level Security (RLS)** — Autorização a nível de linha

> **Nota:** O schema SQL completo e atualizado está nas **migrations** em
> `luar_company/supabase/migrations/` (001 a 026) e resumido em `docs/DATABASE.md`.
> Este guia descreve a configuração do projeto e as boas práticas.

---

## Configuração do Projeto

### Criar Projeto no Supabase

1. Aceda a [supabase.com](https://supabase.com) e inicie sessão
2. Clique em "New Project"
3. Preencha:
   - **Organization**: Selecione ou crie uma organização
   - **Project name**: `luar-company`
   - **Database password**: Gere uma password forte
   - **Region**: Escolha a região mais próxima (Africa ou Europa)
4. Aguarde a criação do projeto
5. Anote o **Project URL** e **anon key** no painel Settings > API

### Variáveis de Ambiente

Copie o `.env.example` para `luar_company/.env` e preencha:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-aqui
FCM_SENDER_ID=seu-sender-id        # opcional
FCM_PROJECT_ID=seu-project-id      # opcional
```

**IMPORTANTE:**
- Nunca fazer commit do ficheiro `.env`
- Usar apenas a `anon` key no cliente (nunca a `service_role`)
- A `service_role` key deve ser usada apenas no Supabase Dashboard ou scripts server-side

---

## Autenticação

### Configuração no Supabase Dashboard

1. Aceda a **Authentication** > **Providers**
2. Ative o provider **Email**
3. Configurações recomendadas:
   - **Confirm email**: Desativado para desenvolvimento (ativar em produção)
   - **Minimum password length**: 8 caracteres
   - **Enable email confirmations**: Conforme necessidade

### Tabela `users` e o perfil do utilizador

O perfil em `public.users` usa o **mesmo `id` de `auth.users`**. É criado automaticamente
pelo trigger `handle_new_user` (definido na migration 007, restaurado na 023):

```sql
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

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

A aplicação também faz `upsert` deste registo após o registo (em `AuthService`).

---

## Schema da Base de Dados

A base de dados contém as seguintes tabelas (definição completa nas migrations):

`users` · `categories` · `locations` · `properties` · `property_images` · `property_videos` · `lands` ·
`land_images` · `land_videos` · `favorites` · `bookings` · `messages` · `notifications` ·
`device_tokens` · `saved_searches` · `reviews` · `partners` · `reports` · `moderation_log`

**Diferenças importantes face a versões anteriores da documentação:**

- `users` **não** tem coluna `id_auth` — o `id` é o próprio `auth.users.id`
- `properties`/`lands` **não** têm array `images` — imagens em tabelas filhas (`property_images`, `land_images`) e vídeos em `property_videos`/`land_videos`
- `favorites` usa `property_id`/`land_id` separados (não `item_id`/`item_type`)
- `bookings` usa `property_id` **ou** `land_id` (um deles, `CHECK` de alvo único) + `date`/`time` (não `scheduled_date`)
- `role` é um ENUM (`user_role`), não TEXT
- `users` tem campos de verificação (`verified`, `verified_at`, …) e `properties`/`lands` têm `province`, `agent_verified` e `views`

Consulte [`docs/DATABASE.md`](DATABASE.md) para o schema detalhado e as políticas RLS.

---

## Storage Buckets

Criados e configurados nas migrations 005 (imagens) e 016 (vídeos):

| Bucket | Público | Tamanho Máx | MIME Permitidos |
|---|---|---|---|
| `property-images` | Sim | 10 MB | jpeg, png, webp, gif |
| `avatars` | Sim | 5 MB | jpeg, png, webp |
| `property-videos` | Sim | 50 MB | mp4, quicktime, webm, x-matroska, 3gpp, x-msvideo |

Policies de storage:
- **Leitura** pública dos buckets
- **Upload/update** restritos a agentes/admins (migration 018)
- **Delete** apenas pelo `owner_id` (dono do objeto, migration 017)

> Os buckets `documents` e `products` aparecem em documentação antiga mas **não** são
> criados pelas migrações atuais.

---

## Row Level Security (RLS)

Todas as tabelas têm RLS ativado. Legenda de políticas ativa (migrations 002–026):

| Tabela | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| `users` | próprio ou admin | próprio (`auth.uid() = id`) | próprio; role/verificação só por admin | admin |
| `categories`, `locations` | público | admin | admin | admin |
| `properties`, `lands` | público | agentes/admins | dono ou admin (com `WITH CHECK`) | admin |
| `property_images`, `land_images`, `property_videos`, `land_videos` | público | admin ou agente dono | admin ou agente dono | admin ou agente dono |
| `favorites` | próprio | próprio | — | próprio |
| `bookings` | próprio, agentes, admin | próprio / RPC convidado | próprio (cancelar) ou agentes/admins | — |
| `messages` | remetente/destinatário | remetente | remetente/destinatário | — |
| `notifications` | próprio | admin/RPC | próprio | — |
| `partners` | próprio ou admin (diretório via view `partners_public`) | admin | próprio | admin |
| `device_tokens` | próprio ou admin | próprio | próprio | próprio ou admin |
| `saved_searches` | próprio | próprio | próprio | próprio |
| `reviews` | público | próprio | próprio | próprio |
| `reports` | próprio ou admin | próprio | admin | admin |
| `moderation_log` | admin | admin | admin | admin |

Função auxiliar usada nas políticas:

```sql
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

---

## Desenvolvimento Local com Supabase CLI

### Instalar Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Linux
npx supabase --version

# Windows
scoop install supabase
```

### Aplicar Migrations

```bash
# Login no Supabase
supabase login

# Vincular ao projeto remoto (a partir da pasta luar_company/supabase)
supabase link --project-ref seu-project-ref

# Aplicar as migrations
supabase db push

# Gerar tipos TypeScript (útil para referência)
supabase gen types typescript --schema public > database.types.ts
```

Alternativamente, execute `scripts/deploy_supabase.sh`, que automatiza estes passos.

---

## RPC de Notificações

A aplicação envia notificações através da função RPC `send_notification` (criada na
migration 009 e reforçada na 018 com rate limit por destinatário):

```sql
CREATE OR REPLACE FUNCTION public.send_notification(
  p_user_id UUID,
  p_title TEXT,
  p_body TEXT
) RETURNS void AS $$
BEGIN
  -- (migration 018) valida autorização, limites de tamanho e rate limit (20/10 min)
  INSERT INTO public.notifications (user_id, title, body)
  VALUES (p_user_id, p_title, COALESCE(p_body, ''));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
```

---

## Dicas e Boas Práticas

### Performance

- Usar índices em colunas frequentemente filtradas (definidos nas migrations)
- Limitar o número de colunas no `select()` (evitar `select('*')` onde possível)
- Usar paginação (`range()`) para listas grandes
- Evitar queries N+1 (carregar dados relacionados em batch)

### Segurança

- RLS ativo em todas as tabelas
- Políticas explícitas para cada operação
- Revisar políticas regularmente
- Nunca expor a `service_role` key no cliente

### Monitorização

- Usar o Dashboard do Supabase para monitorizar queries
- Verificar logs de autenticação
- Monitorizar uso de Storage
- Revisar métricas de performance de queries