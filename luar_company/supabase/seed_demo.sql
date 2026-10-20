-- ════════════════════════════════════════════════════════════════════
-- SEED DE DEMONSTRAÇÃO — Imóveis + Terrenos (Luar Mobiliário)
-- ════════════════════════════════════════════════════════════════════
--
-- O que faz:
--   • Insere 12 imóveis (houses/apartments/office/shop/warehouse/condo)
--     e 7 terrenos (urban/agricultural/lot/industrial/farm/commercial)
--     com fotos reais (Unsplash), preços em AOA e locais de Angola.
--     (Os vídeos de demonstração estão no companheiro seed_demo_videos.sql.)
--   • Marca 5 anúncios como "featured" (carrossel da Home) — todos com
--     is_available = true (aparecem em Home, Descobrir, Pesquisa e Mapa).
--   • É idempotente: usa UUIDs fixos `d0000001-…` / `d0000002-…` e apaga
--     primeiro os anúncios de demonstração (cascade remove as imagens).
--     Os dados reais da app nunca são tocados.
--
-- Como executar:
--   Remoto: supabase db push --include-seed (requer `supabase login` e
--           [db.seed] em config.toml, já configurado) — corre como postgres.
--   Alternativa: Supabase Dashboard → SQL Editor → colar e Run.
--   (Os INSERTs não passam pela RLS de anon, por isso é preciso correr
--    com a sessão do Dashboard / CLI / service_role.)
--   Nota: os statements são individuais (sem BEGIN/COMMIT) para
--   compatibilidade com o executor de seed do CLI.
--
-- Como reverter:
--   DELETE FROM property_videos WHERE property_id::text LIKE 'd0000001-%';
--   DELETE FROM property_images WHERE property_id::text LIKE 'd0000001-%';
--   DELETE FROM properties     WHERE id::text          LIKE 'd0000001-%';
--   DELETE FROM land_videos    WHERE land_id::text     LIKE 'd0000002-%';
--   DELETE FROM land_images    WHERE land_id::text     LIKE 'd0000002-%';
--   DELETE FROM lands          WHERE id::text          LIKE 'd0000002-%';
-- ════════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════════
-- 1. LIMPEZA DOS ANÚNCIOS DE DEMONSTRAÇÃO (apenas os nossos UUIDs)
-- ════════════════════════════════════════════════════════════════════
DELETE FROM property_images WHERE property_id::text LIKE 'd0000001-%';
DELETE FROM property_videos WHERE property_id::text LIKE 'd0000001-%';
DELETE FROM properties      WHERE id::text          LIKE 'd0000001-%';
DELETE FROM land_images     WHERE land_id::text     LIKE 'd0000002-%';
DELETE FROM land_videos     WHERE land_id::text     LIKE 'd0000002-%';
DELETE FROM lands           WHERE id::text          LIKE 'd0000002-%';

