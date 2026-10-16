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
- `id` (UUID, PK) — Chave primária (igual a `auth.users.id`, FK `ON DELETE CASCADE`)
- `name` (TEXT) — Nome completo
- `email` (TEXT, UNIQUE) — Email
- `phone` (TEXT) — Telefone
- `avatar_url` (TEXT) — URL do avatar
- `role` (`user_role`) — `client` | `agent` | `admin`
- `verified` (BOOLEAN) — Anunciante verificado (só admins alteram)
- `verification_note` (TEXT) — Nota de moderação
- `verified_at` (TIMESTAMPTZ) — Data da verificação
- `verified_by` (UUID, FK → users) — Admin que verificou
- `created_at` (TIMESTAMPTZ) — Data de criação
- `updated_at` (TIMESTAMPTZ) — Última atualização

> **Nota:** não existe coluna `id_auth` — o `id` é o próprio `auth.users.id`.

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
- `province` (TEXT) — Província
- `municipality` (TEXT) — Município
- `neighborhood` (TEXT) — Bairro
- `latitude` (NUMERIC 10,7) — Latitude GPS
- `longitude` (NUMERIC 10,7) — Longitude GPS
- `features` (JSONB) — Características (piscina, jardim, etc.) como array
- `agent_id` (UUID, FK → users) — Agente responsável
- `agent_name` (TEXT) — Nome do agente (cache)
- `agent_phone` (TEXT) — Telefone do agente (cache)
- `agent_verified` (BOOLEAN) — Badge de anunciante verificado (denormalizado)
- `is_featured` (BOOLEAN) — Em destaque
- `is_available` (BOOLEAN) — Disponível
- `views` (INTEGER) — Contador de visualizações
- `created_at` (TIMESTAMPTZ) — Data de criação
- `updated_at` (TIMESTAMPTZ) — Última atualização

> **Nota:** as imagens e vídeos **não** são colunas — vivem nas tabelas filhas `property_images` / `property_videos` (relação 1:N).

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
- `province` (TEXT)
- `municipality` (TEXT)
- `neighborhood` (TEXT)
- `latitude` / `longitude` (NUMERIC 10,7)
- `features` (JSONB)
- `agent_id` (UUID, FK → users)
- `agent_name` / `agent_phone` (TEXT)
- `agent_verified` (BOOLEAN)
- `is_featured` (BOOLEAN)
- `is_available` (BOOLEAN)
- `views` (INTEGER)
- `created_at` / `updated_at` (TIMESTAMPTZ)

> **Nota:** as imagens e vídeos **não** são colunas — vivem nas tabelas filhas `land_images` / `land_videos`.

---

### `favorites`

Registos de favoritos.

| Operação | Query Supabase | RLS |
|---|---|---|
| Obter favoritos do utilizador | `.from('favorites').select().eq('user_id', userId)` | Próprio utilizador |
| Adicionar favorito | `.from('favorites').insert(data)` | Próprio utilizador |
| Remover favorito | `.from('favorites').delete().eq('user_id', userId).eq('property_id', id)` | Próprio utilizador |
| Verificar se é favorito | `.from('favorites').select().eq('user_id', userId).eq('property_id', id)` | Próprio utilizador |
| Contagem pública de gostos | RPC `favorite_counts(property_ids)` | Público |

**Campos:**
- `id` (UUID, PK)
- `user_id` (UUID, FK → users)
- `property_id` (UUID, FK → properties, nullable) — imóvel favoritado
- `land_id` (UUID, FK → lands, nullable) — terreno favoritado
- `created_at` (TIMESTAMPTZ)
- **UNIQUE** (user_id, property_id) e **UNIQUE** (user_id, land_id)

---

### `bookings`

Agendamentos de visitas.

| Operação | Query Supabase | RLS |
|---|---|---|
| Obter agendamentos do utilizador | `.from('bookings').select().eq('user_id', userId)` | Próprio utilizador |
| Criar agendamento (conta) | `.from('bookings').insert(data)` | Próprio utilizador |
| Criar agendamento (convidado) | RPC `create_guest_booking(...)` | Público (anon) |
| Atualizar estado | `.from('bookings').update({'status': 'confirmed'}).eq('id', id)` | Agente/Admin |
| Cancelar | `.from('bookings').update({'status': 'cancelled'}).eq('id', id)` | Próprio utilizador |

**Campos:**
- `id` (UUID, PK)
- `user_id` (UUID, FK → users)
- `property_id` (UUID, FK → properties, nullable)
- `land_id` (UUID, FK → lands, nullable)
- `user_name` / `user_phone` (TEXT) — dados de contacto da marcação
- `date` (DATE) — Data da visita
- `time` (TIME) — Hora da visita
- `status` (`booking_status`) — `pending` | `confirmed` | `cancelled` | `completed`
- `notes` (TEXT) — Observações
- `created_at` (TIMESTAMPTZ)

