# Documentação da API

Documentação da camada de API da plataforma Luar Company Imobiliária, baseada em Supabase.

---

## Visão Geral

A plataforma utiliza **Supabase** como camada de API, proporcionando:

- **PostgreSQL** como base de dados relacional
- **Supabase Auth** para autenticação
- **Supabase Storage** para armazenamento de ficheiros
- **Supabase Realtime** para atualizações em tempo real
- **Row Level Security (RLS)** para autorização a nível de linha

Todas as operações de dados são feitas via `supabase_flutter` SDK, que comunica com a API REST do Supabase.

---

## Endpoints por Domínio

### Autenticação

| Operação | Método | Supabase SDK |
|---|---|---|
| Login | `signInWithPassword` | `supabase.auth.signInWithPassword()` |
| Registo | `signUp` | `supabase.auth.signUp()` |
| Logout | `signOut` | `supabase.auth.signOut()` |
| Recuperar password | `resetPasswordForEmail` | `supabase.auth.resetPasswordForEmail()` |
| Atualizar perfil auth | `updateUser` | `supabase.auth.updateUser()` |
| Obter utilizador atual | `currentUser` | `supabase.auth.currentUser` |
| Estado da sessão | `onAuthStateChange` | `supabase.auth.onAuthStateChange` |

---

## Tabelas

### `users`

Perfis de utilizadores.

| Operação | Query Supabase | RLS |
|---|---|---|
| Obter perfil próprio | `.from('users').select().eq('id', userId).single()` | Próprio utilizador |
| Atualizar perfil | `.from('users').update(data).eq('id', userId)` | Próprio utilizador |
| Listar todos (admin) | `.from('users').select()` | Apenas admin |

**Campos:**
- `id` (UUID, PK) — Chave primária
- `id_auth` (UUID, FK → auth.users) — Referência Supabase Auth
- `name` (TEXT) — Nome completo
- `email` (TEXT, UNIQUE) — Email
- `phone` (TEXT) — Telefone
- `avatar_url` (TEXT) — URL do avatar
- `role` (TEXT) — `client` | `agent` | `admin`
- `created_at` (TIMESTAMPTZ) — Data de criação
- `updated_at` (TIMESTAMPTZ) — Última atualização

---

### `properties`

Propriedades imobiliárias.

| Operação | Query Supabase | RLS |
|---|---|---|
| Listar propriedades | `.from('properties').select().eq('is_available', true)` | Público |
| Filtrar por tipo | `.eq('type', 'apartment')` | Público |
| Filtrar por preço | `.gte('price', min).lte('price', max)` | Público |
| Filtrar por cidade | `.eq('city', 'Luanda')` | Público |
| Obter detalhe | `.from('properties').select().eq('id', id).single()` | Público |
| Propriedades destaque | `.eq('is_featured', true).eq('is_available', true)` | Público |
| Pesquisa textual | `.or('title.ilike.%,description.ilike.%,address.ilike.%')` | Público |
| Criar propriedade | `.from('properties').insert(data)` | Agente (próprio) |
| Atualizar | `.from('properties').update(data).eq('id', id)` | Agente (próprio) |
| Eliminar | `.from('properties').delete().eq('id', id)` | Agente (próprio) / Admin |
| Por agente | `.eq('agent_id', agentId)` | Público |
| Paginação | `.range(offset, offset + limit - 1)` | — |
| Ordenação | `.order('created_at', ascending: false)` | — |

**Campos:**
- `id` (UUID, PK) — Chave primária
- `title` (TEXT) — Título do anúncio
- `description` (TEXT) — Descrição detalhada
- `type` (TEXT) — `house` | `apartment` | `office` | `warehouse` | `condo` | `shop`
- `transaction_type` (TEXT) — `sale` | `rent`
- `price` (NUMERIC 15,2) — Preço em Kwanza (AOA)
- `area` (NUMERIC 10,2) — Área em m²
- `bedrooms` (INTEGER) — Número de quartos
- `bathrooms` (INTEGER) — Número de casas de banho
- `garage` (INTEGER) — Lugares de estacionamento
- `address` (TEXT) — Endereço completo
- `city` (TEXT) — Cidade
- `municipality` (TEXT) — Município
- `neighborhood` (TEXT) — Bairro
- `latitude` (NUMERIC 10,7) — Latitude GPS
- `longitude` (NUMERIC 10,7) — Longitude GPS
- `images` (TEXT[]) — URLs das imagens
- `features` (TEXT[]) — Características (piscina, jardim, etc.)
- `agent_id` (UUID, FK → users) — Agente responsável
- `agent_name` (TEXT) — Nome do agente (cache)
- `agent_phone` (TEXT) — Telefone do agente (cache)
- `is_featured` (BOOLEAN) — Em destaque
- `is_available` (BOOLEAN) — Disponível
- `created_at` (TIMESTAMPTZ) — Data de criação
- `updated_at` (TIMESTAMPTZ) — Última atualização

---

### `lands`

Terrenos para venda ou arrendamento.

| Operação | Query Supabase | RLS |
|---|---|---|
| Listar terrenos | `.from('lands').select().eq('is_available', true)` | Público |
| Filtrar por tipo | `.eq('type', 'urban')` | Público |
| Obter detalhe | `.from('lands').select().eq('id', id).single()` | Público |
| Criar terreno | `.from('lands').insert(data)` | Agente (próprio) |
| Atualizar | `.from('lands').update(data).eq('id', id)` | Agente (próprio) |

