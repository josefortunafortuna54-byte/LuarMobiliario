# Arquitetura do Projeto

Documento técnico que descreve a arquitetura, padrões e decisões de design da plataforma Luar Company Imobiliária.

---

## Visão Geral

O projeto é composto por duas partes principais:

1. **Aplicação Flutter** (`luar_company/`) — App mobile multiplataforma
2. **Landing Page** (`index.html`, `css/`, `js/`) — Página web institucional

A aplicação Flutter utiliza o Supabase como plataforma backend (BaaS), eliminando a necessidade de um servidor customizado.

---

## Arquitetura da Aplicação Flutter

### Padrão: Layered Architecture com Repository

```
┌─────────────────────────────────────────┐
│                  UI                     │
│   Screens → Widgets → Components        │
├─────────────────────────────────────────┤
│                State                    │
│         Providers (ChangeNotifier)      │
├─────────────────────────────────────────┤
│              Business Logic             │
│          Providers (orchestration)      │
├─────────────────────────────────────────┤
│               Data Layer                │
│         Repositories → Services         │
├─────────────────────────────────────────┤
│             External APIs               │
│             Supabase · Firebase         │
└─────────────────────────────────────────┘
```

### Camadas

#### 1. UI (Screens + Widgets + Components)

- **Screens**: Ecrãs completos da aplicação, cada um mapeado para uma rota
- **Widgets**: Componentes reutilizáveis de UI (PropertyCard, PriceTag, SearchWidget, etc.)
- **Components**: Elementos estruturais de layout (Header, BottomNav, EmptyState)

#### 2. State (Providers)

Providers baseados em `ChangeNotifier` que expõem o estado reativo à UI:

- Cada Provider encapsula a lógica de um domínio
- A UI ouve alterações via `context.watch<T>()` ou `context.read<T>()`
- Providers são registados no `MultiProvider` em `main.dart`

#### 3. Data Layer (Repositories + Services)

- **Repositories**: Abstraem o acesso a dados. Cada domínio tem o seu repositório
  - `PropertyRepository` — CRUD e pesquisas de propriedades
  - `LandRepository` — CRUD e pesquisas de terrenos
  - `AuthRepository` — Operações de autenticação
  - `FavoriteRepository` — Gestão de favoritos
  - `BookingRepository` — Gestão de agendamentos
  - `MessageRepository` — Gestão de mensagens
  - `AdminRepository` — Painel administrativo (estatísticas, utilizadores, analytics)
  - `ReviewRepository` — Avaliações de imóveis
  - `ReportRepository` — Denúncias/moderação
  - `PartnerRepository` — Parceiros imobiliários
  - `SavedSearchRepository` — Pesquisas guardadas
  - `LocationRepository` — Localizações geográficas

- **Services**: Integrações com serviços externos
  - `SupabaseService` — Inicialização e instância do cliente Supabase
  - `AuthService` — Autenticação via Supabase Auth
  - `StorageService` — Upload/download de ficheiros via Supabase Storage
  - `NotificationService` — Notificações push via Firebase (com preferências por categoria)
  - `ConnectivityService` — Estado da ligação de rede

#### 4. External APIs

- **Supabase**: PostgreSQL, Auth, Storage
- **Firebase Cloud Messaging**: Notificações push

---

## Fluxo de Dados Detalhado

### Exemplo: Carregar propriedades

```
1. User abre ecrã de propriedades
2. PropertiesScreen chama context.read<PropertyProvider>().loadProperties()
3. PropertyProvider chama PropertyRepository.getProperties(filtros)
4. PropertyRepository faz query ao Supabase via SupabaseService.client
5. Supabase retorna JSON
6. PropertyRepository converte JSON → List<PropertyModel>
7. PropertyProvider atualiza o estado e chama notifyListeners()
8. UI rebuild com os novos dados
```

### Exemplo: Login

