-- Migration 005: Storage buckets + cleanup
-- Corrige: bucket de imagens, RLS storage, limpeza de dados, performance

-- ════════════════════════════════════════════════════════════════════
-- 0. Extensions
-- ════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ════════════════════════════════════════════════════════════════════
-- 1. Storage Buckets (property-images + avatars)
-- ════════════════════════════════════════════════════════════════════

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'property-images',
  'property-images',
  true,
  10485760,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ════════════════════════════════════════════════════════════════════
-- 2. Storage RLS Policies
-- ════════════════════════════════════════════════════════════════════

-- Property images
DROP POLICY IF EXISTS "Property images: authenticated upload" ON storage.objects;
CREATE POLICY "Property images: authenticated upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'property-images');

DROP POLICY IF EXISTS "Property images: public read" ON storage.objects;
CREATE POLICY "Property images: public read" ON storage.objects
  FOR SELECT USING (bucket_id = 'property-images');

DROP POLICY IF EXISTS "Property images: delete own" ON storage.objects;
CREATE POLICY "Property images: delete own" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'property-images');

-- Avatars
DROP POLICY IF EXISTS "Avatars: authenticated upload" ON storage.objects;
CREATE POLICY "Avatars: authenticated upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Avatars: public read" ON storage.objects;
CREATE POLICY "Avatars: public read" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Avatars: delete own" ON storage.objects;
CREATE POLICY "Avatars: delete own" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'avatars');

-- ════════════════════════════════════════════════════════════════════
-- 3. Fix: limpar agent_id com valor nil UUID (resquicio do bug vazio)
-- ════════════════════════════════════════════════════════════════════

UPDATE properties SET agent_id = NULL WHERE agent_id = '00000000-0000-0000-0000-000000000000';
UPDATE lands SET agent_id = NULL WHERE agent_id = '00000000-0000-0000-0000-000000000000';

-- ════════════════════════════════════════════════════════════════════
-- 4. Indexes para busca por titulo (LIKE / ILIKE)
-- ════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_properties_title_trgm
  ON properties USING gin(title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_lands_title_trgm
  ON lands USING gin(title gin_trgm_ops);

-- ════════════════════════════════════════════════════════════════════
-- 5. Garantir triggers updated_at (idempotente)
-- ════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TRIGGER update_properties_updated_at
    BEFORE UPDATE ON public.properties
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TRIGGER update_lands_updated_at
    BEFORE UPDATE ON public.lands
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TRIGGER update_partners_updated_at
    BEFORE UPDATE ON public.partners
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN null;
END $$;
