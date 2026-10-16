# Plano de Execução — Documento.md vs App (sessão 2026-10-15)

> **⚠️ Nota (2026-10-16):** snapshot histórico. Várias lacunas listadas abaixo já
> foram resolvidas — nomeadamente: `.env` deixou de ser empacotado como asset
> (config via `--dart-define`); migrações até **`026`** aplicadas; preferências de
> notificação por categoria (T-048) e painel de analytics admin (T-045)
> implementados; `flutter analyze` limpo e **457 testes** a passar; versão
> `1.0.1+14`. Os itens ainda em aberto estão em [`TASKS.md`](TASKS.md).
>
> Sessão guardada. Estado analisado: árvore de trabalho do `luar_company/` com alterações
> **não commitadas** (28 ficheiros, +1134/−331, 9 novos: comparison_provider, comparison_screen,
> main_shell, deep_links, navigation, migrations 018/019).
> Auditoria anterior: `luar_company/docs/auditoria.md` (14/10) — parcialmente desatualizada.

## Decisões do utilizador

1. **Mapa:** `flutter_map` + `flutter_map_marker_cluster` (OpenStreetMap, sem API key).
2. **Bugs:** corrigir todos os bugs das alterações não commitadas (Etapa 0).
3. **Fase 6:** completa — pré-visualização + ecrã "Minhas publicações" do agente.

---

## Estado por fase (auditado 2026-10-15)

| Fase | Estado | Lacunas principais |
|---|---|---|
| 1 Auditoria/Arquitetura | ✅ quase completa | AGENTS.md sem os 5 agentes exigidos pelo Documento |
| 2 Discover | ✅ implementada | vídeo continua a tocar ao mudar de tab; sem filtros; sem pull-to-refresh; sem opção desativar autoplay; `_items` sem limite; corridas async no VideoPlayerWidget; Discover duplicado (tab + rota) |
| 3 Pesquisa/Mapa | ⚠️ parcial | **mapa 0%**; **pesquisas guardadas 0%**; sem ordenação na UI; sheet só com província; sem filtro por features; TransactionType só sale/rent |
| 4 Comparação/Favoritos | ✅ quase completa | comparação não inclui terrenos; fetchFavorite* não carrega imagens; erro de pesquisa não mostrado |
| 5 Trust | ❌ só fundação BD | 018 cria verified/reports/moderation_log mas: sem botão reportar, sem ecrã moderação, sem ação verificar em admin_users, sem badge. Privacidade ✅ |
| 6 Studio | ✅ com lacunas | sem preview do anúncio; sem gestão "minhas publicações" (form força isAvailable:true); sem progresso/resume; **furo RLS** images 002:118-134 |
| 7 Notificações/Personalização | ⚠️ infra OK | deep link **partido** (sem arguments); recomendações 0%; alertas 0%; sem visibility ecrã bloqueado; token FCM não removido no sign-out; deep_links.dart não corresponde às rotas |
| 8 Desempenho | ❌ maioritariamente ausente | sem cache de imagens; sem thumbnails de vídeo; sem connectivity; sem métricas; decode full-res |
| 9 Segurança/Qualidade | ⚠️ parcial | RLS/anon/.env ✅; integration test não corre no CI; .env nos assets; navegação por payload sem allowlist; testes não cobrem providers novos |

---

## Etapas (executar por ordem)

### Etapa 0 — Bugs críticos (bloqueante)
- [x] 0.1 Deep link: `pushNamed` com `arguments` (id), allowlist de rotas, URLs de `deep_links.dart` alinhadas com `/properties/:id`, remover delay 500ms vs splash — `notification_service.dart:88-91,216-224`, `deep_links.dart`, `routes.dart`
- [x] 0.2 Parar vídeo ao sair do tab Discover (RouteAware/`ModalRoute.isCurrent`) — `discover_screen.dart`, `main_shell.dart`, `video_player_widget.dart`
- [x] 0.3 ~~Migration 020: restringir `property_images`/`land_images` a owner/admin~~ — **cancelada:** já resolvido pela migration 007 (`007_security_fixes.sql:99-148`, policies owner/admin com `WITH CHECK`)
- [x] 0.4 `deleteToken()` no sign-out (remove linha em `device_tokens`) + `visibility: private` nas notificações — `auth_provider.dart:100`, `notification_service.dart:207`
- [x] 0.5 Validar payload route contra `AppRoutes` conhecidas — `notification_service.dart:222` (`AppRoutes.parse`)
- [x] 0.6 `flutter analyze` + `flutter test` verdes (402 testes)

### Etapa 1 — Fase 5 Trust ✅ (2026-10-15)
- [x] Botão/dialogo "Reportar anúncio" em property_detail e land_detail → tabela `reports`
- [x] `ReportRepository` + `ReportProvider` + testes unitários (model + provider)
- [x] `admin_reports.dart`: listar, filtrar por estado, ocultar anúncio, verificar agente → `moderation_log`
- [x] Badge "Verificado" só se `agent_verified=true` (cartões + detalhe, widget `VerifiedBadge`)
- [x] Ação "Verificar" em `admin_users.dart` (verified/verified_at/verified_by via trigger 018)
- [x] Strings PT/EN nos `.arb` + `flutter gen-l10n`