> `property_id` **ou** `land_id` deve estar preenchido (CHECK de alvo único, migration 015).

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
| Criar notificação | RPC `send_notification(user_id, title, body)` | Autenticado (com rate limit) |
| Marcar como lida | `.from('notifications').update({'is_read': true}).eq('id', id)` | Próprio utilizador |

**Campos:**
- `id` (UUID, PK)
- `user_id` (UUID, FK → users)
- `title` (TEXT)
- `body` (TEXT) — Conteúdo da notificação
- `fcm_token` (TEXT) — Token de push (legacy; usar `device_tokens`)
- `is_read` (BOOLEAN)
- `created_at` / `updated_at` (TIMESTAMPTZ)

---

### `reviews`

Avaliações de imóveis (1–5 estrelas).

| Operação | Query Supabase | RLS |
|---|---|---|
| Listar avaliações do imóvel | `.from('reviews').select().eq('property_id', id)` | Público |
| Resumo agregado | `.from('property_review_summary').select().eq('property_id', id)` | Público |
| Avaliar | `.from('reviews').insert(data)` | Próprio utilizador |
| Atualizar/remover | `.from('reviews').update(data)/.delete().eq('id', id)` | Próprio autor |

**Campos:** `id`, `property_id` (FK), `user_id` (FK), `rating` (INT 1–5), `comment` (TEXT ≤1000), `created_at`, `updated_at`. **UNIQUE** (property_id, user_id).

---

### `saved_searches`

Pesquisas guardadas por utilizador.

| Operação | Query Supabase | RLS |
|---|---|---|
| Listar | `.from('saved_searches').select().eq('user_id', userId)` | Próprio utilizador |
| Guardar | `.from('saved_searches').insert(data)` | Próprio utilizador |
| Renomear | `.from('saved_searches').update({'name': n}).eq('id', id)` | Próprio utilizador |
| Remover | `.from('saved_searches').delete().eq('id', id)` | Próprio utilizador |

**Campos:** `id`, `user_id` (FK), `name` (TEXT 1–60), `filters` (JSONB), `created_at`.

---

### `device_tokens`

Tokens FCM por dispositivo.

| Operação | Query Supabase | RLS |
|---|---|---|
| Registar/atualizar token | `.from('device_tokens').upsert(data)` | Próprio utilizador |
| Remover token | `.from('device_tokens').delete().eq('token', t)` | Próprio utilizador |

**Campos:** `id`, `user_id` (FK), `token` (TEXT, UNIQUE), `platform` (TEXT), `updated_at`.

---

## Políticas RLS (Resumo)

| Tabela | Leitura | Escrita | Eliminação |
|---|---|---|---|
| `users` | Próprio + Admin (público via view `users_public`) | Próprio | Admin |
| `properties` | Público | Agente (próprio) | Admin |
| `lands` | Público | Agente (próprio) | Admin |
| `favorites` | Próprio utilizador | Próprio utilizador | Próprio utilizador |
| `bookings` | Próprio, agentes e admins | Próprio / RPC convidado | — |
| `messages` | Próprio (enviadas + recebidas) | Próprio (sender) | — |
| `notifications` | Próprio utilizador | RPC `send_notification` / Admin | — |
| `partners` | Próprio + Admin (diretório via `partners_public`) | Próprio | Admin |
| `reviews` | Público | Próprio autor | Próprio autor |
| `saved_searches` | Próprio utilizador | Próprio utilizador | Próprio utilizador |
| `device_tokens` | Próprio + Admin | Próprio utilizador | Próprio + Admin |
| `reports` | Próprio + Admin | Próprio (INSERT) | Admin |
| `moderation_log` | Admin | Admin | Admin |

---

## Storage Buckets

| Bucket | Leitura | Escrita | Tamanho Máx |
|---|---|---|---|
| `property-images` | Público | Autenticado (agente/admin) | 10 MB |
| `avatars` | Público | Autenticado (próprio) | 5 MB |
| `property-videos` | Público | Autenticado (agente/admin) | 50 MB |

Formatos aceites: JPEG, PNG, WebP, GIF (imagens) e MP4, MOV, WebM, MKV, 3GPP, AVI (vídeos).

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

A lista completa e atualizada de índices está em [`docs/DATABASE.md`](DATABASE.md). Exemplos:

```sql
-- Propriedades
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_type ON properties(type);
CREATE INDEX idx_properties_transaction_type ON properties(transaction_type);
CREATE INDEX idx_properties_price ON properties(price);
CREATE INDEX idx_properties_agent_id ON properties(agent_id);
CREATE INDEX idx_properties_is_featured ON properties(is_featured);
CREATE INDEX idx_properties_is_available ON properties(is_available);

-- Índices compostos/parciais (migration 025)
CREATE INDEX idx_properties_available_created
  ON properties(created_at DESC) WHERE is_available = true;

-- Terrenos
CREATE INDEX idx_lands_city ON lands(city);
CREATE INDEX idx_lands_type ON lands(type);
CREATE INDEX idx_lands_price ON lands(price);
CREATE INDEX idx_lands_agent_id ON lands(agent_id);

-- Favoritos / Mensagens / Agendamentos
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
```