```
1. User insere email/senha e clica "Entrar"
2. LoginScreen chama context.read<AuthProvider>().signIn(email, password)
3. AuthProvider chama AuthService.signInWithEmail()
4. AuthService usa Supabase.instance.client.auth.signInWithPassword()
5. Supabase retorna sessão
6. AuthProvider chama AuthService.getCurrentUser() para obter perfil
7. AuthProvider atualiza _user e notifica listeners
8. UI rebuild, navega para HomeScreen
```

---

## Modelos de Dados

Todos os modelos estão em `lib/core/models/` e seguem o padrão:

```dart
class ModelName {
  // Campos imutáveis (final)
  // Construtor const
  // factory fromJson(Map<String, dynamic>) — deserialização
  // toJson() — serialização
  // copyWith() — imutabilidade
}
```

### Modelos Principais

| Modelo | Descrição |
|---|---|
| `UserModel` | Utilizador (id, nome, email, telefone, avatar, role, verificação) |
| `PropertyModel` | Propriedade (título, tipo, preço, área, localização, imagens/vídeos, agente) |
| `LandModel` | Terreno (título, tipo, preço, área, localização, imagens/vídeos, agente) |
| `FavoriteModel` | Registo de favorito |
| `BookingModel` | Agendamento de visita (imóvel ou terreno) |
| `MessageModel` | Mensagem entre utilizadores |
| `PartnerModel` | Parceiro imobiliário |
| `ReviewModel` | Avaliação de imóvel |
| `ReportModel` | Denúncia de anúncio/utilizador |
| `SavedSearchModel` | Pesquisa guardada (snapshot de filtros) |

> Coordenadas geográficas (`latitude`/`longitude`) e localizações são tratadas nos próprios modelos de `Property`/`Land`.

---

## Autenticação e Autorização

### Autenticação

- Supabase Auth com email/senha
- Sessão mantida automaticamente pelo Supabase Flutter SDK
- `AuthProvider` monitoriza o estado da sessão

### Autorização (Roles)

| Role | Permissões |
|---|---|
| `client` | Ver propriedades, favoritos, agendar visitas, mensagens |
| `agent` | Tudo o que o client + gerir as suas propriedades |
| `admin` | Acesso total: gestão de utilizadores, propriedades e dashboard |

---

## Navegação

- Rotas nomeadas definidas em `lib/core/utils/routes.dart`
- `onGenerateRoute` com transições personalizadas (slide + fade)
- Navegação por argumentos para detalhes (ex: `PropertyDetailScreen` recebe o ID)

---

## Tema e Design System

- **Cores**: Navy (#0F1B2D) + Gold (#C9A84C) — identidade visual premium
- **Fonte**: DM Sans via Google Fonts
- **Material 3**: Design system moderno com `ColorScheme` personalizado
- **Constantes**: Espaçamentos, border radius, sombras e durações de animação centralizados em `AppConstants`

---

## Storage (Supabase)

| Bucket | Conteúdo |
|---|---|
| `property-images` | Imagens de propriedades e terrenos |
| `property-videos` | Vídeos de propriedades e terrenos |
| `avatars` | Avatares de utilizadores |

> Os buckets `documents` e `products` referidos em documentação antiga **não** são criados pelas migrações atuais.

---

## Estrutura de Pastas

```
luar_company/lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/env_config.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   └── app_text_styles.dart
│   ├── models/            (10 modelos: property, land, user, favorite,
│   │                       booking, message, partner, review, report,
│   │                       saved_search)
│   ├── providers/         (18 providers: auth, property, land, search,
│   │                       favorite, booking, message, admin, discover,
│   │                       comparison, review, report, partner, saved_search,
│   │                       notification_settings, locale, theme, playback)
│   ├── repositories/      (12 repositórios)
│   ├── services/          (supabase, auth, storage, notification,
│   │                       notification_preferences, connectivity)
│   └── utils/
│       ├── routes.dart
│       ├── formatters.dart
│       ├── validators.dart
│       └── navigation.dart
├── screens/     (16 módulos)
├── widgets/     (17 componentes)
└── l10n/        (PT/EN)
```
