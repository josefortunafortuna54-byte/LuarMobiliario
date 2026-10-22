-- ════════════════════════════════════════════════════════════════════════
-- Verificação E2E das policies RLS de favoritos (migration 032)
-- ════════════════════════════════════════════════════════════════════════
--
-- Executar contra a base de dados como `postgres`:
--   supabase db push --include-seed
-- (com [db.seed].sql_paths a apontar para este ficheiro)
--
-- O script cria dois utilizadores cliente temporários em auth.users
-- (public.users exige FK para auth.users; o trigger on_auth_user_created
-- cria o perfil automaticamente), executa as verificações em nome de cada
-- um e no final remove-os — o cascade limpa public.users e public.favorites.
--
-- Saída: RAISE NOTICE 'VERIFY [n] ...' por verificação e um resumo final.
-- ════════════════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_prop        uuid;
  v_land        uuid;
  v_uid_a       uuid := gen_random_uuid();
  v_uid_b       uuid := gen_random_uuid();
  v_email_a     text := 'verify-032-a@guest.luar';
  v_email_b     text := 'verify-032-b@guest.luar';
  v_rows        integer;
  v_total       integer;
  v_pass        integer := 0;
  v_fail        integer := 0;
BEGIN
  SELECT id INTO v_prop FROM public.properties ORDER BY id LIMIT 1;
  SELECT id INTO v_land FROM public.lands ORDER BY id LIMIT 1;

  IF v_prop IS NULL THEN
    RAISE EXCEPTION 'VERIFY: não há imóveis na base de dados';
  END IF;

  -- O email "@guest.luar" é aceite pelo trigger prevent_other_user_insert,
  -- que bloqueia a criação de perfis por quem não é admin.
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
  )
  VALUES
    (v_uid_a, 'authenticated', 'authenticated', v_email_a, '', now(),
     '{"provider":"email","providers":["email"]}', '{"name":"Verificacao A"}', now(), now()),
    (v_uid_b, 'authenticated', 'authenticated', v_email_b, '', now(),
     '{"provider":"email","providers":["email"]}', '{"name":"Verificacao B"}', now(), now());

  RAISE NOTICE 'VERIFY: utilizadores temporários criados (%) e (%)', v_uid_a, v_uid_b;

  -- ────────────────────────────────────────────────────────────────────────
  -- [1] INSERT de favorito pelo próprio utilizador (policy "insert own")
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('sub', v_uid_a::text, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;

    INSERT INTO public.favorites (user_id, property_id)
    VALUES (v_uid_a, v_prop);

    SELECT count(*) INTO v_rows FROM public.favorites WHERE user_id = v_uid_a;
    IF v_rows = 1 THEN
      RAISE NOTICE 'VERIFY [1] INSERT do proprio favorito: OK';
      v_pass := v_pass + 1;
    ELSE
      RAISE NOTICE 'VERIFY [1] INSERT do proprio favorito: FALHOU (linhas=%)', v_rows;
      v_fail := v_fail + 1;
    END IF;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [1] INSERT do proprio favorito: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [2] INSERT duplicado → violação da unique constraint (comportamento
  --     antigo do app). O caminho usado pelo app é o ON CONFLICT (upsert),
  --     equivalente ao Prefer: resolution=merge-duplicates do PostgREST.
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('sub', v_uid_a::text, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;

    INSERT INTO public.favorites (user_id, property_id)
    VALUES (v_uid_a, v_prop);
    RAISE NOTICE 'VERIFY [2] INSERT duplicado: FALHOU (não devia ser aceite)';
    v_fail := v_fail + 1;
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'VERIFY [2] INSERT duplicado rejeitado pela unique constraint: OK';
    v_pass := v_pass + 1;
  WHEN others THEN
    RAISE NOTICE 'VERIFY [2] INSERT duplicado: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [3] Upsert (ON CONFLICT DO UPDATE) → 1 linha, created_at preservado
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('sub', v_uid_a::text, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;

    INSERT INTO public.favorites (user_id, property_id)
    VALUES (v_uid_a, v_prop)
    ON CONFLICT (user_id, property_id) DO UPDATE SET created_at = public.favorites.created_at;

    SELECT count(*) INTO v_rows FROM public.favorites WHERE user_id = v_uid_a;
    IF v_rows = 1 THEN
      RAISE NOTICE 'VERIFY [3] upsert sem duplicar: OK';
      v_pass := v_pass + 1;
    ELSE
      RAISE NOTICE 'VERIFY [3] upsert sem duplicar: FALHOU (linhas=%)', v_rows;
      v_fail := v_fail + 1;
    END IF;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [3] upsert sem duplicar: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [4] Leitura dos próprios favoritos
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('sub', v_uid_a::text, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;

    SELECT count(*) INTO v_rows FROM public.favorites WHERE user_id = v_uid_a;
    IF v_rows = 1 THEN
      RAISE NOTICE 'VERIFY [4] le os proprios favoritos: OK';
      v_pass := v_pass + 1;
    ELSE
      RAISE NOTICE 'VERIFY [4] le os proprios favoritos: FALHOU (linhas=%)', v_rows;
      v_fail := v_fail + 1;
    END IF;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [4] le os proprios favoritos: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [5] Privacidade: o utilizador A não vê os favoritos do B
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('sub', v_uid_a::text, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;

    SELECT count(*) INTO v_rows FROM public.favorites WHERE user_id = v_uid_b;
    IF v_rows = 0 THEN
      RAISE NOTICE 'VERIFY [5] nao ve os favoritos de outro cliente: OK';
      v_pass := v_pass + 1;
    ELSE
      RAISE NOTICE 'VERIFY [5] nao ve os favoritos de outro cliente: FALHOU (linhas=%)', v_rows;
      v_fail := v_fail + 1;
    END IF;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [5] nao ve os favoritos de outro cliente: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [6] Anónimo: não lê favoritos
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('role', 'anon')::text, true);
    SET LOCAL ROLE anon;

    SELECT count(*) INTO v_rows FROM public.favorites;
    IF v_rows = 0 THEN
      RAISE NOTICE 'VERIFY [6] anonimo nao le favoritos: OK';
      v_pass := v_pass + 1;
    ELSE
      RAISE NOTICE 'VERIFY [6] anonimo nao le favoritos: FALHOU (linhas=%)', v_rows;
      v_fail := v_fail + 1;
    END IF;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [6] anonimo nao le favoritos: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [7] Anónimo: não escreve favoritos
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('role', 'anon')::text, true);
    SET LOCAL ROLE anon;

    INSERT INTO public.favorites (user_id, property_id)
    VALUES (v_uid_a, v_prop);
    RAISE NOTICE 'VERIFY [7] anonimo nao escreve favoritos: FALHOU (inseriu)';
    v_fail := v_fail + 1;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [7] anonimo nao escreve favoritos: OK';
    v_pass := v_pass + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [8] Remoção do próprio favorito
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('sub', v_uid_a::text, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;

    DELETE FROM public.favorites WHERE user_id = v_uid_a AND property_id = v_prop;
    GET DIAGNOSTICS v_rows = ROW_COUNT;

    SELECT count(*) INTO v_total FROM public.favorites WHERE user_id = v_uid_a;
    IF v_rows = 1 AND v_total = 0 THEN
      RAISE NOTICE 'VERIFY [8] remove o proprio favorito: OK';
      v_pass := v_pass + 1;
    ELSE
      RAISE NOTICE 'VERIFY [8] remove o proprio favorito: FALHOU (apagadas=%, restantes=%)',
        v_rows, v_total;
      v_fail := v_fail + 1;
    END IF;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [8] remove o proprio favorito: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [9] Policies de favoritos: 5 ativas, sem as legadas
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    SELECT count(*) INTO v_rows
    FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'favorites';

    SELECT count(*) INTO v_total
    FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'favorites'
      AND policyname IN ('Favorites read for anon', 'Favorites all for authenticated');

    IF v_rows = 5 AND v_total = 0 THEN
      RAISE NOTICE 'VERIFY [9] policies de favoritos (5 ativas, 0 legadas): OK';
      v_pass := v_pass + 1;
    ELSE
      RAISE NOTICE 'VERIFY [9] policies de favoritos: FALHOU (ativas=%, legadas=%)',
        v_rows, v_total;
      v_fail := v_fail + 1;
    END IF;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [9] policies de favoritos: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  -- ────────────────────────────────────────────────────────────────────────
  -- [10] RPC favorite_counts: devolve 0 likes sem favoritos
  -- ────────────────────────────────────────────────────────────────────────
  BEGIN
    SET LOCAL ROLE postgres;
    PERFORM set_config(
      'request.jwt.claims',
      json_build_object('sub', v_uid_a::text, 'role', 'authenticated')::text, true);
    SET LOCAL ROLE authenticated;

    SELECT count(*) INTO v_rows
    FROM public.favorite_counts(ARRAY[v_prop]);

    IF v_rows = 0 THEN
      RAISE NOTICE 'VERIFY [10] RPC favorite_counts sem favoritos: OK';
      v_pass := v_pass + 1;
    ELSE
      RAISE NOTICE 'VERIFY [10] RPC favorite_counts sem favoritos: FALHOU (linhas=%)', v_rows;
      v_fail := v_fail + 1;
    END IF;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'VERIFY [10] RPC favorite_counts sem favoritos: ERRO (%)', SQLERRM;
    v_fail := v_fail + 1;
  END;

  SET LOCAL ROLE postgres;

  -- Limpeza: cascade para public.users e public.favorites
  DELETE FROM auth.users WHERE id IN (v_uid_a, v_uid_b);
  RAISE NOTICE 'VERIFY: utilizadores temporários removidos';

  RAISE NOTICE 'VERIFY RESULTADO: % PASS / % FAIL', v_pass, v_fail;
  IF v_fail > 0 THEN
    RAISE EXCEPTION 'VERIFY: % verificação(ões) falharam', v_fail;
  END IF;
END $$;
