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
│                   UI                     │
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
│      Supabase · Firebase · Google Maps  │
└─────────────────────────────────────────┘
```

### Camadas

#### 1. UI (Screens + Widgets + Components)

- **Screens**: Ecraãs completas da aplicação, cada uma mapeada para uma rota
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

- **Services**: Integrações com serviços externos
  - `SupabaseService` — Inicialização e instância do cliente Supabase
  - `AuthService` — Autenticação via Supabase Auth
  - `StorageService` — Upload/download de ficheiros via Supabase Storage
  - `NotificationService` — Notificações push via Firebase

#### 4. External APIs

- **Supabase**: PostgreSQL, Auth, Storage, Realtime
- **Firebase Cloud Messaging**: Notificações push
- **Google Maps**: Mapas e geolocalização

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
| `UserModel` | Utilizador (id, nome, email, telefone, avatar, role) |
| `PropertyModel` | Propriedade (título, tipo, preço, área, localização, imagens, agente) |
| `LandModel` | Terreno (título, tipo, preço, área, localização, imagens, agente) |
| `CategoryModel` | Categoria de propriedade |
| `FavoriteModel` | Registo de favorito |
| `BookingModel` | Agendamento de visita |
| `MessageModel` | Mensagem entre utilizadores |
| `LocationModel` | Coordenadas geográficas |

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
| `property-images` | Imagens de propriedades |
| `avatars` | Avatares de utilizadores |
| `documents` | Documentos |
| `products` | Imagens de produtos |

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
│   ├── models/
│   │   ├── property_model.dart
│   │   ├── land_model.dart
│   │   ├── user_model.dart
│   │   ├── category_model.dart
│   │   ├── favorite_model.dart
│   │   ├── booking_model.dart
│   │   ├── message_model.dart
│   │   └── location_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── property_provider.dart
│   │   ├── land_provider.dart
│   │   ├── search_provider.dart
│   │   ├── favorite_provider.dart
│   │   └── booking_provider.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── property_repository.dart
│   │   ├── land_repository.dart
│   │   ├── favorite_repository.dart
│   │   ├── booking_repository.dart
│   │   └── message_repository.dart
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   └── utils/
│       ├── routes.dart
│       ├── formatters.dart
│       └── validators.dart
├── screens/     (11 módulos)
├── widgets/     (10 componentes)
└── components/  (3 componentes)
```
