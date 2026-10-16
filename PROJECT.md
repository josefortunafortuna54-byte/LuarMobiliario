# Luar Company Imobiliária

## Informações do Projeto

| Campo | Valor |
|---|---|
| **Nome** | Luar Company Imobiliária |
| **Versão** | 1.0.1+14 |
| **Descrição** | Plataforma imobiliária premium para o mercado angolano |
| **Slogan** | Seu novo lar começa aqui |
| **Licença** | Todos os direitos reservados © Luar Company Imobiliária |

---

## Descrição

A **Luar Company Imobiliária** é uma plataforma completa de imobiliária desenvolvida para o mercado angolano. Permite aos utilizadores pesquisar, filtrar, favoritar e contactar agentes sobre propriedades e terrenos para venda ou arrendamento em toda Angola.

A aplicação combina uma experiência mobile premium com um backend robusto baseado em Supabase, entregando funcionalidades como pesquisa avançada, sistema de mensagens, agendamento de visitas, notificações push e painel administrativo.

---

## Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| Frontend Mobile | Flutter 3.x (Dart SDK ^3.12.1) |
| Backend / BaaS | Supabase (PostgreSQL, Auth, Storage, Realtime) |
| Estado | Provider (ChangeNotifier) |
| Notificações Push | Firebase Cloud Messaging + flutter_local_notifications |
| Fontes | Google Fonts (DM Sans + Playfair Display) |
| Formatação de Dados | intl |
| Partilha | share_plus |
| Gestão de configuração | `--dart-define` (via `.env` local; não empacotado) |
| CI/CD | GitHub Actions |
| Plataformas | Android, iOS, Web |

---

## Equipa de Contacto

| Canal | Informação |
|---|---|
| **Email Geral** | geral@luarcompany.ao |
| **Telefone** | +244 923 456 789 |
| **WhatsApp** | +244 923 456 789 |
| **Instagram** | [@luarcompany](https://instagram.com/luarcompany) |
| **Facebook** | [/luarcompany](https://facebook.com/luarcompany) |
| **LinkedIn** | [/company/luarcompany](https://linkedin.com/company/luarcompany) |
| **YouTube** | [@luarcompany](https://youtube.com/@luarcompany) |
| **Website** | [luarcompany.ao](https://luarcompany.ao) |

---

## Início Rápido

### Pré-requisitos

- Flutter SDK >= 3.12.1
- Dart SDK (incluso no Flutter)
- Android Studio ou VS Code com extensões Flutter/Dart
- Conta Supabase ([supabase.com](https://supabase.com))
- Git

### Instalação

```bash
# 1. Clonar o repositório
git clone https://github.com/josefortunafortuna54-byte/LuarMobiliario.git
cd LuarMobiliario

# 2. Configurar variáveis de ambiente
cp .env.example luar_company/.env
# Editar luar_company/.env com os valores do seu projeto Supabase

# 3. Instalar dependências
cd luar_company
flutter pub get

# 4. Executar (injeta as variáveis do .env em tempo de build)
flutter run --dart-define-from-file=.env
```

### Variáveis de Ambiente

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-aqui
FCM_SENDER_ID=seu-sender-id        # opcional
FCM_PROJECT_ID=seu-project-id      # opcional
FCM_API_KEY=                       # opcional
FCM_APP_ID=                        # opcional
```

### Builds de Produção

```bash
flutter build apk --release --dart-define-from-file=.env          # Android APK
flutter build appbundle --release --dart-define-from-file=.env    # Android AAB (Play Store)
flutter build ios --release --dart-define-from-file=.env          # iOS
flutter build web --release --dart-define-from-file=.env          # Web
```

---

## Funcionalidades Principais

- **Autenticação**: Login e registo via email/senha com Supabase Auth
- **Pesquisa Avançada**: Filtros por tipo, transação, preço, área, quartos, localização e características; ordenação
- **Pesquisas Guardadas**: Guardar e reutilizar conjuntos de filtros
- **Luar Discover**: Feed vertical de imóveis (vídeo/imagem)
- **Comparação**: Comparar imóveis lado a lado
- **Propriedades**: Lista e detalhe com galeria de fotos, vídeos e informações do agente
- **Terrenos**: Lista e detalhe de terrenos (urbano, agrícola, industrial, comercial)
- **Favoritos**: Gestão de propriedades e terrenos favoritos
- **Avaliações**: Avaliações de imóveis (1–5 estrelas) com comentários
- **Mensagens**: Sistema de comunicação entre utilizadores e agentes
- **Agendamentos**: Agendamento de visitas a imóveis e terrenos
- **Perfil**: Gestão de perfil com avatar; anúncios e verificações
- **Painel Administrativo**: Dashboard, análise de métricas, moderação e gestão de utilizadores/anúncios
- **Notificações Push**: Alertas via Firebase Cloud Messaging, com preferências por categoria
- **Internacionalização**: PT/EN
- **WhatsApp**: Contacto rápido com agentes

---

## Estrutura do Projeto

```
Luar-Mobiliario/
├── luar_company/          # Aplicação Flutter
│   ├── lib/
│   │   ├── main.dart      # Ponto de entrada
│   │   ├── app.dart       # Configuração MaterialApp
│   │   ├── core/          # Lógica de negócio
│   │   ├── screens/       # Ecrãs da aplicação
│   │   ├── widgets/       # Componentes reutilizáveis
│   │   └── l10n/          # Traduções (PT/EN)
│   └── test/              # Testes
├── docs/                  # Documentação
├── assets/                # Recursos estáticos
├── scripts/               # Scripts de automação
├── logo/                  # Logotipo
├── index.html             # Landing page
├── css/                   # Estilos da landing page
└── js/                    # Scripts da landing page
```

---

## Documentação Relacionada

- [Arquitetura](docs/ARCHITECTURE.md)
- [Base de Dados](docs/DATABASE.md)
- [API](docs/API.md)
- [Guia de Deploy](docs/DEPLOYMENT.md)
- [Segurança](docs/SECURITY.md)
- [Design System](DESIGN_SYSTEM.md)
- [Roadmap](ROADMAP.md)
- [Tarefas](TASKS.md)
- [Guia de Contribuição](CONTRIBUTING.md)
- [Registo de Alterações](CHANGELOG.md)
