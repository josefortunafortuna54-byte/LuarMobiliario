-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Custom ENUM types ────────────────────────────────────────────────

DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('client', 'agent', 'admin');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE category_type AS ENUM ('property', 'land');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE property_type AS ENUM ('house', 'apartment', 'office', 'warehouse', 'condo', 'shop');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE transaction_type AS ENUM ('sale', 'rent');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE land_type AS ENUM ('urban', 'agricultural', 'industrial', 'commercial', 'lot', 'farm');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ── Tables ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS users (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT NOT NULL,
  email      TEXT NOT NULL UNIQUE,
  phone      TEXT NOT NULL DEFAULT '',
  avatar_url TEXT NOT NULL DEFAULT '',
  role       user_role NOT NULL DEFAULT 'client',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS categories (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name      TEXT NOT NULL,
  icon      TEXT NOT NULL DEFAULT '',
  type      category_type NOT NULL DEFAULT 'property',
  count     INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS locations (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  city          TEXT NOT NULL,
  municipalities JSONB NOT NULL DEFAULT '[]'::jsonb,
  neighborhoods  JSONB NOT NULL DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS properties (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title          TEXT NOT NULL,
  description    TEXT NOT NULL DEFAULT '',
  type           property_type NOT NULL DEFAULT 'house',
  transaction_type transaction_type NOT NULL DEFAULT 'sale',
  price          NUMERIC NOT NULL DEFAULT 0,
  area           NUMERIC NOT NULL DEFAULT 0,
  bedrooms       INT NOT NULL DEFAULT 0,
  bathrooms      INT NOT NULL DEFAULT 0,
  garage         INT NOT NULL DEFAULT 0,
  address        TEXT NOT NULL DEFAULT '',
  city           TEXT NOT NULL DEFAULT '',
  municipality   TEXT NOT NULL DEFAULT '',
  neighborhood   TEXT NOT NULL DEFAULT '',
  latitude       DOUBLE PRECISION,
  longitude      DOUBLE PRECISION,
  features       JSONB NOT NULL DEFAULT '[]'::jsonb,
  agent_id       UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_name     TEXT NOT NULL DEFAULT '',
  agent_phone    TEXT NOT NULL DEFAULT '',
  is_featured    BOOLEAN NOT NULL DEFAULT false,
  is_available   BOOLEAN NOT NULL DEFAULT true,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS lands (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title          TEXT NOT NULL,
  description    TEXT NOT NULL DEFAULT '',
  type           land_type NOT NULL DEFAULT 'urban',
  transaction_type transaction_type NOT NULL DEFAULT 'sale',
  price          NUMERIC NOT NULL DEFAULT 0,
  area           NUMERIC NOT NULL DEFAULT 0,
  address        TEXT NOT NULL DEFAULT '',
  city           TEXT NOT NULL DEFAULT '',
  municipality   TEXT NOT NULL DEFAULT '',
  neighborhood   TEXT NOT NULL DEFAULT '',
  latitude       DOUBLE PRECISION,
  longitude      DOUBLE PRECISION,
  features       JSONB NOT NULL DEFAULT '[]'::jsonb,
  agent_id       UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_name     TEXT NOT NULL DEFAULT '',
  agent_phone    TEXT NOT NULL DEFAULT '',
  is_featured    BOOLEAN NOT NULL DEFAULT false,
  is_available   BOOLEAN NOT NULL DEFAULT true,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS property_images (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  image_url  TEXT NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS land_images (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  land_id   UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS favorites (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  land_id     UUID REFERENCES lands(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT favorites_user_property_unique UNIQUE (user_id, property_id),
  CONSTRAINT favorites_user_land_unique UNIQUE (user_id, land_id)
);

CREATE TABLE IF NOT EXISTS bookings (
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

CREATE TABLE IF NOT EXISTS messages (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  is_read     BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL DEFAULT '',
  is_read    BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Indexes ──────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_properties_agent_id ON properties(agent_id);
CREATE INDEX IF NOT EXISTS idx_properties_city ON properties(city);
CREATE INDEX IF NOT EXISTS idx_properties_municipality ON properties(municipality);
CREATE INDEX IF NOT EXISTS idx_properties_type ON properties(type);
CREATE INDEX IF NOT EXISTS idx_properties_transaction_type ON properties(transaction_type);
CREATE INDEX IF NOT EXISTS idx_properties_is_featured ON properties(is_featured);
CREATE INDEX IF NOT EXISTS idx_properties_is_available ON properties(is_available);
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties(price);
CREATE INDEX IF NOT EXISTS idx_properties_created_at ON properties(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_lands_agent_id ON lands(agent_id);
CREATE INDEX IF NOT EXISTS idx_lands_city ON lands(city);
CREATE INDEX IF NOT EXISTS idx_lands_municipality ON lands(municipality);
CREATE INDEX IF NOT EXISTS idx_lands_type ON lands(type);
CREATE INDEX IF NOT EXISTS idx_lands_transaction_type ON lands(transaction_type);
CREATE INDEX IF NOT EXISTS idx_lands_is_featured ON lands(is_featured);
CREATE INDEX IF NOT EXISTS idx_lands_is_available ON lands(is_available);
CREATE INDEX IF NOT EXISTS idx_lands_price ON lands(price);
CREATE INDEX IF NOT EXISTS idx_lands_created_at ON lands(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_property_images_property_id ON property_images(property_id);
CREATE INDEX IF NOT EXISTS idx_land_images_land_id ON land_images(land_id);

CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_property_id ON favorites(property_id);
CREATE INDEX IF NOT EXISTS idx_favorites_land_id ON favorites(land_id);

CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(date);

CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- ── RLS ──────────────────────────────────────────────────────────────

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE lands ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE land_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- users
CREATE POLICY "Users read for anon" ON users FOR SELECT USING (true);
CREATE POLICY "Users all for authenticated" ON users FOR ALL USING (auth.role() = 'authenticated');

-- categories
CREATE POLICY "Categories read for anon" ON categories FOR SELECT USING (true);
CREATE POLICY "Categories all for authenticated" ON categories FOR ALL USING (auth.role() = 'authenticated');

-- locations
CREATE POLICY "Locations read for anon" ON locations FOR SELECT USING (true);
CREATE POLICY "Locations all for authenticated" ON locations FOR ALL USING (auth.role() = 'authenticated');

-- properties
CREATE POLICY "Properties read for anon" ON properties FOR SELECT USING (true);
CREATE POLICY "Properties all for authenticated" ON properties FOR ALL USING (auth.role() = 'authenticated');

-- lands
CREATE POLICY "Lands read for anon" ON lands FOR SELECT USING (true);
CREATE POLICY "Lands all for authenticated" ON lands FOR ALL USING (auth.role() = 'authenticated');

-- property_images
CREATE POLICY "Property images read for anon" ON property_images FOR SELECT USING (true);
CREATE POLICY "Property images all for authenticated" ON property_images FOR ALL USING (auth.role() = 'authenticated');

-- land_images
CREATE POLICY "Land images read for anon" ON land_images FOR SELECT USING (true);
CREATE POLICY "Land images all for authenticated" ON land_images FOR ALL USING (auth.role() = 'authenticated');

-- favorites
CREATE POLICY "Favorites read for anon" ON favorites FOR SELECT USING (true);
CREATE POLICY "Favorites all for authenticated" ON favorites FOR ALL USING (auth.role() = 'authenticated');

-- bookings
CREATE POLICY "Bookings read for anon" ON bookings FOR SELECT USING (true);
CREATE POLICY "Bookings all for authenticated" ON bookings FOR ALL USING (auth.role() = 'authenticated');

-- messages
CREATE POLICY "Messages read for anon" ON messages FOR SELECT USING (true);
CREATE POLICY "Messages all for authenticated" ON messages FOR ALL USING (auth.role() = 'authenticated');

-- notifications
CREATE POLICY "Notifications read for anon" ON notifications FOR SELECT USING (true);
CREATE POLICY "Notifications all for authenticated" ON notifications FOR ALL USING (auth.role() = 'authenticated');

-- ── Seed: Categories ─────────────────────────────────────────────────

INSERT INTO categories (id, name, icon, type, count) VALUES
  (uuid_generate_v4(), 'Casas',           'home_outlined',           'property', 0),
  (uuid_generate_v4(), 'Apartamentos',    'apartment_rounded',       'property', 0),
  (uuid_generate_v4(), 'Terrenos',        'landscape_rounded',       'land',     0),
  (uuid_generate_v4(), 'Fazendas',        'agriculture_rounded',     'land',     0),
  (uuid_generate_v4(), 'Armazéns',        'warehouse_outlined',      'property', 0),
  (uuid_generate_v4(), 'Escritórios',     'business_outlined',       'property', 0),
  (uuid_generate_v4(), 'Lojas',           'storefront_outlined',     'property', 0),
  (uuid_generate_v4(), 'Comerciais',      'domain_outlined',         'property', 0);

-- ── Seed: Locations (Luanda) ────────────────────────────────────────

INSERT INTO locations (id, city, municipalities, neighborhoods) VALUES
  (uuid_generate_v4(),
   'Luanda',
   '["Ingombota","Maianga","Samba","Kilamba Kiaxi","Sé","Viana","Cazenga","Rangel","Samba Katembo","Ngola Kiluange","Miramar","Musbach","Talatona","Kilamba"]'::jsonb,
   '["Miramar","Maianga","Samba","Viana","Kilamba","Cazenga","Rangel","Ingombota","Coqueiros","Chicala","Talatona","Benfica","Cacuaco","Maconde","Prenda","Cidadela","Vila Alice","São Paulo","Maculusso","Ilha do Cabo","Mussulo","Barra do Cuanza"]'::jsonb);
