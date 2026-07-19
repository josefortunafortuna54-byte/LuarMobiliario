# Luar Company — Aplicação Flutter

Aplicação mobile multiplataforma (Android, iOS, Web) desenvolvida em Flutter para a plataforma imobiliária Luar Company Imobiliária.

---

## Descrição

O app permite aos utilizadores:

- Pesquisar propriedades e terrenos com filtros avançados (tipo, preço, área, localização, quartos)
- Ver detalhes completos com galeria de fotos, mapa e informações do agente
- Guardar favoritos e agendar visitas
- Contactar agentes via WhatsApp ou mensagens dentro da app
- Gerir o perfil e preferências
- Painel administrativo para gestão de propriedades, terrenos e utilizadores

---

## Requisitos

- Flutter SDK >= 3.12.1
- Dart SDK >= 3.12.1
- Android Studio / Xcode / VS Code
- Dispositivo físico ou emulador

---

## Como Executar

```bash
# 1. Navegar até à pasta do projeto Flutter
cd luar_company

# 2. Instalar dependências
flutter pub get

# 3. Configurar variáveis de ambiente
cp ../.env.example .env
# Editar .env com os valores do seu projeto Supabase

# 4. Executar
flutter run
```

### Comandos Úteis

```bash
flutter run                    # Executar em modo debug
flutter run --release          # Executar em modo release
flutter run -d chrome          # Executar no navegador
flutter test                   # Executar testes
flutter analyze                # Verificar código
flutter build apk --release    # Build APK Android
flutter build ios --release    # Build iOS
flutter build web --release    # Build Web
```

---

## Arquitetura

A aplicação segue uma arquitetura em camadas inspirada no padrão **Repository**:

```
lib/
├── main.dart              # Inicialização: dotenv, Supabase, Providers
├── app.dart               # MaterialApp com tema, rotas e configuração
├── core/
│   ├── config/            # EnvConfig — leitura de variáveis .env
│   ├── constants/         # AppColors, AppTextStyles, AppConstants
│   ├── models/            # Data classes com serialização JSON
│   ├── providers/         # ChangeNotifier para estado reativo
│   ├── repositories/      # Acesso a dados via Supabase
│   ├── services/          # Auth, Supabase client, Storage, Notificações
│   └── utils/             # Rotas, validadores, formatadores
├── screens/               # Ecraãs organizadas por módulo
├── widgets/               # Componentes reutilizáveis (PropertyCard, PriceTag, etc.)
└── components/            # Header, BottomNav, EmptyState
```

### Fluxo de Dados

```
UI (Screen) → Provider (ChangeNotifier) → Repository → Supabase Service → Supabase API
```

1. **Screen** interage com o utilizador e notifica o Provider
2. **Provider** orquestra a lógica de negócio e notifica a UI
3. **Repository** executa queries ao Supabase
4. **SupabaseService** mantém a instância do cliente Supabase

### Providers

| Provider | Responsabilidade |
|---|---|
| `AuthProvider` | Autenticação, sessão, perfil do utilizador |
| `PropertyProvider` | Lista, detalhe e filtros de propriedades |
| `LandProvider` | Lista, detalhe e filtros de terrenos |
| `SearchProvider` | Pesquisa global |
| `FavoriteProvider` | Gestão de favoritos |
| `BookingProvider` | Agendamento de visitas |

### Rotas

| Rota | Ecrã |
|---|---|
| `/` | SplashScreen |
| `/login` | LoginScreen |
| `/register` | RegisterScreen |
| `/home` | HomeScreen |
| `/search` | SearchScreen |
| `/properties` | PropertiesScreen |
| `/properties/:id` | PropertyDetailScreen |
| `/lands` | LandsScreen |
| `/lands/:id` | LandDetailScreen |
| `/favorites` | FavoritesScreen |
| `/messages` | MessagesScreen |
| `/profile` | ProfileScreen |
| `/bookings` | BookingsScreen |
| `/admin/dashboard` | AdminDashboard |
| `/admin/properties` | AdminPropertiesScreen |
| `/admin/users` | AdminUsersScreen |

---

## Variáveis de Ambiente

O ficheiro `.env` deve estar em `luar_company/.env`:

```env
# Supabase (obrigatório)
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon

# Firebase Cloud Messaging (opcional)
FCM_SENDER_ID=seu-sender-id
FCM_PROJECT_ID=seu-project-id
```

O `EnvConfig` (`lib/core/config/env_config.dart`) lê estas variáveis via `flutter_dotenv`.

---

## Testes

```bash
# Executar todos os testes
flutter test

# Executar com cobertura
flutter test --coverage

# Ver relatório de cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Os testes encontram-se em `test/`. Adicione novos ficheiros de teste seguindo o padrão `*_test.dart`.

---

## Dependências Principais

| Pacote | Uso |
|---|---|
| `supabase_flutter` | Cliente Supabase (Auth, DB, Storage) |
| `provider` | Gestão de estado |
| `flutter_dotenv` | Variáveis de ambiente |
| `google_fonts` | Tipografia DM Sans |
| `cached_network_image` | Cache de imagens |
| `image_picker` | Seleção de imagens |
| `google_maps_flutter` | Integração com Google Maps |
| `geolocator` | Localização do dispositivo |
| `geocoding` | Conversão de endereços |
| `firebase_messaging` | Notificações push |
| `flutter_local_notifications` | Notificações locais |
| `url_launcher` | Abrir URLs externas |
| `shimmer` | Efeitos de loading |
| `photo_view` | Visualização de imagens |
