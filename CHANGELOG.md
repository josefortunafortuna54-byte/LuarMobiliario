# Changelog

Todas as alterações notáveis neste projeto são documentadas neste ficheiro.

O formato baseia-se em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adota o [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [Unreleased]

### Alterado

- **Agendamentos**: Após confirmar a marcação de visita, o cliente é registado
  pedindo apenas nome + telefone (`register_guest_client` RPC). O perfil é criado
  em `users` com email sintético `@guest.luar` e ligado à marcação.
- **Perfil (visitante)**: Texto atualizado para refletir o registo automático
  após agendar uma visita.

### Removido

- **Código morto**: ecrã `HomeScreen` (substituído por `MainShell` + separadores)
  removido do repositório.

### Corrigido

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
