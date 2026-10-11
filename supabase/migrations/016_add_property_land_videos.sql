-- Migration 016: Vídeos de imóveis e terrenos
-- Adiciona tabelas property_videos / land_videos, bucket de storage e RLS.

-- ════════════════════════════════════════════════════════════════════
-- 1. Tabelas
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS property_videos (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  video_url   TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS land_videos (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  land_id   UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
  video_url TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_property_videos_property_id
  ON property_videos(property_id);
CREATE INDEX IF NOT EXISTS idx_land_videos_land_id
  ON land_videos(land_id);

-- ════════════════════════════════════════════════════════════════════
-- 2. RLS
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE property_videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE land_videos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Property videos read for anon" ON property_videos;
CREATE POLICY "Property videos read for anon" ON property_videos
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Property videos: agents and admins manage" ON property_videos;
CREATE POLICY "Property videos: agents and admins manage" ON property_videos
  FOR ALL USING (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND EXISTS (
        SELECT 1 FROM properties p
        WHERE p.id = property_videos.property_id
          AND p.agent_id = auth.uid()
      )
    )
  )
  WITH CHECK (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND EXISTS (
        SELECT 1 FROM properties p
        WHERE p.id = property_videos.property_id
          AND p.agent_id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "Land videos read for anon" ON land_videos;
CREATE POLICY "Land videos read for anon" ON land_videos
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Land videos: agents and admins manage" ON land_videos;
CREATE POLICY "Land videos: agents and admins manage" ON land_videos
  FOR ALL USING (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND EXISTS (
        SELECT 1 FROM lands l
        WHERE l.id = land_videos.land_id
          AND l.agent_id = auth.uid()
      )
    )
  )
  WITH CHECK (
    public.get_user_role() = 'admin'
    OR (
      public.get_user_role() = 'agent'
      AND EXISTS (
        SELECT 1 FROM lands l
        WHERE l.id = land_videos.land_id
          AND l.agent_id = auth.uid()
      )
    )
  );

-- ════════════════════════════════════════════════════════════════════
-- 3. Storage bucket (vídeos)
-- ════════════════════════════════════════════════════════════════════

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'property-videos',
  'property-videos',
  true,
  52428800,
  ARRAY[
    'video/mp4',
    'video/quicktime',
    'video/webm',
    'video/x-matroska',
    'video/3gpp',
    'video/x-msvideo'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ════════════════════════════════════════════════════════════════════
-- 4. Storage RLS policies
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Property videos: authenticated upload" ON storage.objects;
CREATE POLICY "Property videos: authenticated upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'property-videos');

DROP POLICY IF EXISTS "Property videos: public read" ON storage.objects;
CREATE POLICY "Property videos: public read" ON storage.objects
  FOR SELECT USING (bucket_id = 'property-videos');

DROP POLICY IF EXISTS "Property videos: delete own" ON storage.objects;
CREATE POLICY "Property videos: delete own" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'property-videos'
    AND owner_id::text = auth.uid()::text
  );
