# Schema da Base de Dados

Documentação do schema da base de dados PostgreSQL utilizada no Supabase para a plataforma Luar Company Imobiliária.

> **Nota de coerência:** este documento espelha o schema **real** definido nas migrações
> (`luar_company/supabase/migrations/001` a `007`).

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

> **Nota:** O modelo Dart de propriedades (`PropertyType`) prevê também os valores `lot` e `farm`,
> mas o enum PostgreSQL não os inclui. Usar em propriedades apenas os 6 tipos do enum.

---

## Tabelas

### `users`

Perfis de utilizadores. O `id` é o mesmo `id` do `auth.users` do Supabase Auth.

```sql
CREATE TABLE users (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT NOT NULL,
  email      TEXT NOT NULL UNIQUE,
  phone      TEXT NOT NULL DEFAULT '',
  avatar_url TEXT NOT NULL DEFAULT '',
  role       user_role NOT NULL DEFAULT 'client',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária (igual a `auth.users.id`) |
| `name` | TEXT | Nome completo |
| `email` | TEXT | Email (único) |
| `phone` | TEXT | Número de telefone |
| `avatar_url` | TEXT | URL da imagem de avatar |
| `role` | `user_role` | Papel: `client`, `agent` ou `admin` |
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
  municipality     TEXT NOT NULL DEFAULT '',
  neighborhood     TEXT NOT NULL DEFAULT '',
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  features         JSONB NOT NULL DEFAULT '[]'::jsonb,
  agent_id         UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_name       TEXT NOT NULL DEFAULT '',
  agent_phone      TEXT NOT NULL DEFAULT '',
  is_featured      BOOLEAN NOT NULL DEFAULT false,
  is_available     BOOLEAN NOT NULL DEFAULT true,
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
| `features` | JSONB | Características (piscina, jardim, etc.) como array |
| `agent_id` | UUID | Referência ao agente responsável (FK users) |
| `agent_name` | TEXT | Nome do agente (cache) |
| `agent_phone` | TEXT | Telefone do agente (cache) |
| `is_featured` | BOOLEAN | Propriedade em destaque |
| `is_available` | BOOLEAN | Disponível para venda/arrendamento |

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
  municipality     TEXT NOT NULL DEFAULT '',
  neighborhood     TEXT NOT NULL DEFAULT '',
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  features         JSONB NOT NULL DEFAULT '[]'::jsonb,
  agent_id         UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_name       TEXT NOT NULL DEFAULT '',
  agent_phone      TEXT NOT NULL DEFAULT '',
  is_featured      BOOLEAN NOT NULL DEFAULT false,
  is_available     BOOLEAN NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `type` | `land_type` | urban, agricultural, industrial, commercial, lot, farm |
| `transaction_type` | `transaction_type` | Venda (`sale`) ou Arrendamento (`rent`) |

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

Agendamentos de visitas a propriedades.

```sql
CREATE TABLE bookings (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_name   TEXT NOT NULL DEFAULT '',
  user_phone  TEXT NOT NULL DEFAULT '',
  date        DATE NOT NULL DEFAULT CURRENT_DATE,
  time        TIME NOT NULL DEFAULT '00:00:00',
  status      booking_status NOT NULL DEFAULT 'pending',
  notes       TEXT NOT NULL DEFAULT '',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `property_id` | UUID | Propriedade visitada (obrigatório) |
| `user_id` | UUID | Utilizador que agendou |
| `date` | DATE | Data da visita |
| `time` | TIME | Hora da visita |
| `status` | `booking_status` | pending, confirmed, cancelled, completed |
| `notes` | TEXT | Observações |

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
| `handle_new_user()` | Trigger `AFTER INSERT ON auth.users` que cria o perfil em `public.users` |

Triggers aplicados: `users`, `properties`, `lands`, `partners`, `notifications` e `auth.users`.

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
idx_notifications_user_id, idx_notifications_is_read

-- Parceiros
idx_partners_user_id, idx_partners_business_type
```

Extensão `pg_trgm` ativada na migração 005 para busca por título (`ILIKE`).

---

## Políticas RLS (Row Level Security)

Resumo das políticas ativas após as migrações 002–007:

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

### `property_images` / `land_images`
- SELECT: público
- ALL: admin, ou agente dono da propriedade/terreno associado

### `favorites`
- SELECT/INSERT/DELETE: próprio utilizador

### `bookings`
- SELECT: próprio utilizador, agentes e admins
- INSERT: `auth.uid() = user_id`
- UPDATE: próprio ou admin; o utilizador apenas pode cancelar agendamentos `pending`

### `messages`
- SELECT: remetente ou destinatário
- INSERT: `auth.uid() = sender_id`
- UPDATE: remetente ou destinatário

### `notifications`
- SELECT/UPDATE: próprio utilizador
- INSERT: admin (ou via RPC `send_notification`)

### `partners`
- SELECT: público; UPDATE: próprio; ALL: admin

---

## Buckets de Storage

Criados nas migrações (públicos, com limites e MIME validados):

| Bucket | Público | Tamanho Máx | MIME |
|---|---|---|---|
| `property-images` | Sim | 10 MB | jpeg, png, webp, gif |
| `avatars` | Sim | 5 MB | jpeg, png, webp |

Policies de storage: leitura pública; upload autenticado; delete apenas do `owner_id` (dono do objeto).

> Os buckets `documents` e `products` são referidos em código/documentação antiga mas **não são criados** pelas migrações atuais.