**Campos:**
- `id` (UUID, PK)
- `title` (TEXT)
- `description` (TEXT)
- `type` (TEXT) — `urban` | `agricultural` | `industrial` | `commercial` | `lot` | `farm`
- `transaction_type` (TEXT) — `sale` | `rent`
- `price` (NUMERIC 15,2)
- `area` (NUMERIC 10,2)
- `address` (TEXT)
- `city` (TEXT)
- `municipality` (TEXT)
- `neighborhood` (TEXT)
- `latitude` / `longitude` (NUMERIC 10,7)
- `images` (TEXT[])
- `features` (TEXT[])
- `agent_id` (UUID, FK → users)
- `agent_name` / `agent_phone` (TEXT)
- `is_featured` (BOOLEAN)
- `is_available` (BOOLEAN)
- `created_at` / `updated_at` (TIMESTAMPTZ)

---

### `favorites`

Registos de favoritos.

| Operação | Query Supabase | RLS |
|---|---|---|
| Obter favoritos do utilizador | `.from('favorites').select().eq('user_id', userId)` | Próprio utilizador |
| Adicionar favorito | `.from('favorites').insert(data)` | Próprio utilizador |
| Remover favorito | `.from('favorites').delete().eq('user_id', userId).eq('item_id', itemId)` | Próprio utilizador |
| Verificar se é favorito | `.from('favorites').select().eq('user_id', userId).eq('item_id', itemId)` | Próprio utilizador |

**Campos:**
- `id` (UUID, PK)
- `user_id` (UUID, FK → users)
- `item_id` (UUID) — ID do item favoritado
- `item_type` (TEXT) — `property` | `land`
- `created_at` (TIMESTAMPTZ)
- **UNIQUE** (user_id, item_id, item_type)

---

### `bookings`

Agendamentos de visitas.

| Operação | Query Supabase | RLS |
|---|---|---|
| Obter agendamentos do utilizador | `.from('bookings').select().eq('user_id', userId)` | Próprio utilizador |
| Criar agendamento | `.from('bookings').insert(data)` | Próprio utilizador |
| Atualizar estado | `.from('bookings').update({'status': 'confirmed'}).eq('id', id)` | Próprio utilizador |
| Cancelar | `.from('bookings').update({'status': 'cancelled'}).eq('id', id)` | Próprio utilizador |

**Campos:**
- `id` (UUID, PK)
- `user_id` (UUID, FK → users)
- `property_id` (UUID, FK → properties, nullable)
- `land_id` (UUID, FK → lands, nullable)
- `scheduled_date` (TIMESTAMPTZ) — Data/hora da visita
- `status` (TEXT) — `pending` | `confirmed` | `cancelled` | `completed`
- `notes` (TEXT) — Observações
- `created_at` / `updated_at` (TIMESTAMPTZ)

---

### `messages`

Mensagens entre utilizadores.

| Operação | Query Supabase | RLS |
|---|---|---|
| Obter mensagens recebidas | `.from('messages').select().eq('receiver_id', userId)` | Próprio utilizador |
| Obter mensagens enviadas | `.from('messages').select().eq('sender_id', userId)` | Próprio utilizador |
| Enviar mensagem | `.from('messages').insert(data)` | Próprio utilizador (sender) |
| Marcar como lida | `.from('messages').update({'is_read': true}).eq('id', id)` | Próprio utilizador |

**Campos:**
- `id` (UUID, PK)
- `sender_id` (UUID, FK → users)
- `receiver_id` (UUID, FK → users)
- `content` (TEXT) — Conteúdo da mensagem
- `is_read` (BOOLEAN) — Lida ou não
- `created_at` (TIMESTAMPTZ)

---

### `notifications`

Notificações do sistema.

| Operação | Query Supabase | RLS |
|---|---|---|
| Obter notificações | `.from('notifications').select().eq('user_id', userId)` | Próprio utilizador |
| Criar notificação | `.from('notifications').insert(data)` | Serviço / Admin |
| Marcar como lida | `.from('notifications').update({'is_read': true}).eq('id', id)` | Próprio utilizador |

**Campos:**
- `id` (UUID, PK)
- `user_id` (UUID, FK → users)
- `title` (TEXT)
- `message` (TEXT)
- `type` (TEXT) — Tipo da notificação
- `is_read` (BOOLEAN)
- `created_at` (TIMESTAMPTZ)

---

## Políticas RLS (Resumo)

| Tabela | Leitura | Escrita | Eliminação |
|---|---|---|---|
| `users` | Próprio + Admin | Próprio | — |
| `properties` | Público | Agente (próprio) | Agente (próprio) / Admin |
| `lands` | Público | Agente (próprio) | Agente (próprio) / Admin |
| `favorites` | Próprio utilizador | Próprio utilizador | Próprio utilizador |
| `bookings` | Próprio utilizador | Próprio utilizador | Próprio utilizador |
| `messages` | Próprio (enviadas + recebidas) | Próprio (sender) | — |
| `notifications` | Próprio utilizador | Serviço / Admin | — |

---

## Storage Buckets

| Bucket | Leitura | Escrita | Tamanho Máx |
|---|---|---|---|
| `property-images` | Público | Autenticado (agente/admin) | 10 MB |
| `avatars` | Público | Autenticado (próprio) | 10 MB |
| `documents` | Privado | Autenticado (próprio) | 10 MB |
| `products` | Público | Autenticado (agente/admin) | 10 MB |

Formatos aceites: JPEG, PNG, WebP, PDF.

---

## Paginação

A paginação é feita via `range()` do Supabase:

```dart
// Página 1 (20 itens)
final response = await client
    .from('properties')
    .select()
    .order('created_at', ascending: false)
    .range(0, 19);

// Página 2
final response = await client
    .from('properties')
    .select()
    .order('created_at', ascending: false)
    .range(20, 39);
```

**Tamanho padrão por página:** 20 itens (`AppConstants.defaultPageSize`)

---

## Índices na Base de Dados

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
