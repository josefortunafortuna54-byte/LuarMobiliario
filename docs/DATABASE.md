# Schema da Base de Dados

Documentação do schema da base de dados PostgreSQL utilizada no Supabase para a plataforma Luar Company Imobiliária.

---

## Visão Geral

A base de dados é gerida pelo Supabase e utiliza PostgreSQL. Todas as tabelas incluem campos de auditoria (`created_at`, `updated_at`) e utilizam UUID como chave primária.

---

## Tabelas

### `users`

Perfis de utilizadores da plataforma.

```sql
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_auth     UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  phone       TEXT DEFAULT '',
  avatar_url  TEXT DEFAULT '',
  role        TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'agent', 'admin')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária |
| `id_auth` | UUID | Referência ao auth.users do Supabase Auth |
| `name` | TEXT | Nome completo |
| `email` | TEXT | Email (único) |
| `phone` | TEXT | Número de telefone |
| `avatar_url` | TEXT | URL da imagem de avatar |
| `role` | TEXT | Papel: `client`, `agent` ou `admin` |
| `created_at` | TIMESTAMPTZ | Data de criação |
| `updated_at` | TIMESTAMPTZ | Data da última atualização |

---

### `properties`

Propriedades imobiliárias (casas, apartamentos, escritórios, etc.).

```sql
CREATE TABLE properties (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title            TEXT NOT NULL,
  description      TEXT NOT NULL DEFAULT '',
  type             TEXT NOT NULL DEFAULT 'house'
                     CHECK (type IN ('house', 'apartment', 'office', 'warehouse', 'condo', 'shop')),
  transaction_type TEXT NOT NULL DEFAULT 'sale'
                     CHECK (transaction_type IN ('sale', 'rent')),
  price            NUMERIC(15, 2) NOT NULL DEFAULT 0,
  area             NUMERIC(10, 2) NOT NULL DEFAULT 0,
  bedrooms         INTEGER NOT NULL DEFAULT 0,
  bathrooms        INTEGER NOT NULL DEFAULT 0,
  garage           INTEGER NOT NULL DEFAULT 0,
  address          TEXT NOT NULL DEFAULT '',
  city             TEXT NOT NULL DEFAULT '',
  municipality     TEXT NOT NULL DEFAULT '',
  neighborhood     TEXT NOT NULL DEFAULT '',
  latitude         NUMERIC(10, 7) DEFAULT 0,
  longitude        NUMERIC(10, 7) DEFAULT 0,
  images           TEXT[] DEFAULT '{}',
  features         TEXT[] DEFAULT '{}',
  agent_id         UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_name       TEXT DEFAULT '',
  agent_phone      TEXT DEFAULT '',
  is_featured      BOOLEAN DEFAULT false,
  is_available     BOOLEAN DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária |
| `title` | TEXT | Título do anúncio |
| `description` | TEXT | Descrição detalhada |
| `type` | TEXT | Tipo: house, apartment, office, warehouse, condo, shop |
| `transaction_type` | TEXT | Venda (`sale`) ou Arrendamento (`rent`) |
| `price` | NUMERIC(15,2) | Preço em Kwanza (AOA) |
| `area` | NUMERIC(10,2) | Área em m² |
| `bedrooms` | INTEGER | Número de quartos |
| `bathrooms` | INTEGER | Número de casas de banho |
| `garage` | INTEGER | Lugares de estacionamento |
| `address` | TEXT | Endereço completo |
| `city` | TEXT | Cidade (ex: Luanda, Benguela) |
| `municipality` | TEXT | Município |
| `neighborhood` | TEXT | Bairro |
| `latitude` | NUMERIC(10,7) | Latitude GPS |
| `longitude` | NUMERIC(10,7) | Longitude GPS |
| `images` | TEXT[] | URLs das imagens (array) |
| `features` | TEXT[] | Características (piscina, jardim, etc.) |
| `agent_id` | UUID | Referência ao agente responsável |
| `agent_name` | TEXT | Nome do agente (cache) |
| `agent_phone` | TEXT | Telefone do agente (cache) |
| `is_featured` | BOOLEAN | Propriedade em destaque |
| `is_available` | BOOLEAN | Disponível para venda/arrendamento |
| `created_at` | TIMESTAMPTZ | Data de criação |
| `updated_at` | TIMESTAMPTZ | Última atualização |

---

### `lands`

Terrenos para venda ou arrendamento.

```sql
CREATE TABLE lands (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title            TEXT NOT NULL,
  description      TEXT NOT NULL DEFAULT '',
  type             TEXT NOT NULL DEFAULT 'urban'
                     CHECK (type IN ('urban', 'agricultural', 'industrial', 'commercial', 'lot', 'farm')),
  transaction_type TEXT NOT NULL DEFAULT 'sale'
                     CHECK (transaction_type IN ('sale', 'rent')),
  price            NUMERIC(15, 2) NOT NULL DEFAULT 0,
  area             NUMERIC(10, 2) NOT NULL DEFAULT 0,
  address          TEXT NOT NULL DEFAULT '',
  city             TEXT NOT NULL DEFAULT '',
  municipality     TEXT NOT NULL DEFAULT '',
  neighborhood     TEXT NOT NULL DEFAULT '',
  latitude         NUMERIC(10, 7) DEFAULT 0,
  longitude        NUMERIC(10, 7) DEFAULT 0,
  images           TEXT[] DEFAULT '{}',
  features         TEXT[] DEFAULT '{}',
  agent_id         UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_name       TEXT DEFAULT '',
  agent_phone      TEXT DEFAULT '',
  is_featured      BOOLEAN DEFAULT false,
  is_available     BOOLEAN DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária |
| `title` | TEXT | Título do anúncio |
| `description` | TEXT | Descrição detalhada |
| `type` | TEXT | Tipo: urban, agricultural, industrial, commercial, lot, farm |
| `transaction_type` | TEXT | Venda (`sale`) ou Arrendamento (`rent`) |
| `price` | NUMERIC(15,2) | Preço em Kwanza (AOA) |
| `area` | NUMERIC(10,2) | Área em m² |
| `address` | TEXT | Endereço completo |
| `city` | TEXT | Cidade |
| `municipality` | TEXT | Município |
| `neighborhood` | TEXT | Bairro |
| `latitude` | NUMERIC(10,7) | Latitude GPS |
| `longitude` | NUMERIC(10,7) | Longitude GPS |
| `images` | TEXT[] | URLs das imagens |
| `features` | TEXT[] | Características |
| `agent_id` | UUID | Referência ao agente |
| `agent_name` | TEXT | Nome do agente (cache) |
| `agent_phone` | TEXT | Telefone do agente (cache) |
| `is_featured` | BOOLEAN | Terreno em destaque |
| `is_available` | BOOLEAN | Disponível |
| `created_at` | TIMESTAMPTZ | Data de criação |
| `updated_at` | TIMESTAMPTZ | Última atualização |

---

### `favorites`

Registos de favoritos dos utilizadores.

```sql
CREATE TABLE favorites (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  item_id     UUID NOT NULL,
  item_type   TEXT NOT NULL CHECK (item_type IN ('property', 'land')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, item_id, item_type)
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária |
| `user_id` | UUID | Utilizador que favoritou |
| `item_id` | UUID | ID do item favoritado |
| `item_type` | TEXT | Tipo do item: `property` ou `land` |
| `created_at` | TIMESTAMPTZ | Data de criação |

---

### `bookings`

Agendamentos de visitas a propriedades.

```sql
CREATE TABLE bookings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  property_id     UUID REFERENCES properties(id) ON DELETE CASCADE,
  land_id         UUID REFERENCES lands(id) ON DELETE CASCADE,
  scheduled_date  TIMESTAMPTZ NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
  notes           TEXT DEFAULT '',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária |
| `user_id` | UUID | Utilizador que agendou |
| `property_id` | UUID | Propriedade (nullable) |
| `land_id` | UUID | Terreno (nullable) |
| `scheduled_date` | TIMESTAMPTZ | Data/hora da visita |
| `status` | TEXT | pending, confirmed, cancelled, completed |
| `notes` | TEXT | Observações |
| `created_at` | TIMESTAMPTZ | Data de criação |
| `updated_at` | TIMESTAMPTZ | Última atualização |

---

### `messages`

Mensagens entre utilizadores.

```sql
CREATE TABLE messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  is_read     BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária |
| `sender_id` | UUID | Remetente |
| `receiver_id` | UUID | Destinatário |
| `content` | TEXT | Conteúdo da mensagem |
| `is_read` | BOOLEAN | Lida ou não |
| `created_at` | TIMESTAMPTZ | Data de envio |

---

### `notifications`

Notificações do sistema.

```sql
CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  message     TEXT NOT NULL,
  type        TEXT DEFAULT 'info',
  is_read     BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## Índices Recomendados

```sql
-- Propriedades
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_type ON properties(type);
CREATE INDEX idx_properties_transaction ON properties(transaction_type);
CREATE INDEX idx_properties_price ON properties(price);
CREATE INDEX idx_properties_agent ON properties(agent_id);
CREATE INDEX idx_properties_featured ON properties(is_featured) WHERE is_featured = true;
CREATE INDEX idx_properties_available ON properties(is_available) WHERE is_available = true;

-- Terrenos
CREATE INDEX idx_lands_city ON lands(city);
CREATE INDEX idx_lands_type ON lands(type);
CREATE INDEX idx_lands_price ON lands(price);
CREATE INDEX idx_lands_agent ON lands(agent_id);

-- Favoritos
CREATE INDEX idx_favorites_user ON favorites(user_id);

-- Mensagens
CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);

-- Agendamentos
CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_property ON bookings(property_id);
```

---

## Políticas RLS (Row Level Security)

Recomenda-se ativar RLS em todas as tabelas e criar políticas de acesso:

```sql
-- Exemplo: utilizadores só veem os seus favoritos
CREATE POLICY "Users view own favorites" ON favorites
  FOR SELECT USING (auth.uid() = user_id);

-- Propriedades são públicas para leitura
CREATE POLICY "Properties public read" ON properties
  FOR SELECT USING (true);

-- Apenas o agente pode editar as suas propriedades
CREATE POLICY "Agent owns property" ON properties
  FOR UPDATE USING (auth.uid() = agent_id);
```

---

## Buckets de Storage

| Bucket | Tipo | Conteúdo |
|---|---|---|
| `property-images` | Público (leitura) | Imagens de propriedades e terrenos |
| `avatars` | Público (leitura) | Avatares de utilizadores |
| `documents` | Privado | Documentos de identificação |
| `products` | Público (leitura) | Imagens de produtos |
