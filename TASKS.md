# Tarefas do Projeto

Registo de tarefas concluídas, em curso e pendentes da plataforma Luar Company Imobiliária.

> Plano detalhado de evolução para plataforma premium (9 fases): ver [Documento.md](Documento.md).

---

## Concluídas ✅

### v1.0.0 — Funcionalidades Principais (Julho 2026)

| ID | Tarefa | Módulo |
|---|---|---|
| T-001 | Configuração do projeto Flutter com Supabase | Infraestrutura |
| T-002 | Arquitetura em camadas (UI → Provider → Repository) | Infraestrutura |
| T-003 | Sistema de variáveis de ambiente (`--dart-define`) | Infraestrutura |
| T-004 | Design system navy/gold com Material 3 | Infraestrutura |
| T-005 | Tema personalizado (cores, tipografia, botões, inputs) | Infraestrutura |
| T-006 | Rotas nomeadas com transições slide+fade | Infraestrutura |
| T-007 | Modelos de dados (User, Property, Land, Booking, Message, etc.) | Core |
| T-008 | Serviços (Supabase, Auth, Storage, Notifications) | Core |
| T-009 | Repositórios (Property, Land, Auth, Favorite, Booking, Message, Admin) | Core |
| T-010 | Providers (Auth, Property, Land, Search, Favorite, Booking, Message, Admin) | Core |
| T-011 | Ecrã de arranque (Splash Screen) | UI |
| T-012 | Login e registo de utilizadores | Auth |
| T-013 | Ecrã principal com destaques, categorias e recentes | Home |
| T-014 | Lista de propriedades com filtros | Properties |
| T-015 | Detalhe de propriedade com galeria e agente | Properties |
| T-016 | Lista de terrenos com filtros | Lands |
| T-017 | Detalhe de terreno | Lands |
| T-018 | Pesquisa avançada multi-filtro | Search |
| T-019 | Sistema de favoritos (adicionar/remover) | Favorites |
| T-020 | Sistema de mensagens entre utilizadores e agentes | Messages |
| T-021 | Agendamento de visitas | Bookings |
| T-022 | Gestão de perfil com avatar | Profile |
| T-023 | Painel administrativo (dashboard, propriedades, utilizadores) | Admin |
| T-024 | Integração Firebase Cloud Messaging (notificações push) | Notifications |
| T-026 | Integração WhatsApp para contacto rápido | Comunicação |
| T-027 | Componentes reutilizáveis (PropertyCard, LandCard, PriceTag, etc.) | Widgets |
| T-028 | Landing page institucional (HTML/CSS/JS) | Web |
| T-029 | Testes unitários (models, constants) | Testes |
| T-030 | Testes de widget (CustomButton, PropertyCard) | Testes |
| T-031 | Documentação técnica (ARCHITECTURE, DATABASE, SECURITY, DEPLOYMENT) | Docs |

---

### v1.0.1 — Evolução Premium (Outubro 2026)

| ID | Tarefa | Módulo |
|---|---|---|
| T-032 | CI/CD com GitHub Actions (analyze + testes + build APK/AAB/Web) | Infraestrutura |
| T-037 | Conteúdo dinâmico na landing page (propriedades em destaque) | Web |
| T-038 | Otimização de performance (cached_network_image, limites de cache) | Performance |
| T-039 | Otimização de queries na base de dados (migration 025) | Database |
| T-043 | Vídeos de propriedades (upload, player e viewer) | Media |
| T-044 | Sistema de internacionalização (PT/EN) | i18n |
| T-045 | Dashboard de analytics para administradores (migrations 025/026) | Admin |
| T-047 | Sistema de avaliações de imóveis (1–5 estrelas) | Social |
| T-048 | Notificações refinadas com categorias e preferências | Notifications |
| T-051 | Luar Discover (feed vertical) | Discover |
| T-052 | Comparação de imóveis lado a lado | Comparison |
| T-053 | Pesquisas guardadas | Search |
| T-054 | Base de segurança e confiança (Trust): verificação, denúncias, moderação | Segurança |

---

## Em Curso 🔄

| ID | Tarefa | Módulo | Prioridade |
|---|---|---|---|
| T-033 | Aumentar cobertura de testes (unit + widget + integration no CI) | Testes | Alta |
| T-034 | Configuração de assinatura de APK (key keystore/secrets) | Android | Alta |
| T-035 | Configuração de bundle identifier para Play Store | Android | Alta |
| T-036 | Testes de integração com Supabase | Testes | Média |
| T-055 | Comparação de terrenos (para além de imóveis) | Comparison | Média |

---

## Pendentes (Backlog) ⏳

| ID | Tarefa | Módulo | Prioridade |
|---|---|---|---|
| T-040 | Testes de acessibilidade (semântica, contraste, navegação) | UX | Média |
| T-041 | Testes em múltiplos dispositivos e versões de SO | QA | Média |
| T-042 | Pesquisa por mapa com clusters | Search | Alta |
| T-046 | Integração de pagamentos (Multicaixa Express) | Pagamentos | Alta |
| T-049 | Modo offline com cache local | Offline | Baixa |
| T-050 | Publicação na Google Play Store | Deploy | Alta |

---

## Legenda

| Ícone | Significado |
|---|---|
| ✅ | Concluída |
| 🔄 | Em curso |
| ⏳ | Pendente |

| Prioridade | Significado |
|---|---|
| Alta | Deve ser feita antes do próximo lançamento |
| Média | Importante mas não bloqueante |
| Baixa | Pode aguardar |
