-- ════════════════════════════════════════════════════════════════════
-- SEED DE DEMONSTRAÇÃO — VÍDEOS (companheiro de seed_demo.sql)
-- ════════════════════════════════════════════════════════════════════
--
-- O que faz:
--   • Associa 1 vídeo a 11 imóveis (a loja fica só com fotos) e a os
--     7 terrenos do seed_demo.sql. Fonte: Mixkit (licença livre,
--     sem watermark), MP4 720p — todos verificados com HTTP 200/206.
--   • Idempotente: apaga primeiro os vídeos dos anúncios demo
--     (d0000001-*/d0000002-*) e volta a inserir.
--
-- Como executar (depois de seed_demo.sql):
--   Remoto: supabase db push --include-seed (requer `supabase login` e
--           [db.seed] em config.toml — já com este ficheiro incluído).
--   Alternativa: Supabase Dashboard → SQL Editor → colar e Run.
--
-- Como reverter:
--   DELETE FROM property_videos WHERE property_id::text LIKE 'd0000001-%';
--   DELETE FROM land_videos    WHERE land_id::text     LIKE 'd0000002-%';
-- ════════════════════════════════════════════════════════════════════

DELETE FROM property_videos WHERE property_id::text LIKE 'd0000001-%';
DELETE FROM land_videos    WHERE land_id::text     LIKE 'd0000002-%';

-- ════════════════════════════════════════════════════════════════════
-- 1. VÍDEOS DOS IMÓVEIS (1 vídeo em 11 imóveis; a loja fica só com fotos)
-- ════════════════════════════════════════════════════════════════════
INSERT INTO property_videos (property_id, video_url) VALUES
  ('d0000001-0000-4000-8000-000000000001', 'https://assets.mixkit.co/videos/47286/47286-720.mp4'),
  ('d0000001-0000-4000-8000-000000000002', 'https://assets.mixkit.co/videos/3090/3090-720.mp4'),
  ('d0000001-0000-4000-8000-000000000003', 'https://assets.mixkit.co/videos/4029/4029-720.mp4'),
  ('d0000001-0000-4000-8000-000000000004', 'https://assets.mixkit.co/videos/3110/3110-720.mp4'),
  ('d0000001-0000-4000-8000-000000000005', 'https://assets.mixkit.co/videos/25991/25991-720.mp4'),
  ('d0000001-0000-4000-8000-000000000006', 'https://assets.mixkit.co/videos/49845/49845-720.mp4'),
  ('d0000001-0000-4000-8000-000000000008', 'https://assets.mixkit.co/videos/23011/23011-720.mp4'),
  ('d0000001-0000-4000-8000-000000000009', 'https://assets.mixkit.co/videos/5008/5008-720.mp4'),
  ('d0000001-0000-4000-8000-000000000010', 'https://assets.mixkit.co/videos/3111/3111-720.mp4'),
  ('d0000001-0000-4000-8000-000000000011', 'https://assets.mixkit.co/videos/21226/21226-720.mp4'),
  ('d0000001-0000-4000-8000-000000000012', 'https://assets.mixkit.co/videos/2168/2168-720.mp4');

-- ════════════════════════════════════════════════════════════════════
-- 2. VÍDEOS DOS TERRENOS (1 vídeo por terreno)
-- ════════════════════════════════════════════════════════════════════
INSERT INTO land_videos (land_id, video_url) VALUES
  ('d0000002-0000-4000-8000-000000000001', 'https://assets.mixkit.co/videos/41389/41389-720.mp4'),
  ('d0000002-0000-4000-8000-000000000002', 'https://assets.mixkit.co/videos/34035/34035-720.mp4'),
  ('d0000002-0000-4000-8000-000000000003', 'https://assets.mixkit.co/videos/4010/4010-720.mp4'),
  ('d0000002-0000-4000-8000-000000000004', 'https://assets.mixkit.co/videos/39462/39462-720.mp4'),
  ('d0000002-0000-4000-8000-000000000005', 'https://assets.mixkit.co/videos/44923/44923-720.mp4'),
  ('d0000002-0000-4000-8000-000000000006', 'https://assets.mixkit.co/videos/41576/41576-720.mp4'),
  ('d0000002-0000-4000-8000-000000000007', 'https://assets.mixkit.co/videos/45782/45782-720.mp4');

-- ════════════════════════════════════════════════════════════════════
-- 3. RESUMO
-- ════════════════════════════════════════════════════════════════════
SELECT
  (SELECT count(*) FROM property_videos v
     JOIN properties p ON p.id = v.property_id
    WHERE p.id::text LIKE 'd0000001-%') AS videos_imoveis,
  (SELECT count(*) FROM land_videos v
     JOIN lands l ON l.id = v.land_id
    WHERE l.id::text LIKE 'd0000002-%') AS videos_terrenos;