-- ════════════════════════════════════════════════════════════════════
-- 2. IMÓVEIS (12)
-- ════════════════════════════════════════════════════════════════════
INSERT INTO properties (
  id, title, description, type, transaction_type, price, area,
  bedrooms, bathrooms, garage, address, city, province, municipality,
  neighborhood, latitude, longitude, features, agent_name, agent_phone,
  agent_verified, is_featured, is_available, created_at, updated_at
) VALUES
(
  'd0000001-0000-4000-8000-000000000001',
  'Vivenda T4 com piscina em Talatona',
  'Vivenda de luxo com 4 suítes, piscina privativa, jardim paisagístico e gerador completo. Condomínio fechado com segurança 24 horas, a 5 minutos do Belas Shopping.',
  'house', 'sale', 185000000, 450,
  4, 5, 2, 'Condomínio Belas Business Park, Talatona',
  'Luanda', 'Luanda', 'Belas', 'Talatona', -8.9186, 13.1836,
  '["Piscina","Gerador","Ar condicionado","Segurança 24h","Jardim","Suites"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, true, true,
  now() - interval '2 days', now() - interval '2 days'
),
(
  'd0000001-0000-4000-8000-000000000002',
  'Casa T4 com quintal no Benfica',
  'Casa espaçosa em zona residencial calma, com 4 quartos, sala ampla, cozinha equipada e quintal para churrascos. Próxima a escolas e mercados.',
  'house', 'sale', 95000000, 320,
  4, 3, 2, 'Rua 21 de Janeiro, Benfica',
  'Luanda', 'Luanda', 'Belas', 'Benfica', -9.0215, 13.2074,
  '["Quintal","Garagem dupla","Água quente","Varanda"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '4 days', now() - interval '4 days'
),
(
  'd0000001-0000-4000-8000-000000000003',
  'Apartamento T3 mobilado no Miramar',
  'Apartamento mobilado e pronto a habitar, com vista para a baía de Luanda, 3 quartos, 2 casas de banho, varanda generosa e estacionamento.',
  'apartment', 'rent', 850000, 165,
  3, 2, 1, 'Rua António Tchieta, Miramar',
  'Luanda', 'Luanda', 'Luanda', 'Miramar', -8.8098, 13.2400,
  '["Mobilado","Vista mar","Elevador","Estacionamento","Ar condicionado"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, true, true,
  now() - interval '1 day', now() - interval '1 day'
),
(
  'd0000001-0000-4000-8000-000000000004',
  'Apartamento T2 novo no Kilamba',
  'Apartamento novo na 3ª fase do Kilamba, 2 quartos, sala comum, cozinha moderna e duas casas de banho. Prédio com elevador e estacionamento.',
  'apartment', 'sale', 65000000, 95,
  2, 2, 1, 'Quarto Bairro, Kilamba',
  'Luanda', 'Luanda', 'Icolo e Bengo', 'Kilamba', -8.9907, 13.2688,
  '["Novo","Elevador","Estacionamento","Água e luz inclusos"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '6 days', now() - interval '6 days'
),
(
  'd0000001-0000-4000-8000-000000000005',
  'Apartamento T4 mobilado no Belas',
  'Apartamento T4 nos Belas Business Park, ideal para famílias ou representações de empresa. Mobilado, 4 quartos, 3 casas de banho e duas varandas.',
  'apartment', 'rent', 1900000, 210,
  4, 3, 2, 'Belas Business Park, Belas',
  'Luanda', 'Luanda', 'Belas', 'Talatona', -8.9966, 13.1938,
  '["Mobilado","Piscina do condomínio","Ginásio","Segurança 24h"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '8 days', now() - interval '8 days'
),
(
  'd0000001-0000-4000-8000-000000000006',
  'Escritório open space no Ingombota',
  'Escritório open space de 220 m² na baixa de Luanda, com 3 salas de reunião, receção, instalações sanitárias e ar central. Edifício com elevador e gerador.',
  'office', 'rent', 2500000, 220,
  0, 1, 0, 'Rua Rainha Ginga, Ingombota',
  'Luanda', 'Luanda', 'Luanda', 'Ingombota', -8.8147, 13.2330,
  '["Ar central","Gerador","Elevador","Salas de reunião","Fibra óptica"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, true, true,
  now() - interval '3 days', now() - interval '3 days'
),
(
  'd0000001-0000-4000-8000-000000000007',
  'Loja em esquina na Rua Rainha Ginga',
  'Loja com esquina dupla, vitrines amplas e 80 m² úteis, numa das ruas com mais movimento da baixa. Ideal para roupa, calçados ou ótica.',
  'shop', 'rent', 1200000, 80,
  0, 1, 0, 'Rua Rainha Ginga, Ingombota',
  'Luanda', 'Luanda', 'Luanda', 'Ingombota', -8.8160, 13.2344,
  '["Vitrine dupla","Movimento peão","Água e luz"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '9 days', now() - interval '9 days'
),
(
  'd0000001-0000-4000-8000-000000000008',
  'Armazém classe A na Viana',
  'Armazém de 1.200 m² com 8 metros de altura livre, docas de carregamento, pátio para camiões e escritório anexo. Acesso direto à EN-100.',
  'warehouse', 'rent', 3500000, 1200,
  0, 1, 0, 'Zona Industrial da Viana, Viana',
  'Luanda', 'Luanda', 'Viana', 'Viana', -8.9036, 13.3730,
  '["Docas","Pátio para camiões","Escritório","Segurança 24h"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '11 days', now() - interval '11 days'
),
(
  'd0000001-0000-4000-8000-000000000009',
  'Casa T3 em condomínio na Praia Morena',
  'Casa dentro de condomínio fechado a 2 minutos da Praia Morena, em Benguela. 3 quartos, 3 casas de banho, piscina comunitária e jardim.',
  'condo', 'sale', 120000000, 280,
  3, 3, 2, 'Condomínio Baía Azul, Praia Morena',
  'Benguela', 'Benguela', 'Benguela', 'Praia Morena', -12.5783, 13.4073,
  '["Piscina comunitária","Condomínio fechado","Perto da praia","Gerador"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '5 days', now() - interval '5 days'
),
(
  'd0000001-0000-4000-8000-000000000010',
  'Moradia T5 no Huambo',
  'Moradia com 5 quartos, sala de estar dupla, cozinha americana, garagem para 3 carros e quintal amplo. Bairro tranquilo a 10 minutos do centro.',
  'house', 'sale', 75000000, 420,
  5, 4, 3, 'Rua do Sumbe, Centro',
  'Huambo', 'Huambo', 'Huambo', 'Centro', -12.7680, 15.7420,
  '["Quintal","Garagem triplo","Lareira","Água quente"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '13 days', now() - interval '13 days'
),
(
  'd0000001-0000-4000-8000-000000000011',
  'Escritório com varanda no Lubango',
  'Escritório de 120 m² no centro do Lubango, com duas salas, sala de reunião, copa e varanda com vista para a cidade. Edifício com elevador e estacionamento.',
  'office', 'rent', 1500000, 120,
  0, 1, 0, 'Rua Pinheiro Chagas, Lubango',
  'Huíla', 'Huíla', 'Lubango', 'Centro', -14.9310, 13.4900,
  '["Varanda","Elevador","Estacionamento","Ar condicionado"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '15 days', now() - interval '15 days'
),
(
  'd0000001-0000-4000-8000-000000000012',
  'Casa T3 mobilada no Cabo Ledo',
  'Casa mobilada perto da praia do Cabo Ledo, com 3 quartos, piscina privativa e área exterior ajardinada. Ideal para férias ou alojamento turístico.',
  'house', 'sale', 88000000, 250,
  3, 2, 2, 'Estrada do Cabo Ledo, Nambuangongo',
  'Luanda', 'Luanda', 'Nambuangongo', 'Cabo Ledo', -9.1900, 13.1600,
  '["Piscina","Perto da praia","Mobilado","Área exterior"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '7 days', now() - interval '7 days'
);

