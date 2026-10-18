AUDITORIA "VERY THOROUGH" - APP FLUTTER LUAR MOBILIÁRIO
Path: /home/fortuna/Desktop/Luar-Mobiliario/luar_company
Data: 2026-10-14

NOTA (2026-10-18): Documento histórico (data de 2026-10-14). A maioria das lacunas
apontadas abaixo já NÃO se aplica: Discover (F2), mapa com flutter_map (F3), pesquisas
guardadas (F3), comparação e favoritos (F4), Trust com verificação/denúncias/moderacão (F5),
Studio (F6), notificações com deep links e preferências (F7) e desempenho/cache/conectividade
(F8) estão implementados. Ver o estado atual em TASKS.md, ROADMAP.md e PLANO_EXECUCAO.md.
Notas antigas desatualizadas: "sem dependências de mapa", "sem cached_network_image/connectivity_plus",
"Discover ausente", "Testes: 28". Mantém-se útil apenas como retrato do ponto de partida.

SUMÁRIO
- Ficheiros Dart: 88 (lib/* ~20.282 LOC)
- Testes: 28 (26 unit/widget + 2 integration?)
- i18n: lib/l10n/ (app_pt.arb, app_en.arb ~457 chaves cada, AppLocalizations 2858 linhas)
- Arquitetura: Layered (UI -> Providers -> Repositories -> Services -> Supabase/Firebase)
- Sem dependências de mapa (google_maps/mapbox/flutter_map) no pubspec.yaml/lock
- Sem cached_network_image, video_thumbnail, visibility_detector, connectivity_plus, flutter_secure_storage
- Build: flutter analyze sem issues; APKs existentes

ESTADO GERAL POR FASE (resumo): 1 parcial, 2 ausente/parcial, 3 parcial, 4 parcial, 5 ausente, 6 implementado, 7 ausente, 8 ausente, 9 parcial

FASE 1 - AUDITORIA E ARQUITETURA
Estado: PARCIAL
Comprovado por:
- docs/ARCHITECTURE.md (estrutura camadas, providers, repos, services) - linhas 1-150
- docs/DATABASE.md (schema real migrs 001-007) - linhas 1-200
- docs/SUPABASE.md, docs/MIGRATIONS.md
- lib/core/* (config, constants, models, providers, repositories, services, theme, utils)
- main.dart + app.dart + routes.dart
- supabase/migrations/001-017

O que já existe:
- Arquitetura em camadas clara (Providers + Repositories + Services + Models)
- Mapeamento de dominios: properties/lands/favorites/bookings/messages/partners/admin/auth
- Rotas com PageRouteBuilder custom (routes.dart)
- Separação i18n completa
- Migrações Supabase organizadas, RLS presente

O que falta:
- Plano de execução consolidado no repo (Documento.md existe mas plano detalhado por ficheiros ainda não sintetizado internamente)
- Não há documento explícito "audit map" por ficheiro vs fases (o presente relatório serve para isso)
- Falta revisão sistemática de todos os pontos RLS vs políticas (parcialmente documentado)


FASE 2 - LUAR DISCOVER (feed vertical vídeo automático)
Estado: IMPLEMENTADO (2026-10-14) - com lacunas remanescentes
Comprovado por:
- lib/screens/discover/discover_screen.dart (659 linhas) - PageView.builder scrollDirection Axis.vertical, UMA página por imóvel, _activeIndex via onPageChanged, loadMore quando index >= items.length - 3, overlay (gradiente, badge venda/arrendamento, título, localização, preço, descrição 2 linhas, chips quartos/WC/área), ações (favorito, partilha, WhatsApp, detalhes), estados loading/erro/vazio, Semantics.
- lib/core/providers/discover_provider.dart (86 linhas) - paginação real Supabase (fetchProperties page, pageSize=20), load/loadMore/refresh, guarda anti-corrida isLoadingMore, isEmpty explícito, mapa filters.
- test/unit/discover_provider_test.dart (143 linhas) - 5 testes load/loadMore/hasMore/error.
- lib/widgets/video_player_widget.dart (203 linhas) - VideoPlayerController.networkUrl por página, isActive, WidgetsBindingObserver + didChangeAppLifecycleState (pausa em background), _userPaused (toque pause/play), didUpdateWidget com _reinitialize, dispose correto.
- Entradas: bottom-nav "Descobrir" (índice 4) em home_screen.dart, botão "Descobrir" no hero (home_screen.dart:194, :974), rota /discover (routes.dart).
- Registado em main.dart: 12 ChangeNotifierProvider incl. DiscoverProvider.

O que ainda falta (pendente Etapa 3):
- Filtros no ecrã Discover (provider aceita filters mas UI não os expõe)
- Incluir terrenos no feed (de momento só properties)
- Pull-to-refresh no ecrã
- Opção global para desativar reprodução automática (persistida)
- Preloading/aquecimento do vídeo seguinte, VisibilityDetector, volume/mudo
- Limite de memória da lista _items crescente
- pushNamed vs bottom-nav: ainda um ecrã empurrado com AppBar própria

Conclusão: EXPERIÊNCIA VERTICAL IMPLEMENTADA E FUNCIONAL. Restam melhorias de Fase 2/8.


FASE 3 - PESQUISA E MAPA
Estado: PARCIAL
Comprovado por:
- lib/screens/search/search_screen.dart - pesquisa com query + filtros (transactionType, propertyType, landType, city, price range, area range, quartos/banhos/garagem). Chips ativos, bottom sheet de filtros. Resultados mistos (properties + lands) em ListView. Linhas 1-1002
- lib/core/providers/search_provider.dart - search() chama propertyRepository.searchAdvanced + landRepository.searchAdvanced, mantém filtros (municipality/neighborhood também). Linhas 1-173
- lib/core/repositories/property_repository.dart - searchAdvanced aplica filtros: query OR, type, transactionType, city, municipality, neighborhood, minPrice/maxPrice, minArea/maxArea, bedrooms, bathrooms, garage; ordena created_at desc; limita pageSize. Linhas 225-306. Também fetchProperties com range pagination.
- lib/core/repositories/land_repository.dart - searchAdvanced similar (sem bedrooms/bathrooms/garage). Linhas 203-260
- lib/screens/properties/properties_screen.dart - listagem com ordenação (priceAsc/priceDesc/areaDesc/recent) + filtros básicos via provider.loadProperties. Linhas 1-430
- lib/screens/lands/lands_screen.dart - idem terrenos. Linhas 1-450

Mapeamento campos existentes vs requisito:
- Compra/arrendamento: transactionType (sale/rent) - OK
- Província/município/localização: city, municipality, neighborhood, address - OK (modelo tem)
- Intervalo preços/área/tipo/quartos/área/características - OK (searchAdvanced cobre)
- Ordenação: existe (recent/preço/área) nas listas; search devolve ordenado por created_at desc - OK parcial
- Pesquisas guardadas: AUSENTES (nenhuma tabela migration "saved_searches", nenhum provider/repo/screen)
- Mapa interativo: AUSENTE. Modelos têm latitude/longitude (PropertyModel linhas 38-39,99,145; LandModel 35-36,89,133). Mas SEM pacote mapa no pubspec (sem google_maps/mapbox/flutter_map). No property_detail_screen e land_detail_screen há secção localização com coordenadas textuais + placeholder visual (map icon) mas não renderiza mapa. Linhas relevantes: property_detail_screen 589-649 (mostra coords), land_detail_screen similar.

O que falta:
- Mapa interativo funcional (precisa integrar pacote aprovado - mas não existe no pubspec atual)
- Correspondência marcadores -> anúncios reais: estrutura existe (coords) mas UI mapa inexistente
- Pesquisas guardadas (persistir filtros/query por user_id)
- Pode haver necessidade de ordenação estendida na pesquisa (distância se mapa implementado) - não aplicável sem mapa

Conclusão: Pesquisa avançada bem implementada. Mapa e pesquisas guardadas AUSENTES.


FASE 4 - COMPARAÇÃO E FAVORITOS
Estado: PARCIAL (favoritos implementados; comparação ausente)
Comprovado por:
- lib/core/models/favorite_model.dart - model com id, userId, propertyId?, landId?, createdAt. Linhas 1-53
- lib/core/repositories/favorite_repository.dart - fetchFavorites(userId), add/remove, fetchFavoriteProperties/ fetchFavoriteLands by ids. Linhas 1-69
- lib/core/providers/favorite_provider.dart - loadFavorites, toggleFavorite, isFavorite, getFavoriteProperties/Lands, clear. Linhas 1-107
- lib/screens/favorites/favorites_screen.dart - tabs Imóveis/Terrenos, guest state, grid, refresh, navega para detalhe. Linhas 1-334
- Uso em detalhe: property_detail_screen toggleFavorite (linhas ~188-205), land_detail_screen similar
- Supabase: favorites table (migr 001 mostra tabela favorites?) - verificar: migr 001 tem favorites? (grep rápido: favorites aparece em policies? migr 002 tem policies p/ favorites)
- Persistência: via Supabase (RLS policies existem nas migrações 002)

Comparação:
- AUSENTE. Não há ComparisonProvider, ComparisonScreen, model Comparison, nem botão "comparar". 
- Não há cálculo preço/m² (pricePerSqm) em lado cliente. 
- Grep: "compar", "compare" só em bookings/provider sorts e propriedades sorts (sort client-side). Nenhum código de comparação.

O que falta p/ Fase 4:
- Comparação até 3 imóveis (seleção múltipla, comparar propriedades entre si; terrenos podem ser distintos mas requisito fala "imóveis" - verificar Documento: "comparação de até três imóveis")
- Comparação campos: preço, área, localização, características disponíveis + preço por m² (apenas com dados válidos: area>0)
- Estados vazios/erros/loading na comparação
- Sincronização Supabase: não necessário se local session; mas favoritos já sincronizam. Comparação pode ser sessão/local (até 3) - mas requisito pede "sincronização segura com Supabase quando aplicável" - talvez permitir guardar comparação? Não explícito; mas favoritos já OK.
- Botões "Adicionar à comparação" em cards/detalhes
- Ecrã de comparação lado-a-lado

Conclusão: Favoritos OK e persistentes. Comparação COMPLETAMENTE AUSENTE.


FASE 5 - LUAR TRUST
Estado: AUSENTE
Comprovado por:
- Modelos: user_model tem role (client/agent/admin), agentName/agentPhone em property/land. Sem "verified", "verificationStatus", "verificationDocument", "report_reason", "report_status", "moderation_log", etc.
- Tabelas migrations: users tem role; não há agent_verifications, reports, moderation_actions.
- Perfis de anunciantes: existe partner (partners table migr 003) e PartnerScreen/PartnerForm - mas "perfis de anunciantes" no contexto "Trust" pode referir estado verificação agente/anunciante. Atualmente agente é user com role agent; sem flag verificado.
- Estado explícito verificação: AUSENTE em UI e BD.
- Reportar anúncios suspeitos: AUSENTE (sem botão/report dialog, sem repo/model/table)
- Ferramentas admin moderação: Admin tem dashboard/users/properties/lands/bookings/partners - mas não moderação de reports/denúncias.
- Registo ações moderação + proteção dados: AUSENTE.
- Nunca apresentar como verificado sem processo real - regra respeitada pois não existe marcação falsa (não existe).

O que falta:
- Campos verification_status (pending/verified/rejected) em users/agents
- Tabela reports (property_id/land_id/reporter_id/reason/status/notes)
- Tabela moderation_actions (actor_id/target_type/target_id/action/notes)
- UI: badge "Verificado" só se status verified; botão "Reportar anúncio"; ecrã admin para reports/moderação
- Regras RLS para reports/moderation
- Proteção dados: já há RLS extenso; mas logs moderação devem ser auditados

Conclusão: Trust não implementado.


FASE 6 - LUAR STUDIO E PUBLICAÇÃO
Estado: IMPLEMENTADO (auditoria/fluxo existente com melhorias)
Comprovado por:
- lib/screens/properties/property_form_screen.dart - criação/edição imóveis. Upload múltiplas imagens (image_picker), upload vídeos (pickVideo), validações, pré-visualização (XFileThumbnail), estados loading, tratamento erros. Usa StorageService.uploadImage/uploadVideo com validação MIME/tamanho e retry. Linhas 1-700+
- lib/screens/lands/land_form_screen.dart - idem terrenos. Linhas 1-650+
- lib/core/services/storage_service.dart - validação tipos MIME (MediaTypeUtil), max bytes, retry 3x, getPublicUrl, delete. Linhas 1-186
- lib/core/utils/media_type_util.dart - detecção MIME por extensão+magic bytes. Linhas 1-80
- lib/core/repositories/property_repository.dart - create/update com inserção de property_images/property_videos (limpa e reinsere). Delete soft-delete (is_available=false) e limpa relações. Linhas 143-209
- lib/core/repositories/land_repository.dart - create/update/delete similar + land_images/land_videos. Linhas 126-189
- lib/screens/admin/admin_properties.dart, admin_lands.dart - gestão admin
- Permissões: AuthProvider controla role (client/agent/admin). Formulários acessíveis consoante role? (proprietário/agente) - na UI há botões para criar (ex. em profile? não visto aqui) mas fluxo existe; validação backend depende RLS.
- Validação cliente+backend: forms fazem validação básica; backend via RLS/policies (migrações)

Detalhes:
- Upload imagens/vídeos: OK
- Validação formatos/tamanhos: OK (storage_service + MediaTypeUtil; forms também validam)
- Compressão: NÃO explícita. image_picker devolve bytes originais; storage_service não comprime. Requisito menciona "compressão adequada quando possível" - AUSENTE
- Pré-visualização: OK (XFileThumbnail para XFile; em detalhe mostra imagens)
- Edição/estado/gestão: OK
- Falhas rede/uploads interrompidos: storage_service tem retry; tratamento de exceções com StorageUploadException
- Permissões owner/agente: RLS policies em migrations (ex. property_videos: agents/admin só gerem se agent_id corresponde) - OK no backend
- Validação cliente+backend: parcial (cliente forms, backend RLS)

O que falta:
- Compressão de imagens/vídeos antes upload (ex. image_compression/flutter_image_compress ou similar) - não há deps
- Tratamento mais robusto de uploads grandes/interrompidos (progress? atual não mostra progresso detalhado)
- Validação mais estrita no backend além de RLS? (ex. constraints CHECK)

Conclusão: Fluxo de publicação bem implementado. Falta compressão e talvez melhor UX de progresso.


FASE 7 - PERSONALIZAÇÃO E NOTIFICAÇÕES
Estado: AUSENTE
Notificações (infraestrutura existe):
- lib/core/services/notification_service.dart - Firebase FCM + local notifications. Inicializa, getToken, saveTokenToDatabase (upsert em notifications table), sendNotification (chama RPC send_notification + edge function send-notification), listeners foreground/onMessageOpenedApp. Linhas 1-184
- supabase/migrations/008_add_notifications_tokens.sql - tabela notifications (user_id, fcm_token, updated_at) + RLS
- supabase/migrations/009_add_send_notification_rpc.sql - RPC send_notification
- supabase/functions/send-notification/index.ts - edge function
- AuthProvider/NotificationService integration: tokens guardados? No código NotificationService.saveTokenToDatabase chamado em algum lado? AuthProvider não chama explicitamente (verificado superficialmente). Registo de tokens existe.
- Consentimento: pedido permission FCM (linha 50-64 notification_service) - OK
- Tokens/deep links: tokens salvos BD; deep links NÃO tratados. _handleBackgroundMessage vazio (linha 172-174), onMessageOpenedApp só ouve mas não navega com payload para imóvel específico. Não há parsing de data (route/deep link). Ausência de roteamento com argumentos por notification.

Recomendações/personalização:
- AUSENTE. Nenhum provider/repo para recommendations, saved searches, user_preferences. Sem regras transparentes de recomendações. Sem alertas (saved search alerts).
- Não há tabelas recommendations/user_preferences/alerts/saved_searches.

O que falta:
- Deep links: ao receber notification com property_id/land_id, navegar para AppRoutes.propertyDetail/landDetail (precisa inicializar handler que lê initialMessage e onMessageOpenedApp com payload)
- Recomendações progressivas baseadas em pesquisas/favoritos (começar por regras transparentes)
- Alertas com pesquisas guardadas + notificações + evitar duplicados (já há estrutura tokens, falta lógica alertas)
- Ausência exposição dados sensíveis no ecrã bloqueado: notificações locais mostram title/body (normais); não há PII exposto além do que enviamos - mas sem deep link payload sensível. Parcial.

Conclusão: Infra FCM existe. Falta deep linking + recomendações + alertas.


FASE 8 - DESEMPENHO E POUPANÇA DE DADOS
Estado: AUSENTE
Verificado:
- Miniaturas antes vídeos: não há geração de miniaturas. property_form usa XFileThumbnail para preview local (linha 564 property_form) - thumbnail local do XFile, não servidor. Em listas/cards não mostra thumbnail de vídeo; cards mostram apenas imagemUrl (primeira imagem). VideoPlayerWidget carrega vídeo direto.
- Carregamento só necessário: lists com pagination (range) - OK (fetchProperties com page/pageSize). Featured limitados. 
- Cache com limites memória/armazenamento: não há cached_network_image; Image.network usado diretamente (property_card, detail). Sem cache configurado explicitamente.
- Libertação recursos: VideoPlayerWidget dispose() correto (linha 52-55). Outros widgets normais. Mas sem gestão agressiva.
- Conectividade fraca: AUSENTE. Nenhum pacote connectivity_plus; sem verificação rede antes requests.
- Desativar autoplay: VideoPlayerWidget tem autoPlay param (default false). Em video_viewer_screen autoPlay true (linha 54) - intencional p/ visualizador. Em feed vertical futuro precisaria controlar por página ativa + permitir desativar.
- Redução resolução/consumo: não há lógica adaptive (qualidade) p/ vídeos/imagens.
- Métricas desempenho sem recolha excessiva: não há Firebase Performance/Crashlytics configurados além do FCM core? pubspec tem firebase_core+firebase_messaging; sem performance/crashlytics. Sem métricas próprias.

O que falta:
- Thumbnails de vídeo (servidor ou gerar) - deps: video_thumbnail. Não existe.
- Imagem cacheada (cached_network_image) ou configurar.
- Connectivity listener + fallback/offline
- Opção "desativar autoplay" (setting) - Theme/SettingsSheet existe mas não configura autoplay global
- VisibilityDetector para pausar vídeo fora ecrã (relevante p/ futuras listas com vídeos)
- Métricas mínimas (opcional)

Conclusão: Maioria ausente. Existe base (dispose, pagination). Falta cache, conectividade, thumbnails, autoplay configurável.


FASE 9 - SEGURANÇA E QUALIDADE
Estado: PARCIAL
Segurança:
- Autenticação Supabase Auth: AuthProvider + AuthRepository + AuthService. Login admin por 6 dígitos (migr 013 contexto? ver migr 016? migr 016 não; migr 013-014 guest registration; admin login screen existe)
- RLS preservado: muitas migrações com policies (002 tem 31 policies). Tabelas com ENABLE ROW LEVEL SECURITY.
- Revisão acesso tabelas/Storage: policies para properties/lands/images/videos/favorites/bookings/messages/partners/admin/users/notifications. Buckets: property-images, property-videos, avatars? (migr 016 cria property-videos; imagens provavelmente bucket existente)
- Não incluir chaves secretas no cliente: usa .env + publishable anon key (SUPABASE_ANON_KEY) - correto. Service role não usado no cliente.
- Não contornar RLS: código respeita cliente Supabase com sessão autenticada.
- .gitignore cobre .env etc.

Qualidade:
- flutter analyze: sem issues (relatado)
- Testes unitários: 26 (modelos, utils, widgets básicos)
- Testes integração: 2 (app_test.dart)
- Builds adequados: APKs existentes (luar-mobiliario-apk-9.apk, 10.apk), workflow CI presente (.github)
- TODO/FIXME: apenas placeholders UI (XXX) - 3 ocorrências não código funcional
- Regressões: não verificadas por falta de execução completa testes

Riscos identificados:
- Sem mapa deps mas modelos têm coords - pode ser aceitável se não implementar mapa agora
- Comparação/report/moderação ausentes - requisitos fortes Fase 5
- Discover vertical ausente - Fase 2 crítica
- Deep links não tratados - Fase 7
- Autoplay em background não gerido - Fase 2/8
- Compressão uploads ausente - Fase 6


CONTAGEM E ORGANIZAÇÃO ARQUITETURA EM CAMADAS
- Camadas confirmadas (docs/ARCHITECTURE.md):
  1. UI: lib/screens (17 pastas: admin, auth, bookings, favorites, home, lands, messages, partners, profile, properties, search, splash, videos, welcome) + lib/widgets (24 widgets)
  2. State: lib/core/providers (14: admin, auth, booking, favorite, land, locale, message, partner, property, search, theme)
  3. Business/Data: lib/core/repositories (8 repos) + lib/core/services (4: auth, notification, storage, supabase)
  4. Models: lib/core/models (8: booking, favorite, land, message, partner, property, user)
  5. Utils/Theme/Config/Constants: lib/core/{utils,theme,config,constants}
- lib/l10n: 4 ficheiros (pt/en + generated)
- test/: 27 ficheiros; integration_test/: 1
- supabase/: migrations (17) + functions + config
- Organização clara por domínio. Sem anomalias estruturais.


TESTES EXISTENTES
test/unit/: 14 (app_constants, booking_model, categories, favorite_model, formatters, land_model, media_type_util, message_model, partner_model, property_model, responsive, routes, user_model, validators)
test/widget/: 12 (avatar, category_card, custom_button, custom_input, empty_state, feature_chip, land_card, loading, price_tag, property_card, search_widget, widget_test)
test/helpers/: test_app.dart
integration_test/app_test.dart: 2 testes
Total: 28 ficheiros. Cobrem modelos, utils, widgets. Falta cobertura providers/repositories/screens críticos.

TODO/FIXME
Apenas placeholders de UI:
- lib/screens/bookings/booking_bottom_sheet.dart:263: hint '(9XX) XXX XXX'
- lib/screens/profile/edit_profile_screen.dart:171: hint '+244 9XX XXX XXX'
- lib/screens/partners/partner_form_screen.dart:194: hint '+244 9XX XXX XXX'
Sem TODO/FIXME funcionais.

RISCOS E DEPENDÊNCIAS EM FALTA (pubspec)
Dependências presentes relevantes: supabase_flutter, provider, google_fonts, url_launcher, image_picker, video_player, mime, intl, shared_preferences, firebase_core, firebase_messaging, flutter_local_notifications, share_plus, path, uuid. flutter_localizations gerado.
Em falta (sugeridas p/ cumprir fases):
- google_maps_flutter OU flutter_map+latlong (Fase 3 - mapa) - AUSENTE
- cached_network_image (Fase 8 cache imagens) - AUSENTE
- video_thumbnail (Fase 8 thumbnails vídeos) - AUSENTE
- visibility_detector (Fase 8 pause vídeo fora ecrã / Discover) - AUSENTE
- connectivity_plus (Fase 8 conectividade) - AUSENTE
- image_picker tem compressão? não nativo; pode precisar flutter_image_compress (Fase 6) - AUSENTE
- permission_handler (se necessário p/ storage/camera) - AUSENTE (image_picker já gere)
- flutter_secure_storage (tokens sensíveis extras) - opcional
- workmanager (background tasks alerts) - opcional p/ Fase 7

Riscos principais: Discover ausente (F2), Comparação ausente (F4), Trust/report/moderação ausentes (F5), Deep links ausentes (F7), Mapa ausente (F3), Autoplay em background não gerido (F2/8).


MAPA IMPLEMENTADO VS AUSENTE (detalhado por ficheiro)
IMPLEMENTADO (parcial):
- F1: arquitetura, models (property/land com lat/lng), repos, providers, i18n
- F3: pesquisa avançada completa (transaction/city/mun/neigh/price/area/bed/bath/garage, lands)
- F4: favoritos completos (model/repo/provider/UI)
- F6: publicação completa (imagens+vídeos, storage, forms, admin)
- F9: RLS extenso, auth, analyze OK

PARCIAL:
- F2: VideoPlayerWidget existe mas sem lifecycle pause; video_viewer existe mas não é feed vertical
- F3: sem mapa UI, sem saved searches
- F4: comparação ausente
- F7: notificações infra OK, deep links ausentes
- F8: sem cache/connectivity/thumbnails/autoplay global config
- F9: testes cobertura limitada

AUSENTE:
- F2: feed vertical Discover
- F3: mapa interativo + saved searches
- F4: comparação (até 3, preço/m²)
- F5: verification/report/moderação
- F7: recomendações + alertas + deep links completos
- F8: performance/data saving completo


RECOMENDAÇÕES PARA PRÓXIMOS PASSOS (sem alterar ficheiros)
1. F2 - Implementar Discover vertical (novo ecrã discover_screen.dart) com PageView.vertical, autoplay só página ativa, pause em background via WidgetsBindingObserver no VideoPlayerWidget, paginação real (loadMore).
2. F3 - Adicionar mapa: escolher pacote (google_maps_flutter vs flutter_map). Implementar mapa com marcadores reais (lat/lng válidos). Adicionar saved_searches (tabela + provider + UI).
3. F4 - Implementar comparação: ComparisonProvider, ComparisonScreen, botão "comparar" (max 3), cálculo preço/m².
4. F5 - Trust: verification status em users, reports + moderation_actions (migrations + UI admin + report dialog).
5. F7 - Deep links em NotificationService (tratar initialMessage/onMessageOpenedApp + navegar). Recomendações baseadas em regras + alertas.
6. F8 - cached_network_image, connectivity_plus, video_thumbnail (ou gerar thumbnails), VisibilityDetector.
7. F6 - Compressão imagens antes upload (melhoria)
8. F9 - Expandir testes (providers/repositories/screens)

PRIORIDADE SUGERIDA: F2 (Discover) + F3 parcial (mapa) + F4 (comparação) + F7 deep links.

