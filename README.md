# Luar Company Imobiliária

**Seu novo lar começa aqui.**

Plataforma imobiliária completa para o mercado angolano, desenvolvida com Flutter e Supabase. Permite aos utilizadores pesquisar, filtrar e contactar agentes sobre propriedades e terrenos para venda ou arrendamento em toda Angola.

---

## Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| Frontend Mobile | Flutter 3.x (Dart SDK ^3.12.1) |
| Backend / BaaS | Supabase (PostgreSQL, Auth, Storage, Realtime) |
| Estado | Provider |
| Notificações Push | Firebase Cloud Messaging + flutter_local_notifications |
| Fontes | Google Fonts (DM Sans) |
| Formatação de Dados | intl |
| Partilha | share_plus |
| Gestão de configuração | `--dart-define` (via `.env` local; não empacotado) |
| CI/CD | GitHub Actions |

---

## Arquitetura

```
UI (Screen) → Provider → Repository → Supabase Service → Supabase API
```

Os ecrãs consomem `Provider`s (ChangeNotifier), que delegam nos `Repository`s, que por sua vez falam com o Supabase através dos `Service`s. Detalhes em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## Pré-requisitos

- **Flutter SDK** >= 3.12.1 — [Instalar Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (incluso no Flutter)
- **Android Studio** ou **VS Code** com extensões Flutter/Dart
- **Conta Supabase** — [supabase.com](https://supabase.com)
- **Conta Firebase** (opcional, para notificações push) — [firebase.google.com](https://firebase.google.com)
- **Git**

---

## Como Executar

### 1. Clonar o repositório

```bash
git clone https://github.com/josefortunafortuna54-byte/LuarMobiliario.git
cd LuarMobiliario
```

### 2. Configurar variáveis de ambiente

```bash
cp .env.example luar_company/.env
```

Edite o ficheiro `luar_company/.env` com os seus valores:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-aqui
FCM_SENDER_ID=seu-sender-id        # opcional
FCM_PROJECT_ID=seu-project-id      # opcional
FCM_API_KEY=                       # opcional
FCM_APP_ID=                        # opcional
```

> O `.env` **não** é empacotado como asset: os valores são injetados em tempo de build via `--dart-define` (ver `scripts/build_*.sh`).

### 3. Instalar dependências

```bash
cd luar_company
flutter pub get
```

### 4. Executar a aplicação

```bash
# Emulator ou dispositivo conectado (injeta as variáveis do .env)
flutter run --dart-define-from-file=.env

# Executar em modo web
flutter run -d chrome --dart-define-from-file=.env

# Verificar dispositivos disponíveis
flutter devices
```

### 5. Build de produção

```bash
# Android (APK)
flutter build apk --release --dart-define-from-file=.env

# iOS
flutter build ios --release --dart-define-from-file=.env

# Web
flutter build web --release --dart-define-from-file=.env
```

---

## Estrutura do Projeto

```
Luar-Mobiliario/
├── luar_company/                 # Aplicação Flutter
│   ├── lib/
│   │   ├── main.dart             # Ponto de entrada
│   │   ├── app.dart              # Configuração do MaterialApp
│   │   ├── core/
│   │   │   ├── config/           # Configuração de variáveis de ambiente
│   │   │   ├── constants/        # Cores, estilos, constantes da app
│   │   │   ├── models/           # Modelos de dados (Property, Land, User, etc.)
│   │   │   ├── providers/        # Providers (ChangeNotifier) para estado
│   │   │   ├── repositories/     # Camada de acesso a dados (Supabase)
│   │   │   ├── services/         # Serviços (Auth, Supabase, Storage, Notificações)
│   │   │   └── utils/            # Utilitários (rotas, validadores, formatadores)
│   │   ├── screens/              # Ecrãs da aplicação
│   │   │   ├── splash/           # Ecrã de arranque
│   │   │   ├── auth/             # Login e registo
│   │   │   ├── home/             # Ecrã principal
│   │   │   ├── search/           # Pesquisa
│   │   │   ├── properties/       # Lista e detalhe de propriedades
│   │   │   ├── lands/            # Lista e detalhe de terrenos
│   │   │   ├── favorites/        # Favoritos
│   │   │   ├── messages/         # Mensagens
│   │   │   ├── bookings/         # Agendamentos
│   │   │   ├── discover/         # Feed Luar Discover
│   │   │   ├── comparison/       # Comparação de imóveis
│   │   │   ├── videos/           # Visualização de vídeos
│   │   │   ├── profile/          # Perfil do utilizador
│   │   │   └── admin/            # Painel administrativo
│   │   ├── widgets/              # Componentes reutilizáveis
│   │   └── l10n/                 # Traduções (PT/EN)
│   ├── test/                     # Testes
│   ├── android/                  # Configuração Android
│   ├── ios/                      # Configuração iOS
│   └── web/                      # Configuração Web
├── assets/                       # Recursos estáticos
├── docs/                         # Documentação do projeto
├── scripts/                      # Scripts de automação
├── logo/                         # Logotipo
├── index.html                    # Landing page
├── css/                          # Estilos da landing page
├── js/                           # Scripts da landing page
├── .env.example                  # Exemplo de variáveis de ambiente
├── CHANGELOG.md                  # Registo de alterações
├── CONTRIBUTING.md               # Guia de contribuição
├── DESIGN_SYSTEM.md              # Design system
├── PROJECT.md                    # Informações do projeto
├── README.md                     # Este ficheiro
├── ROADMAP.md                    # Roadmap do projeto
└── TASKS.md                      # Tarefas em curso
```

---

## Variáveis de Ambiente

| Variável | Obrigatória | Descrição |
|---|---|---|
| `SUPABASE_URL` | Sim | URL do projeto Supabase |
| `SUPABASE_ANON_KEY` | Sim | Chave pública (anon) do Supabase |
| `FCM_SENDER_ID` | Não | ID do remetente Firebase Cloud Messaging |
| `FCM_PROJECT_ID` | Não | ID do projeto Firebase |
| `FCM_API_KEY` | Não | API key do Firebase (web/notificações) |
| `FCM_APP_ID` | Não | App ID do Firebase |

Consulte o ficheiro `.env.example` para a referência completa.

---

## Contribuir

Consulte o ficheiro [CONTRIBUTING.md](CONTRIBUTING.md) para orientações sobre como contribuir para este projeto.

---

## Licença

Todos os direitos reservados © Luar Company Imobiliária.
