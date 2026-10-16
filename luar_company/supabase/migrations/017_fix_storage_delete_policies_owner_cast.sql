-- Migration 017: corrige policies de DELETE de storage (cast do owner_id)
-- Contexto: no projeto, storage.objects.owner_id passou a ser TEXT, mas as
-- policies criadas na migration 007 comparavam owner_id = auth.uid() (uuid),
-- o que falha com "operator does not exist: text = uuid". Recria-as com um
-- cast type-agnóstico (::text), seguro em qualquer versão do storage.

DROP POLICY IF EXISTS "Property images: delete own" ON storage.objects;
CREATE POLICY "Property images: delete own" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'property-images'
    AND owner_id::text = auth.uid()::text
  );

DROP POLICY IF EXISTS "Avatars: delete own" ON storage.objects;
CREATE POLICY "Avatars: delete own" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND owner_id::text = auth.uid()::text
  );
