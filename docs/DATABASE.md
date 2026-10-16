# Schema da Base de Dados

Documentação do schema da base de dados PostgreSQL utilizada no Supabase para a plataforma Luar Company Imobiliária.

> **Nota de coerência:** este documento espelha o schema **real** definido nas migrações
> (`luar_company/supabase/migrations/001` a `026`, todas aplicadas em produção).

---

## Visão Geral

A base de dados é gerida pelo Supabase e utiliza PostgreSQL. A maioria das tabelas inclui campos de auditoria (`created_at`, `updated_at`) e utiliza UUID como chave primária.

O utilizador autenticado no Supabase Auth partilha o mesmo `id` na tabela `public.users` (o `id` de `auth.users` é usado como `id` da tabela `users`, via trigger `handle_new_user` ou via upsert na aplicação).

---

## Tipos Enumerados

Criados nas migrações via `CREATE TYPE` (protegidos por `DO ... EXCEPTION WHEN duplicate_object`):

| Enum | Valores |
|---|---|
| `user_role` | `client`, `agent`, `admin` |
| `category_type` | `property`, `land` |
| `property_type` | `house`, `apartment`, `office`, `warehouse`, `condo`, `shop` |
| `transaction_type` | `sale`, `rent` |
| `land_type` | `urban`, `agricultural`, `industrial`, `commercial`, `lot`, `farm` |
| `booking_status` | `pending`, `confirmed`, `cancelled`, `completed` |
| `partner_business_type` | `imobiliaria`, `construtora`, `corretor`, `administrador`, `outro` |
| `report_target` | `property`, `land`, `user` |
| `report_status` | `pending`, `reviewing`, `resolved`, `dismissed` |

> **Nota:** O modelo Dart de propriedades (`PropertyType`) prevê também os valores `lot` e `farm`,
> mas o enum PostgreSQL não os inclui. Usar em propriedades apenas os 6 tipos do enum.

---

## Tabelas

### `users`

Perfis de utilizadores. O `id` é o mesmo `id` do `auth.users` do Supabase Auth.