-- ════════════════════════════════════════════════════════════════════
-- 3. IMAGENS DOS IMÓVEIS (2–3 por anúncio)
-- ════════════════════════════════════════════════════════════════════
INSERT INTO property_images (property_id, image_url, is_primary) VALUES
  ('d0000001-0000-4000-8000-000000000001', 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=1200&q=70&auto=format&fit=crop',  true),
  ('d0000001-0000-4000-8000-000000000001', 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200&q=70&auto=format&fit=crop',   false),
  ('d0000001-0000-4000-8000-000000000001', 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=1200&q=70&auto=format&fit=crop',  false),
  ('d0000001-0000-4000-8000-000000000002', 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=1200&q=70&auto=format&fit=crop',   true),
  ('d0000001-0000-4000-8000-000000000002', 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=1200&q=70&auto=format&fit=crop',        false),
  ('d0000001-0000-4000-8000-000000000002', 'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=1200&q=70&auto=format&fit=crop',    false),
  ('d0000001-0000-4000-8000-000000000003', 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200&q=70&auto=format&fit=crop',    true),
  ('d0000001-0000-4000-8000-000000000003', 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=1200&q=70&auto=format&fit=crop',      false),
  ('d0000001-0000-4000-8000-000000000003', 'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=1200&q=70&auto=format&fit=crop',    false),
  ('d0000001-0000-4000-8000-000000000004', 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200&q=70&auto=format&fit=crop',  true),
  ('d0000001-0000-4000-8000-000000000004', 'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?w=1200&q=70&auto=format&fit=crop',         false),
  ('d0000001-0000-4000-8000-000000000005', 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=1200&q=70&auto=format&fit=crop',   true),
  ('d0000001-0000-4000-8000-000000000005', 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=1200&q=70&auto=format&fit=crop',      false),
  ('d0000001-0000-4000-8000-000000000006', 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1200&q=70&auto=format&fit=crop',   true),
  ('d0000001-0000-4000-8000-000000000006', 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=1200&q=70&auto=format&fit=crop',   false),
  ('d0000001-0000-4000-8000-000000000006', 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=1200&q=70&auto=format&fit=crop',   false),
  ('d0000001-0000-4000-8000-000000000007', 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&q=70&auto=format&fit=crop',         true),
  ('d0000001-0000-4000-8000-000000000007', 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=1200&q=70&auto=format&fit=crop',         false),
  ('d0000001-0000-4000-8000-000000000008', 'https://images.unsplash.com/photo-1553413077-190dd305871c?w=1200&q=70&auto=format&fit=crop',      true),
  ('d0000001-0000-4000-8000-000000000008', 'https://images.unsplash.com/photo-1565610222536-ef125c59da2e?w=1200&q=70&auto=format&fit=crop',      false),
  ('d0000001-0000-4000-8000-000000000009', 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=1200&q=70&auto=format&fit=crop', true),
  ('d0000001-0000-4000-8000-000000000009', 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=1200&q=70&auto=format&fit=crop',     false),
  ('d0000001-0000-4000-8000-000000000010', 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=1200&q=70&auto=format&fit=crop',         true),
  ('d0000001-0000-4000-8000-000000000010', 'https://images.unsplash.com/photo-1592595896551-12b371d546d5?w=1200&q=70&auto=format&fit=crop', false),
  ('d0000001-0000-4000-8000-000000000011', 'https://images.unsplash.com/photo-1541746972996-4e0b0f43e02a?w=1200&q=70&auto=format&fit=crop',   true),
  ('d0000001-0000-4000-8000-000000000011', 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=1200&q=70&auto=format&fit=crop', false),
  ('d0000001-0000-4000-8000-000000000012', 'https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=1200&q=70&auto=format&fit=crop', true),
  ('d0000001-0000-4000-8000-000000000012', 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=1200&q=70&auto=format&fit=crop',   false);


-- ════════════════════════════════════════════════════════════════════
-- 4. TERRENOS (7)
-- ════════════════════════════════════════════════════════════════════
INSERT INTO lands (
  id, title, description, type, transaction_type, price, area,
  address, city, province, municipality, neighborhood,
  latitude, longitude, features, agent_name, agent_phone,
  agent_verified, is_featured, is_available, created_at, updated_at
) VALUES
(
  'd0000002-0000-4000-8000-000000000001',
  'Terreno urbano de 1.000 m² no Sequele',
  'Terreno plano e cercado no Sequele, com 1.000 m², acesso asfaltado, água e luz no limite do lote. Documentação pronta para escritura.',
  'urban', 'sale', 45000000, 1000,
  'Estrada do Sequele, Cacuaco', 'Luanda', 'Luanda', 'Cacuaco', 'Sequele',
  -8.9200, 13.1900,
  '["Cercado","Água","Luz","Acesso asfaltado"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, true, true,
  now() - interval '3 days', now() - interval '3 days'
),
(
  'd0000002-0000-4000-8000-000000000002',
  'Terreno agrícola de 5 hectares no Catete',
  '5 hectares de terreno agrícola fértil no Catete, com poço próprio e acesso para maquinaria. Ideal para hortícolas, bananeiras ou criação.',
  'agricultural', 'sale', 60000000, 50000,
  'Estrada Nacional 1, Catete', 'Luanda', 'Luanda', 'Icolo e Bengo', 'Catete',
  -9.0500, 13.1000,
  '["Poço","Plano","Fértil","Acesso maquinaria"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, true, true,
  now() - interval '5 days', now() - interval '5 days'
),
(
  'd0000002-0000-4000-8000-000000000003',
  'Lote de 400 m² em condomínio no Ramiro',
  'Lote de 400 m² dentro de condomínio privativo no Ramiro, com infraestrutura completa (água, esgoto e iluminação) e segurança permanente.',
  'lot', 'sale', 28000000, 400,
  'Condomínio Vale Verde, Ramiro', 'Luanda', 'Luanda', 'Belas', 'Ramiro',
  -8.9400, 13.2300,
  '["Condomínio fechado","Infraestrutura pronta","Segurança 24h"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '10 days', now() - interval '10 days'
),
(
  'd0000002-0000-4000-8000-000000000004',
  'Terreno industrial de 5.000 m² na Viana',
  'Terreno industrial junto à EN-100, com 5.000 m², terreno estável para pavilhões, acesso para pesados e todas as redes no limite.',
  'industrial', 'sale', 250000000, 50000,
  'Zona Industrial, Viana', 'Luanda', 'Luanda', 'Viana', 'Viana',
  -8.9036, 13.3730,
  '["Acesso pesados","Redes no limite","Plano","EN-100"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', true, false, true,
  now() - interval '12 days', now() - interval '12 days'
),
(
  'd0000002-0000-4000-8000-000000000005',
  'Quinta com 12 hectares no Calumbo',
  'Quinta de 12 hectares com casa de apoio, curral, poço e árvores de fruta já produzidas. A 20 minutos do centro de Luanda.',
  'farm', 'sale', 180000000, 120000,
  'Estrada do Calumbo, Talatona', 'Luanda', 'Luanda', 'Belas', 'Calumbo',
  -9.1300, 13.1600,
  '["Casa de apoio","Poço","Curral","Árvores de fruta"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', false, false, true,
  now() - interval '14 days', now() - interval '14 days'
),
(
  'd0000002-0000-4000-8000-000000000006',
  'Terreno comercial de 800 m² no Lubango',
  'Terreno de esquina em avenida comercial do Lubango, com 800 m² e frente de 25 metros. Perfeito para supermercado, farmácia ou showroom.',
  'commercial', 'sale', 95000000, 800,
  'Avenida da Liberdade, Lubango', 'Huíla', 'Huíla', 'Lubango', 'Centro',
  -14.9310, 13.4900,
  '["Esquina","25m de frente","Zona comercial","Água e luz"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', false, false, true,
  now() - interval '16 days', now() - interval '16 days'
),
(
  'd0000002-0000-4000-8000-000000000007',
  'Terreno agrícola de 8 hectares no Ebo (renda)',
  '8 hectares arrendados por ano no Ebo, Kwanza Sul, com estrada de acesso e poço. Renda anual, contrato mínimo de 5 anos.',
  'agricultural', 'rent', 1500000, 80000,
  'Estrada do Ebo, Kwanza Sul', 'Kwanza Sul', 'Kwanza Sul', 'Ebo', 'Ebo',
  -9.9600, 14.1800,
  '["Estrada de acesso","Poço","Contrato longo"]'::jsonb,
  'Luar Mobiliário', '+244 923 456 789', false, false, true,
  now() - interval '18 days', now() - interval '18 days'
);

-- ════════════════════════════════════════════════════════════════════
-- 5. IMAGENS DOS TERRENOS (2 por anúncio)
-- ════════════════════════════════════════════════════════════════════
INSERT INTO land_images (land_id, image_url, is_primary) VALUES
  ('d0000002-0000-4000-8000-000000000001', 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1200&q=70&auto=format&fit=crop', true),
  ('d0000002-0000-4000-8000-000000000001', 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1200&q=70&auto=format&fit=crop',       false),
  ('d0000002-0000-4000-8000-000000000002', 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=1200&q=70&auto=format&fit=crop',          true),
  ('d0000002-0000-4000-8000-000000000002', 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=1200&q=70&auto=format&fit=crop',        false),
  ('d0000002-0000-4000-8000-000000000003', 'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=1200&q=70&auto=format&fit=crop',      true),
  ('d0000002-0000-4000-8000-000000000003', 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1200&q=70&auto=format&fit=crop',      false),
  ('d0000002-0000-4000-8000-000000000004', 'https://images.unsplash.com/photo-1470115636492-6d2b56f9146d?w=1200&q=70&auto=format&fit=crop', true),
  ('d0000002-0000-4000-8000-000000000004', 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=1200&q=70&auto=format&fit=crop',        false),
  ('d0000002-0000-4000-8000-000000000005', 'https://images.unsplash.com/photo-1444858291040-58f756a3bdd6?w=1200&q=70&auto=format&fit=crop',         true),
  ('d0000002-0000-4000-8000-000000000005', 'https://images.unsplash.com/photo-1418065460487-3e41a6c84dc5?w=1200&q=70&auto=format&fit=crop',       false),
  ('d0000002-0000-4000-8000-000000000006', 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1200&q=70&auto=format&fit=crop',           true),
  ('d0000002-0000-4000-8000-000000000006', 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1200&q=70&auto=format&fit=crop',       false),
  ('d0000002-0000-4000-8000-000000000007', 'https://images.unsplash.com/photo-1523712999610-f77fbcfc3843?w=1200&q=70&auto=format&fit=crop',         true),
  ('d0000002-0000-4000-8000-000000000007', 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=1200&q=70&auto=format&fit=crop',         false);


-- ════════════════════════════════════════════════════════════════════
-- 6. RESUMO
-- ════════════════════════════════════════════════════════════════════
SELECT
  (SELECT count(*) FROM properties WHERE id::text LIKE 'd0000001-%') AS imoveis,
  (SELECT count(*) FROM property_images i
     JOIN properties p ON p.id = i.property_id
    WHERE p.id::text LIKE 'd0000001-%')                              AS imagens_imoveis,
  (SELECT count(*) FROM lands WHERE id::text LIKE 'd0000002-%')      AS terrenos,
  (SELECT count(*) FROM land_images i
     JOIN lands l ON l.id = i.land_id
    WHERE l.id::text LIKE 'd0000002-%')                              AS imagens_terrenos,
  (SELECT count(*) FROM properties
    WHERE id::text LIKE 'd0000001-%' AND is_featured)
  + (SELECT count(*) FROM lands
    WHERE id::text LIKE 'd0000002-%' AND is_featured)                AS destaque;

