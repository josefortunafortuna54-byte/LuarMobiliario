# Changelog

Todas as alterações notáveis neste projeto são documentadas neste ficheiro.

O formato baseia-se em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adota o [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [Unreleased]

### Adicionado

- **Seed de demonstração** (`luar_company/supabase/seed_demo.sql` +
  `seed_demo_videos.sql`): 12 imóveis (casas, apartamentos, escritório, loja,
  armazém e condomínio) e 7 terrenos (urbano, agrícola, lote, industrial,
  quinta, comercial e renda), com fotos reais verificadas (Unsplash),
  18 vídeos MP4 720p de licença livre (Mixkit — 1 vídeo em 11 imóveis e em
  todos os terrenos; a loja fica só com fotos), preços em AOA e localizações
  em Luanda, Benguela, Huambo, Huíla e Kwanza Sul. Cinco anúncios ficam em
  destaque (carrossel da Home), todos com `is_available = true`. Os scripts
  são idempotentes (UUIDs fixos `d0000001-…`/`d0000002-…` e limpeza prévia
  desses mesmos anúncios), não tocam em dados reais e podem ser revertidos
  com os `DELETE` indicados nos cabeçalhos. Já aplicados ao projeto de
  produção via `supabase db push --include-seed` (o `config.toml` passou a
  declarar `[db.seed] sql_paths`, também útil no `db reset` local). Nota: os
  statements são individuais (sem temp tables/`BEGIN`) por compatibilidade
  com o executor de seed do CLI; e o CLI v2.72.7 só reaplica um seed cujo
  hash mudou se o caminho do ficheiro mudar (daí os vídeos viverem num
  ficheiro companheiro, aplicado como novo).
- **Menu Admin no perfil**: acesso direto ao painel de gestão para
  administradores e agentes (a entrada não aparece a clientes).
- **Widgets de arranque**: `PremiumSplashBackground` (foto de fundo com
  scrim navy e orbes douradas animadas) e `GoldShimmerRing` (anel com
  varredura de brilho à volta do logo), reutilizados pelo splash e pelas
  boas-vindas.
- **Imagem de fundo do arranque** (`luar_company/fundo.jpeg`): usada nos
  ecrãs anteriores à Home (splash e boas-vindas) por trás de um scrim navy
  que garante a legibilidade do conteúdo. O asset foi redimensionado para
  1920px e comprimido (≈420 KB) para não pesar no arranque; se o asset
  falhar, o fundo cai no gradiente navy sem partir o ecrã.

### Alterado

- **Fluxo de arranque (Splash → Welcome → Home)**: o splash passa a
  navegar para o ecrã de boas-vindas (antes ia direto ao Home), com
  transição suave de fade+zoom (`startupFadeRoute`). Em notificações de
  arranque frio, o splash salta as boas-vindas e vai direto ao destino
  (`NotificationService.hasPendingNavigation`).
- **Splash**: redesenho premium — fundo com orbes douradas animadas, logo
  com anel shimmer e glow, e barra de carregamento gold (substitui o
  spinner circular).
- **Boas-vindas**: redesenho premium em ecrã inteiro navy+gold com
  entrada escalonada (fade + slide-up), grelha de cartões "glass" com as
  7 features (substitui a lista vertical) e CTA "Explorar Imóveis";
  comporta-se bem em telemóvel, tablet e desktop.
- **Painel admin**: redesenho visual — cabeçalho hero com detalhe dourado e
  ícone admin, secções com acento gold, cartões de estatística com bordas do
  tema, métricas e chips legíveis no modo escuro (top-5 com medalhas) e
  ações rápidas leves com ripple; agora com pull-to-refresh, botão de
  atualizar na AppBar, barra de progresso e estados de erro com "Tentar
  novamente". As ações rápidas só-admin (Ver Utilizadores, Denúncias)
  ficam ocultas para agentes.
- **Agendamentos**: Após confirmar a marcação de visita, o cliente é registado
  pedindo apenas nome + telefone (`register_guest_client` RPC). O perfil é criado
  em `users` com email sintético `@guest.luar` e ligado à marcação.
- **Perfil (visitante)**: Texto atualizado para refletir o registo automático
  após agendar uma visita.

### Removido

- **Código morto**: ecrã `HomeScreen` (substituído por `MainShell` + separadores)
  removido do repositório.

### Corrigido

- **Favoritos (o coração não guardava)**: guardar um favorito que já existia
  no servidor falhava com `409 duplicate key value violates unique constraint
  "favorites_user_property_unique"`. O `INSERT` passou a `upsert`
  (`ON CONFLICT DO UPDATE` com `missing=default`, para preservar o `created_at`
  original) e a remoção passou a ser feita pela chave lógica
  (`user_id` + `property_id`/`land_id`) em vez do id da linha — assim também
  funciona quando o estado local está dessincronizado do servidor. O
  `FavoriteProvider.toggleFavorite` devolve agora
  `FavoriteToggleResult{added, removed, failed}` (antes devolvia `bool`, que
  tratava uma falha como "removido" e mostrava o coração por preencher), e o
  novo helper `toggleFavoriteWithFeedback`
  (`lib/core/utils/favorite_actions.dart`) avisa o utilizador com um snackbar
  quando a gravação falha. Os cartões das listagens (Imóveis, Terrenos e
  Pesquisa) passaram a receber `isFavorite`/`onFavoriteTap` e a carregar os
  favoritos do utilizador — o botão de like não existia nessas listas.
- **Privacidade dos favoritos (RLS)**: a migration
  `032_favorites_rls.sql` remove as policies legacy permissivas ("Favorites
  read for anon" e "Favorites all for authenticated") — qualquer visitante
  anónimo lia os favoritos de todos os utilizadores e qualquer conta
  autenticada podia escrever em qualquer linha. Passam a valer as policies
  "own" (read/insert/update/delete) mais o acesso total do admin; a policy de
  `UPDATE` é necessária porque o `upsert` resolve conflitos com
  `ON CONFLICT DO UPDATE`. Já aplicada em produção (`supabase db push`) e
  validada contra a API de produção: 15/15 verificações na REST API (upsert
  sem `409`, `created_at` preservado, leitura isolada por utilizador, escrita
  bloqueada ao anónimo, `favorite_counts` correto antes/depois do `DELETE`) e
  10/10 no script SQL `luar_company/supabase/verify_032_favorites.sql`
  (`VERIFY RESULTADO: 10 PASS / 0 FAIL`), que cria e remove os seus próprios
  utilizadores de teste.
- **Migration `007_security_fixes.sql` (base de dados nova)**: a policy
  "Bookings: update own" comparava as pseudo-colunas `OLD`/`NEW`, que só
  existem dentro de funções trigger — nunca em policies RLS. A migration
  abortava com `missing FROM-clause entry for table "old"`, pelo que
  `supabase db reset`/`start` nunca completava numa base vazia. Passou a
  usar a mesma formulação da migration 015 (a que a produção já executa): o
  cliente só transita de `pending` para `cancelled`, enquanto agente e admin
  confirmam ou cancelam definitivamente. As duas policies de `DELETE` do
  storage passaram a comparar `owner_id::text = auth.uid()::text` (o
  `owner_id` é TEXT em algumas versões do storage) — a mesma correção da
  migration 017. Validado com a cadeia completa 001→032 aplicada numa base
  nova (`supabase db start`) e o script `verify_032_favorites.sql` a correr
  contra ela (`VERIFY RESULTADO: 10 PASS / 0 FAIL`).
- **Deriva entre a cadeia de migrations e a produção (033 + 034)**: a
  migration `002_rls_role_based_policies.sql` foi executada em produção antes
  de ser revista e a `007` foi corrigida depois de já estar aplicada — o CLI
  do Supabase regista version+name e nunca re-executa uma migration já
  aplicada, pelo que a produção ficou com as policies originais. A migration
  `033_reconcile_rls_policies.sql` remove as 19 policies legacy ("X read for
  anon" com `USING (true)` e "X all for authenticated" com `FOR ALL`) que
  deixavam qualquer visitante anónimo ler todas as reservas e todos os
  perfis de utilizadores, e recria "Users: read own or admin" e "Users: insert
  own" (apenas o perfil próprio). A migration
  `034_reconcile_ownership_policies.sql` repõe a verificação de posse da
  `007` nas imagens — em produção qualquer agente podia alterar ou apagar as
  imagens do anúncio de outro agente —, alinha o `WITH CHECK` do `UPDATE` de
  imóveis/terrenos (bloqueia a transferência de posse do anúncio, erro
  `42501`) e recria os índices `idx_bookings_user_created` e
  `idx_bookings_property_status`, que faltavam em produção. Os dados públicos
  do agente (nome, avatar, verificação) continuam disponíveis através da view
  `users_public`, sem expor e-mail nem telefone. Ambas aplicadas em
  produção (`supabase db push`) e validadas com `supabase db diff --linked`
  sem qualquer diferença entre a cadeia e a produção (0 statements), 27/27
  verificações na REST API de produção e 7/7 num teste de posse (agente
  gere as imagens do seu anúncio e não as de outro).
- **Painel admin — contador de mensagens não lidas**: com a remoção da policy
  legacy "Messages all for authenticated", o contador de mensagens por ler
  (`admin_repository.fetchStats`) passa a contar apenas as mensagens do próprio
  admin, em vez de todas as mensagens da plataforma — as mensagens dos
  utilizadores deixaram de ser legíveis por qualquer conta autenticada.
- **Testes de integração**: `main()` passa a ser aguardado antes das
  verificações e o assert da rota `home` verifica agora `MainShell`.
- **WhatsApp**: botão de contacto nos detalhes de imóvel/terreno passa a
  normalizar o telefone (`WhatsAppUtil.normalizePhone`), evitando links
  `wa.me` inválidos para números no formato local (ex.: `942 203 497`);
  código duplicado dos ecrãs de detalhe substituído por `WhatsAppUtil.open`.
- **Arranque**: serviços e repositórios acedem ao cliente Supabase de forma
  lazy (getter), eliminando o crash no arranque quando a configuração
  Supabase está em falta (ex.: testes de integração no CI sem
  `--dart-define`); a inicialização de notificações no `main()` passa a ser
  protegida com try/catch.

---

## [1.0.1] - 2026-10-16

### Adicionado

- **Luar Discover**: feed vertical de imóveis (vídeo/imagem) com gostos e reprodução
- **Comparação**: comparar imóveis lado a lado
- **Pesquisas guardadas**: guardar e reutilizar conjuntos de filtros de pesquisa
- **Avaliações**: avaliações de imóveis (1–5 estrelas) com comentários e média
- **Trust**: verificação de anunciantes, denúncias, registo de moderação e badges
- **Notificações por categoria**: preferências in-app e canais Android dedicados
  (mensagens, agendamentos, anúncios, promoções, sistema)
- **Dashboard de analytics**: métricas no painel admin, contador de visualizações
  (`views`) e RPC `register_listing_view`
- **Internacionalização**: suporte PT/EN

### Alterado

- **Segurança**: o `.env` deixa de ser empacotado como asset; configuração
  injetada via `--dart-define` (scripts de build e CI)
- **Notificações**: tokens FCM passam para a tabela dedicada `device_tokens`
- **Pesquisa**: ordenação de resultados e filtros por província/município
- **Favoritos**: carregamento de imagens na listagem

### Corrigido

- Políticas RLS e ligação app ↔ BD (view pública sem PII, contagens de favoritos)
- Restauro do trigger `handle_new_user` e integridade ao apagar utilizadores
- Upload/delete de imagens e vídeos (policies de storage)

### Infraestrutura

- Migrações 018–026 (trust, device tokens, pesquisas guardadas, RLS, avaliações,
  integridade de utilizadores, otimização de índices e analytics)

---

## [1.0.0] - 2026-07-19

### Adicionado

- **Autenticação**: Login e registo de utilizadores via email/senha com Supabase Auth
- **Ecrã principal (Home)**: Destaques, categorias e propriedades recentes
- **Pesquisa avançada**: Filtros por tipo, transação, preço, área, quartos e localização
- **Propriedades**: Lista e detalhe com galeria de fotos e informações do agente
- **Terrenos**: Lista e detalhe de terrenos (urbano, agrícola, industrial, comercial)
- **Favoritos**: Guardar e gerir propriedades e terrenos favoritos
- **Mensagens**: Sistema de mensagens entre utilizadores e agentes
- **Agendamentos**: Agendamento de visitas a propriedades
- **Perfil**: Gestão de perfil do utilizador com avatar
- **Painel administrativo**: Dashboard, gestão de propriedades e utilizadores
- **Notificações push**: Integração com Firebase Cloud Messaging
- **Integração WhatsApp**: Contacto rápido com agentes via WhatsApp
- **Design system**: Tema personalizado com cores navy/gold, tipografia DM Sans
- **Landing page**: Página web institucional em HTML/CSS/JS

### Infraestrutura

- Arquitetura em camadas (UI → Provider → Repository → Supabase)
- Variáveis de ambiente via `--dart-define` (inicialmente `flutter_dotenv`)
- Modelos de dados com serialização JSON
- Repositórios para acesso a dados
- Services para autenticação, storage e notificações
- Rotas nomeadas com transições personalizadas
- Componentes reutilizáveis (PropertyCard, LandCard, PriceTag, SearchWidget, etc.)

### Tipos de Propriedade Suportados

- Casa
- Apartamento
- Terreno
- Fazenda
- Armazém
- Escritório
- Loja
- Condomínio

### Tipos de Transação

- Venda
- Arrendamento

### Tipos de Terreno

- Urbano
- Agrícola
- Industrial
- Comercial
- Lote
- Fazenda

### Roles de Utilizador

- Cliente
- Agente
- Administrador