```sql
CREATE TABLE users (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name              TEXT NOT NULL,
  email             TEXT NOT NULL UNIQUE,
  phone             TEXT NOT NULL DEFAULT '',
  avatar_url        TEXT NOT NULL DEFAULT '',
  role              user_role NOT NULL DEFAULT 'client',
  verified          BOOLEAN NOT NULL DEFAULT false,
  verification_note TEXT NOT NULL DEFAULT '',
  verified_at       TIMESTAMPTZ,
  verified_by       UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária (igual a `auth.users.id`, FK `ON DELETE CASCADE` — migration 024) |
| `name` | TEXT | Nome completo |
| `email` | TEXT | Email (único) |
| `phone` | TEXT | Número de telefone |
| `avatar_url` | TEXT | URL da imagem de avatar |
| `role` | `user_role` | Papel: `client`, `agent` ou `admin` |
| `verified` | BOOLEAN | Anunciante verificado (migration 018; só admins alteram) |
| `verification_note` | TEXT | Nota de moderação da verificação |
| `verified_at` | TIMESTAMPTZ | Data da verificação |
| `verified_by` | UUID | Admin que verificou (FK users) |
| `created_at` | TIMESTAMPTZ | Data de criação |
| `updated_at` | TIMESTAMPTZ | Última atualização |

---

### `categories`

Categorias apresentadas no ecrã inicial.

```sql
CREATE TABLE categories (
  id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name  TEXT NOT NULL,
  icon  TEXT NOT NULL DEFAULT '',
  type  category_type NOT NULL DEFAULT 'property',
  count INT NOT NULL DEFAULT 0
);
```

---

### `locations`

Estrutura geográfica (cidade → municípios → bairros) em JSONB.

```sql
CREATE TABLE locations (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  city           TEXT NOT NULL,
  municipalities JSONB NOT NULL DEFAULT '[]'::jsonb,
  neighborhoods  JSONB NOT NULL DEFAULT '[]'::jsonb
);
```

---

### `properties`

Propriedades imobiliárias (casas, apartamentos, escritórios, etc.). As imagens vivem na tabela `property_images` (1:N).

```sql
CREATE TABLE properties (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title            TEXT NOT NULL,
  description      TEXT NOT NULL DEFAULT '',
  type             property_type NOT NULL DEFAULT 'house',
  transaction_type transaction_type NOT NULL DEFAULT 'sale',
  price            NUMERIC NOT NULL DEFAULT 0,
  area             NUMERIC NOT NULL DEFAULT 0,
  bedrooms         INT NOT NULL DEFAULT 0,
  bathrooms        INT NOT NULL DEFAULT 0,
  garage           INT NOT NULL DEFAULT 0,
  address          TEXT NOT NULL DEFAULT '',
  city             TEXT NOT NULL DEFAULT '',
  province         TEXT NOT NULL DEFAULT '',
  municipality     TEXT NOT NULL DEFAULT '',
  neighborhood     TEXT NOT NULL DEFAULT '',
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  features         JSONB NOT NULL DEFAULT '[]'::jsonb,
  agent_id         UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_name       TEXT NOT NULL DEFAULT '',
  agent_phone      TEXT NOT NULL DEFAULT '',
  agent_verified   BOOLEAN NOT NULL DEFAULT false,
  is_featured      BOOLEAN NOT NULL DEFAULT false,
  is_available     BOOLEAN NOT NULL DEFAULT true,
  views            INTEGER NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `type` | `property_type` | house, apartment, office, warehouse, condo, shop |
| `transaction_type` | `transaction_type` | Venda (`sale`) ou Arrendamento (`rent`) |
| `price` | NUMERIC | Preço em Kwanza (AOA) |
| `area` | NUMERIC | Área em m² |
| `province` | TEXT | Província (migration 018 — filtro hierárquico Angola) |
| `features` | JSONB | Características (piscina, jardim, etc.) como array |
| `agent_id` | UUID | Referência ao agente responsável (FK users) |
| `agent_name` | TEXT | Nome do agente (cache) |
| `agent_phone` | TEXT | Telefone do agente (cache) |
| `agent_verified` | BOOLEAN | Badge de anunciante verificado (denormalizado, migration 018) |
| `is_featured` | BOOLEAN | Propriedade em destaque |
| `is_available` | BOOLEAN | Disponível para venda/arrendamento |
| `views` | INTEGER | Contador de visualizações (migration 026) |

---

### `property_images`

Imagens de propriedades (relação 1:N).

```sql
CREATE TABLE property_images (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  image_url   TEXT NOT NULL,
  is_primary  BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### `property_videos`

Vídeos de propriedades (relação 1:N). Criada na migration 016.

```sql
CREATE TABLE property_videos (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  video_url   TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### `lands`

Terrenos para venda ou arrendamento.

```sql
CREATE TABLE lands (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title            TEXT NOT NULL,
  description      TEXT NOT NULL DEFAULT '',
  type             land_type NOT NULL DEFAULT 'urban',
  transaction_type transaction_type NOT NULL DEFAULT 'sale',
  price            NUMERIC NOT NULL DEFAULT 0,
  area             NUMERIC NOT NULL DEFAULT 0,
  address          TEXT NOT NULL DEFAULT '',
  city             TEXT NOT NULL DEFAULT '',
  province         TEXT NOT NULL DEFAULT '',
  municipality     TEXT NOT NULL DEFAULT '',
  neighborhood     TEXT NOT NULL DEFAULT '',
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  features         JSONB NOT NULL DEFAULT '[]'::jsonb,
  agent_id         UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_name       TEXT NOT NULL DEFAULT '',
  agent_phone      TEXT NOT NULL DEFAULT '',
  agent_verified   BOOLEAN NOT NULL DEFAULT false,
  is_featured      BOOLEAN NOT NULL DEFAULT false,
  is_available     BOOLEAN NOT NULL DEFAULT true,
  views            INTEGER NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `type` | `land_type` | urban, agricultural, industrial, commercial, lot, farm |
| `transaction_type` | `transaction_type` | Venda (`sale`) ou Arrendamento (`rent`) |
| `province` | TEXT | Província (migration 018) |
| `agent_verified` | BOOLEAN | Badge de anunciante verificado (denormalizado, migration 018) |
| `views` | INTEGER | Contador de visualizações (migration 026) |

---

### `land_images`

Imagens de terrenos (relação 1:N).

```sql
CREATE TABLE land_images (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  land_id   UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### `land_videos`

Vídeos de terrenos (relação 1:N). Criada na migration 016.

```sql
CREATE TABLE land_videos (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  land_id   UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
  video_url TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### `favorites`

Registos de favoritos. Usa colunas separadas para propriedade e terreno, com unicidade por par.

```sql
CREATE TABLE favorites (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  land_id     UUID REFERENCES lands(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT favorites_user_property_unique UNIQUE (user_id, property_id),
  CONSTRAINT favorites_user_land_unique UNIQUE (user_id, land_id)
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `user_id` | UUID | Utilizador que favoritou |
| `property_id` | UUID | Propriedade favoritada (nullable) |
| `land_id` | UUID | Terreno favoritado (nullable) |

---

### `bookings`

Agendamentos de visitas a propriedades ou terrenos.

```sql
CREATE TABLE bookings (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  land_id     UUID REFERENCES lands(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_name   TEXT NOT NULL DEFAULT '',
  user_phone  TEXT NOT NULL DEFAULT '',
  date        DATE NOT NULL DEFAULT CURRENT_DATE,
  time        TIME NOT NULL DEFAULT '00:00:00',
  status      booking_status NOT NULL DEFAULT 'pending',
  notes       TEXT NOT NULL DEFAULT '',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT bookings_single_target CHECK (
    (property_id IS NOT NULL) <> (land_id IS NOT NULL)
  )
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `property_id` | UUID | Propriedade visitada (nullable, migration 015) |
| `land_id` | UUID | Terreno visitado (nullable, migration 015) |
| `user_id` | UUID | Utilizador que agendou |
| `date` | DATE | Data da visita |
| `time` | TIME | Hora da visita |
| `status` | `booking_status` | pending, confirmed, cancelled, completed |
| `notes` | TEXT | Observações |

> Marcações de convidado (sem conta) são criadas via RPC `create_guest_booking` com `user_id` nulo, sem expor PII a anónimos (migration 018).

---

### `messages`

Mensagens entre utilizadores.

```sql
CREATE TABLE messages (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  is_read     BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### `notifications`

Notificações do sistema.

```sql
CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL DEFAULT '',
  is_read    BOOLEAN NOT NULL DEFAULT false,
  fcm_token  TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

A coluna `fcm_token` regista o token de push do utilizador (migration 008), usado pelo `NotificationService.saveTokenToDatabase`. Existe um índice parcial na coluna (`idx_notifications_fcm_token`, apenas para tokens não vazios).

> Desde a migration 019, os tokens de push são geridos na tabela dedicada `device_tokens`; `notifications.fcm_token` mantém-se por compatibilidade.

---

### `device_tokens`

Tokens FCM por dispositivo (migration 019). Substitui o uso de `notifications.fcm_token` para permitir upsert fiável.

```sql
CREATE TABLE device_tokens (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      TEXT NOT NULL,
  platform   TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT device_tokens_token_unique UNIQUE (token)
);
```

---

### `saved_searches`

Pesquisas guardadas por utilizador (migration 020). `filters` guarda o snapshot JSON dos filtros.

```sql
CREATE TABLE saved_searches (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name       TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 60),
  filters    JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### `reviews`

Avaliações de imóveis (migration 022). Uma avaliação por utilizador e imóvel.

```sql
CREATE TABLE reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT NOT NULL DEFAULT '' CHECK (char_length(comment) <= 1000),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (property_id, user_id)
);
```

---

### `reports`

Denúncias de anúncios/utilizadores (migration 018).

```sql
CREATE TABLE reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES users(id) ON DELETE SET NULL,
  target_type report_target NOT NULL,
  target_id   UUID NOT NULL,
  reason      TEXT NOT NULL,
  details     TEXT NOT NULL DEFAULT '',
  status      report_status NOT NULL DEFAULT 'pending',
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### `moderation_log`

Registo de ações de moderação (migration 018). Acesso restrito a admins.

```sql
CREATE TABLE moderation_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id    UUID REFERENCES users(id) ON DELETE SET NULL,
  action      TEXT NOT NULL,
  target_type TEXT NOT NULL DEFAULT '',
  target_id   UUID,
  metadata    JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### `partners`

Parceiros imobiliários (agências, construtoras, corretores).

```sql
CREATE TABLE partners (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  company_name  TEXT NOT NULL DEFAULT '',
  nif           TEXT NOT NULL DEFAULT '',
  business_type partner_business_type NOT NULL DEFAULT 'outro',
  address       TEXT NOT NULL DEFAULT '',
  whatsapp      TEXT NOT NULL DEFAULT '',
  license       TEXT NOT NULL DEFAULT '',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT partners_user_id_unique UNIQUE (user_id)
);
```

---

## Funções e Triggers

| Função / Trigger | Descrição |
|---|---|
| `public.get_user_role()` | Retorna o `role` do utilizador atual (base para políticas RLS) |
| `update_updated_at_column()` | Trigger que atualiza `updated_at` antes de UPDATE |
| `prevent_role_change()` | Impede que não-admins alterem o `role` de utilizadores |
| `handle_new_user()` | Trigger `AFTER INSERT ON auth.users` que cria o perfil em `public.users` (restaurado na migration 023) |
| `send_notification(user_id, title, body)` | RPC `SECURITY DEFINER` que regista uma notificação; com rate limit por destinatário (migration 018) |
| `create_guest_booking(...)` | RPC `SECURITY DEFINER` que cria uma marcação de convidado (imóvel OU terreno), validando nome/telefone (migration 018) |
| `register_guest_client(name, phone, booking_id)` | RPC `SECURITY DEFINER` que cria um perfil de visitante em `users` e liga a marcação; usa email sintético no domínio `@guest.luar` e valida posse pelo telefone (migration 018) |
| `is_guest_profile_email(email)` | Helper que identifica emails sintéticos `%@guest.luar` |
| `favorite_counts(property_ids)` | RPC `SECURITY DEFINER` que devolve a contagem pública de gostos por imóvel (migration 021) |
| `sync_agent_verified()` | Trigger que propaga `users.verified` para `properties`/`lands.agent_verified` (migration 018) |
| `prevent_self_verification()` | Trigger que impede não-admins de alterar campos de verificação (migration 018/021) |
| `delete_user(user_id)` | RPC `SECURITY DEFINER` que apaga um utilizador de `auth.users` (só admins; cascade) (migration 024) |
| `register_listing_view(kind, id)` | RPC `SECURITY DEFINER` que incrementa o contador `views` de um imóvel/terreno (migration 026) |

Triggers aplicados: `users`, `properties`, `lands`, `partners`, `notifications` e `auth.users`.

---

## Views

Views (executam com os privilégios do owner/PostgREST, para expor campos não-PII):

| View | Descrição |
|---|---|
| `users_public` | Campos públicos de `users` (`id`, `name`, `avatar_url`, `role`, `verified`, `verified_at`) — migration 021 |
| `partners_public` | Diretório de parceiros sem campos sensíveis (`nif`, `license` omitidos) — migration 018 |
| `property_review_summary` | Média (`average_rating`) e nº (`review_count`) de avaliações por imóvel — migration 022 |

---

## Índices

```sql
-- Propriedades
idx_properties_agent_id, idx_properties_city, idx_properties_municipality,
idx_properties_type, idx_properties_transaction_type,
idx_properties_is_featured, idx_properties_is_available, idx_properties_price,
idx_properties_created_at (DESC), idx_properties_title_trgm (GIN trigram)

-- Terrenos
idx_lands_agent_id, idx_lands_city, idx_lands_municipality, idx_lands_type,
idx_lands_transaction_type, idx_lands_is_featured, idx_lands_is_available,
idx_lands_price, idx_lands_created_at (DESC), idx_lands_title_trgm (GIN trigram)

-- Imagens
idx_property_images_property_id, idx_land_images_land_id

-- Favoritos
idx_favorites_user_id, idx_favorites_property_id, idx_favorites_land_id

-- Agendamentos
idx_bookings_property_id, idx_bookings_user_id, idx_bookings_status,
idx_bookings_date, idx_bookings_user_created, idx_bookings_property_status

-- Mensagens
idx_messages_sender_id, idx_messages_receiver_id, idx_messages_created_at (DESC),
idx_messages_conversation (sender_id, receiver_id, created_at DESC)

-- Notificações
idx_notifications_user_id, idx_notifications_is_read,
idx_notifications_user_unread (user_id, created_at DESC) WHERE is_read = false

-- Parceiros
idx_partners_user_id, idx_partners_business_type

-- Índices compostos/parciais de otimização (migration 025)
idx_properties_available_created, idx_lands_available_created,
idx_properties_available_type / _transaction / _city,
idx_lands_available_type / _transaction / _city,
idx_properties_featured_available, idx_lands_featured_available,
idx_messages_sender_receiver_created, idx_messages_receiver_created,
idx_reviews_user_id, idx_users_created_at, idx_users_role

-- Vídeos, pesquisas guardadas, avaliações, denúncias, device tokens, moderação
idx_property_videos_property_id, idx_land_videos_land_id,
idx_saved_searches_user_id (user_id, created_at DESC),
idx_reviews_property_id (property_id, created_at DESC),
idx_reports_status, idx_reports_target, idx_reports_reporter,
idx_device_tokens_user_id,
idx_moderation_log_actor, idx_moderation_log_created (created_at DESC),
idx_properties_province, idx_lands_province,
idx_properties_views (views DESC), idx_lands_views (views DESC)
```

Extensão `pg_trgm` ativada na migração 005 para busca por título (`ILIKE`).

---

## Políticas RLS (Row Level Security)

Resumo das políticas ativas após as migrações 002–026:

### `users`
- SELECT: o próprio utilizador ou admin (`auth.uid() = id OR get_user_role() = 'admin'`)
- INSERT: `auth.uid() = id`
- UPDATE: próprio utilizador; apenas admins alteram `role` (trigger `prevent_role_change`)
- ALL: admin

### `categories` / `locations`
- SELECT: público; ALL: admin

### `properties` / `lands`
- SELECT: público
- INSERT: agentes e admins
- UPDATE: dono (`agent_id = auth.uid()`) ou admin, com `WITH CHECK` para impedir reatribuição de `agent_id`
- DELETE: admin

### `property_images` / `land_images` / `property_videos` / `land_videos`
- SELECT: público
- ALL: admin, ou agente dono da propriedade/terreno associado

### `favorites`
- SELECT/INSERT/DELETE: próprio utilizador

### `bookings`
- SELECT: próprio utilizador, agentes e admins (migration 018 removeu a leitura anónima)
- INSERT: `auth.uid() = user_id`; convidados via RPC `create_guest_booking`
- UPDATE: próprio ou admin; o utilizador apenas pode cancelar agendamentos `pending`

### `messages`
- SELECT: remetente ou destinatário
- INSERT: `auth.uid() = sender_id`
- UPDATE: remetente ou destinatário

### `notifications`
- SELECT/UPDATE: próprio utilizador
- INSERT: admin (ou via RPC `send_notification`)

### `partners`
- SELECT: próprio ou admin (a leitura pública passou para a view `partners_public`, migration 018)
- UPDATE: próprio; ALL: admin

### `device_tokens`
- SELECT/UPDATE/DELETE: próprio utilizador ou admin; INSERT: `auth.uid() = user_id`

### `saved_searches`
- SELECT/INSERT/UPDATE/DELETE: próprio utilizador

### `reviews`
- SELECT: público; INSERT/UPDATE/DELETE: próprio autor (`auth.uid() = user_id`)

### `reports`
- INSERT: próprio autor; SELECT: próprio autor ou admin; UPDATE/DELETE: admin

### `moderation_log`
- ALL: admin

---

## Buckets de Storage

Criados nas migrações (públicos, com limites e MIME validados):

| Bucket | Público | Tamanho Máx | MIME |
|---|---|---|---|
| `property-images` | Sim | 10 MB | jpeg, png, webp, gif |
| `avatars` | Sim | 5 MB | jpeg, png, webp |
| `property-videos` | Sim | 50 MB | mp4, quicktime, webm, x-matroska, 3gpp, x-msvideo |

Policies de storage: leitura pública; upload e update restritos a agentes/admins (migration 018); delete apenas do `owner_id` (dono do objeto, migration 017).

> Os buckets `documents` e `products` são referidos em código/documentação antiga mas **não são criados** pelas migrações atuais.