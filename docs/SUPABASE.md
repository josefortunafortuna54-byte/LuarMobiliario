# Configuração do Supabase

Guia completo de configuração do Supabase para a plataforma Luar Company Imobiliária.

---

## Visão Geral

O Supabase é a plataforma backend (BaaS) utilizada no projeto, fornecendo:

- **PostgreSQL** — Base de dados relacional
- **Supabase Auth** — Autenticação e gestão de utilizadores
- **Supabase Storage** — Armazenamento de ficheiros (imagens, documentos)
- **Supabase Realtime** — Atualizações em tempo real (subscriptions)
- **Row Level Security (RLS)** — Autorização a nível de linha

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

### Tabela `users`

Após o registo no Supabase Auth, um registo é criado na tabela `users` via trigger ou via aplicação:

```sql
-- Trigger para criar perfil automaticamente após registo (alternativa)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id_auth, name, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    NEW.email,
    'client'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## Database Setup

### Criar Tabelas

Execute o seguinte SQL no Supabase Dashboard > SQL Editor:

```sql
-- Tabela de utilizadores
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

-- Tabela de propriedades
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

-- Tabela de terrenos
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

-- Tabela de favoritos
CREATE TABLE favorites (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  item_id     UUID NOT NULL,
  item_type   TEXT NOT NULL CHECK (item_type IN ('property', 'land')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, item_id, item_type)
);

-- Tabela de agendamentos
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

-- Tabela de mensagens
CREATE TABLE messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  is_read     BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Tabela de notificações
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

### Criar Índices

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

## Storage Buckets

### Criar Buckets

No Supabase Dashboard > Storage > New bucket:

| Bucket Name | Público | Tamanho Máx |
|---|---|---|
| `property-images` | Sim (leitura) | 10 MB |
| `avatars` | Sim (leitura) | 10 MB |
| `documents` | Não | 10 MB |
| `products` | Sim (leitura) | 10 MB |

### Políticas de Storage

```sql
-- property-images: leitura pública, escrita autenticada
CREATE POLICY "Property images public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'property-images');

CREATE POLICY "Property images insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'property-images'
    AND auth.role() = 'authenticated'
  );

-- avatars: leitura pública, escrita próprio utilizador
CREATE POLICY "Avatars public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Avatars insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
  );

-- documents: acesso privado
CREATE POLICY "Documents own read"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

---

## Row Level Security (RLS)

### Ativar RLS

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE lands ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
```

### Políticas

```sql
-- ═══════════════════════════════════════════════════════════
-- USERS
-- ═══════════════════════════════════════════════════════════

CREATE POLICY "Users read own profile" ON users
  FOR SELECT USING (auth.uid() = id_auth);

CREATE POLICY "Users update own profile" ON users
  FOR UPDATE USING (auth.uid() = id_auth);

CREATE POLICY "Admins read all users" ON users
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id_auth = auth.uid() AND role = 'admin')
  );

-- ═══════════════════════════════════════════════════════════
-- PROPERTIES
-- ═══════════════════════════════════════════════════════════

CREATE POLICY "Properties public read" ON properties
  FOR SELECT USING (true);

CREATE POLICY "Agents create properties" ON properties
  FOR INSERT WITH CHECK (auth.uid() = agent_id);

CREATE POLICY "Agents update own properties" ON properties
  FOR UPDATE USING (auth.uid() = agent_id);

CREATE POLICY "Agents delete own properties" ON properties
  FOR DELETE USING (auth.uid() = agent_id);

CREATE POLICY "Admin manages all properties" ON properties
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id_auth = auth.uid() AND role = 'admin')
  );

-- ═══════════════════════════════════════════════════════════
-- LANDS
-- ═══════════════════════════════════════════════════════════

CREATE POLICY "Lands public read" ON lands
  FOR SELECT USING (true);

CREATE POLICY "Agents create lands" ON lands
  FOR INSERT WITH CHECK (auth.uid() = agent_id);

CREATE POLICY "Agents update own lands" ON lands
  FOR UPDATE USING (auth.uid() = agent_id);

CREATE POLICY "Agents delete own lands" ON lands
  FOR DELETE USING (auth.uid() = agent_id);

CREATE POLICY "Admin manages all lands" ON lands
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id_auth = auth.uid() AND role = 'admin')
  );

-- ═══════════════════════════════════════════════════════════
-- FAVORITES
-- ═══════════════════════════════════════════════════════════

CREATE POLICY "Users manage own favorites" ON favorites
  FOR ALL USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════
-- BOOKINGS
-- ═══════════════════════════════════════════════════════════

CREATE POLICY "Users manage own bookings" ON bookings
  FOR ALL USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════
-- MESSAGES
-- ═══════════════════════════════════════════════════════════

CREATE POLICY "Users read own messages" ON messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users send messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- ═══════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════

CREATE POLICY "Users read own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service creates notifications" ON notifications
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

---

## Variáveis de Ambiente — Resumo

| Variável | Obrigatória | Descrição | Onde usar |
|---|---|---|---|
| `SUPABASE_URL` | Sim | URL do projeto Supabase | App Flutter |
| `SUPABASE_ANON_KEY` | Sim | Chave pública (anon) | App Flutter |
| `FCM_SENDER_ID` | Não | ID do remetente FCM | App Flutter |
| `FCM_PROJECT_ID` | Não | ID do projeto Firebase | App Flutter |

**Nunca** usar a `service_role` key no cliente Flutter.

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

### Iniciar Projeto Local

```bash
# Login no Supabase
supabase login

# Vincular ao projeto remoto
supabase link --project-ref seu-project-ref

# Criar migration
supabase migration new create_tables

# Aplicar migrations
supabase db push

# Gerar tipos TypeScript (útil para referência)
supabase gen types typescript --schema public > database.types.ts
```

### Estrutura de Migrations

```
supabase/
├── migrations/
│   ├── 20260719000000_create_users.sql
│   ├── 20260719000001_create_properties.sql
│   ├── 20260719000002_create_lands.sql
│   ├── 20260719000003_create_favorites.sql
│   ├── 20260719000004_create_bookings.sql
│   ├── 20260719000005_create_messages.sql
│   ├── 20260719000006_create_notifications.sql
│   ├── 20260719000007_create_indexes.sql
│   └── 20260719000008_enable_rls.sql
├── seed.sql
└── config.toml
```

### Seed Data (Desenvolvimento)

```sql
-- seed.sql
INSERT INTO users (id_auth, name, email, role) VALUES
  ('uuid-admin', 'Admin Luar', 'admin@luarcompany.ao', 'admin'),
  ('uuid-agent', 'João Silva', 'joao@luarcompany.ao', 'agent');
```

---

## Dicas e Boas Práticas

### Performance

- Usar índices em colunas frequentemente filtradas
- Limitar o número de colunas no `select()` (evitar `select('*')`)
- Usar paginação (`range()`) para listas grandes
- Evitar queries N+1 (carregar dados relacionados em batch)

### Segurança

- Ativar RLS em todas as tabelas
- Usar políticas explícitas para cada operação
- Revisar políticas regularmente
- Não expor a `service_role` key

### Monitorização

- Usar o Dashboard do Supabase para monitorar queries
- Verificar logs de autenticação
- Monitorar uso de Storage
- Revisar métricas de performance de queries