### Etapa 2 — Fase 8 Desempenho
- [ ] `cached_network_image` + limites `imageCache` + `cacheWidth`
- [ ] Poster/primeira imagem como fallback antes do vídeo carregar
- [ ] Definição "desativar autoplay" persistida (settings_sheet + shared_preferences)
- [ ] `connectivity_plus`: aviso offline + retry/backoff
- [ ] Limite/evicção de `_items` no DiscoverProvider + corrigir corridas do VideoPlayerWidget
- [ ] Pull-to-refresh + filtros no ecrã Discover

### Etapa 3 — Fase 7 Notificações/Personalização
- [ ] Deep link ponta-a-ponta testado (notificação → detalhe)
- [ ] Preferências de notificação em app; token no sign-out
- [ ] Pesquisas guardadas: tabela `saved_searches` (migration 020) + RLS + botão "Guardar pesquisa" + alertas
- [ ] Recomendações por regras transparentes (recentes da província / favoritos) sem IA

### Etapa 4 — Fase 3 Mapa/Pesquisa
- [ ] Dependência `flutter_map` + `flutter_map_marker_cluster`
- [ ] Ecrã de mapa com marcadores reais (lat/lng válidos) + sincronização marcador↔lista
- [ ] Secção de localização dos detalhes a renderizar mapa real
- [ ] Ordenação na UI (preço ↑↓, área, recentes)
- [ ] Filtros: município/bairro no sheet, features, estado de erro com retry

### Etapa 5 — Fase 6 Studio completo
- [ ] Ecrã de pré-visualização do anúncio antes de publicar
- [ ] Ecrã "Minhas publicações" (filtro agent_id): editar/ativar/desativar/eliminar; deixar de forçar `isAvailable:true` (`property_form_screen.dart:251`)
- [ ] Progresso por ficheiro + limpeza de uploads órfãos
- [ ] Compressão de vídeo (ou limite documentado)

### Etapa 6 — Fase 4 fecho + Fase 9 qualidade
- [ ] Comparação de terrenos (estender ComparisonProvider a LandModel) ou justificar exclusão
- [ ] `fetchFavoriteProperties/Lands` a carregar imagens
- [ ] Testes: comparison_provider, search_provider, notification deep link, widget discover_screen, admin_reports
- [ ] CI: correr integration tests (hoje só analyze+unit+build)
- [ ] `.env` fora dos assets do build
- [ ] Reescrever `docs/auditoria.md` + **Relatório Final** do Documento.md
- [ ] Atualizar `AGENTS.md` com os 5 agentes (ou confirmar recusa)

**Migrações novas:** 020 (saved_searches), 021 (alertas/recomendações se necessário).
**Dependências novas:** flutter_map, flutter_map_marker_cluster, cached_network_image, connectivity_plus.

---

## Sessão 2026-10-15 (blocos escolhidos: Preço Kz, Discover, Filtros, Perfil) — CONCLUÍDA

Decisões do utilizador: "Pacote rápido (Recomendado)", "Discover completo", "Filtros completo",
"Perfil de agente". Não escolhidos: Favoritos em lista, Detalhe com tabs, Tema dark por omissão,
ecrã de mapa (sem `flutter_map`).

### Feito
- **Preço em Kz** (`formatPrice` → sufixo `Kz` em vez de prefixo `AOA`): `formatters.dart`,
  `price_tag.dart`, detalhe de imóvel/terreno (partilha + preço), `admin_lands.dart`, arbs.
- **Likes reais sem números falsos:** `FavoriteRepository.countLikes` + `FavoriteProvider.loadLikeCounts`
  no Discover (sem contagens de comentários — não existe sistema de comentários).
- **Discover completo:** tabs segmentadas Descobrir/Pesquisar/Favoritos, botão de comparação com badge,
  cartão de rodapé ("Ver imóvel", contador de imagens 1/N), rail de ações compacto.
- **Filtros completo:** novo ecrã `lib/screens/search/filters_screen.dart` (rota `/filters`) com chips
  Comprar/Arrendar/Todos, Província/Município (`locations` via `LocationRepository`), Preço Mín/Máx (Kz),
  grelha de categorias, Finalidade (Residencial/Comercial → `purposePropertyTypes`, só imóveis),
  área, quartos/WC/garagem. `SearchProvider.purpose` + `types` no `searchAdvanced`;
  antigo bottom sheet removido do `search_screen.dart`.
- **Perfil de agente:** header com função + badge "Verificado" (só se `verified`), estatísticas reais
  (Anúncios via `countByAgent`, Favoritos, Mensagens = conversas; sem seguidores/rating — não existem
  na BD), ações "Editar perfil" + engrenagem (`showSettingsSheet`), menu "Definições".
- **"Os meus anúncios"** (rota `/my-listings`, agentes/admin): tabs Imóveis/Terrenos,
  `fetchByAgent` em ambos os repositórios, ativar/desativar (`setAvailable`), editar via form,
  "Novo anúncio" (imóvel/terreno), estado vazio `EmptyState`. **Eliminar não existe aqui:**
  RLS só permite `DELETE` a admin (002) e o `delete` do repo é soft-delete com limpeza de imagens.

### Resta desta sessão (opcional)
- [ ] "Eliminar" no ecrã de gestão (apenas admin) ou esclarecer soft-delete nas telas de gestão
- [ ] Testes de widget para `filters_screen` / `my_listings_screen` (hoje só unit de `purposePropertyTypes`)
- [ ] Notificações como item de menu (não há ecrã/BD de preferências — não inventado)

`flutter analyze` limpo; `flutter test` = **407 testes** (402 + 5 novos de finalidade).
