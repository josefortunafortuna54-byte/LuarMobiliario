# Fluxos do Utilizador

Documentação dos principais fluxos de utilizador na plataforma Luar Company Imobiliária.

---

## 1. Fluxo de Onboarding

```
App arranca
  → Ecrã de Splash (logo + slogan + loader)
    → Verificar sessão existente (AuthProvider.init)
      → Sessão válida → HomeScreen
      → Sem sessão → LoginScreen
```

**Detalhes:**
- O Splash Screen exibe o logo e slogan da empresa
- O AuthProvider verifica automaticamente se existe uma sessão ativa no Supabase
- Se existir sessão, o utilizador é redirecionado para o HomeScreen
- Se não existir sessão, é redirecionado para o LoginScreen
- Orientação fixa: retrato (portraitUp + portraitDown)

---

## 2. Fluxo de Autenticação

### 2.1 Login

```
LoginScreen
  → Inserir email
  → Inserir senha
  → Clicar "Entrar"
    → AuthProvider.signIn(email, password)
      → AuthService.signInWithEmail()
        → Supabase Auth: signInWithPassword()
      → AuthService.getCurrentUser() → perfil completo
      → Sucesso → HomeScreen
      → Erro → SnackBar com mensagem de erro
```

**Validações:**
- Email: formato válido (regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
- Senha: não vazia
- Mensagens de erro do Supabase são exibidas no SnackBar

### 2.2 Registo

```
RegisterScreen
  → Inserir nome
  → Inserir email
  → Inserir senha
  → Clicar "Registar"
    → AuthProvider.signUp(email, password, name)
      → AuthService.signUpWithEmail()
        → Supabase Auth: signUp()
        → Upsert na tabela users (id, email, name, role='client')
      → AuthProvider.getCurrentUser()
      → Sucesso → HomeScreen
      → Erro → SnackBar com mensagem
```

**Regras:**
- Novo utilizador recebe role `client` por defeito
- O perfil é criado automaticamente na tabela `users` após registo

### 2.3 Logout

```
ProfileScreen
  → Clicar "Sair"
    → AuthProvider.signOut()
      → AuthService.signOut()
        → Supabase Auth: signOut()
      → _user = null
      → LoginScreen
```

---

## 3. Fluxo de Navegação Principal

```
HomeScreen (tab 0)
SearchScreen (tab 1)
FavoritesScreen (tab 2)
MessagesScreen (tab 3)
ProfileScreen (tab 4)
```

**Regras:**
- A Bottom Nav Bar está presente em todos os ecrãs principais
- Cada tab mantém o seu estado independentemente
- Navegação entre tabs é instantânea (sem transição)

---

## 4. Fluxo de Pesquisa de Propriedades

### 4.1 Pesquisa Rápida

```
HomeScreen
  → Tocar na barra de pesquisa
    → SearchScreen (com foco automático no input)
      → Digitar termo de pesquisa
        → SearchProvider.searchProperties(query)
          → PropertyRepository.searchProperties(query)
            → Supabase: .or('title.ilike...description.ilike...')
          → Resultados exibidos em lista
```

### 4.2 Pesquisa Avançada

```
SearchScreen
  → Tocar em "Filtros"
    → Bottom Sheet com opções de filtro:
      → Tipo de propriedade (Casa, Apartamento, etc.)
      → Tipo de transação (Venda, Arrendamento)
      → Faixa de preço (mínimo / máximo)
      → Área mínima / máxima
      → Número de quartos (1, 2, 3, 4, 5+)
      → Cidade
    → Aplicar filtros
      → SearchProvider.applyFilters(filtros)
        → PropertyRepository.getProperties(filtros)
          → Queries encadeadas ao Supabase
        → Resultados atualizados
    → Limpar filtros
      → Remove todos os filtros e recarrega
```

### 4.3 Filtrar por Categoria

```
HomeScreen
  → Tocar numa CategoryCard
    → PropertiesScreen (com filtro de tipo pré-selecionado)
      → Lista filtrada por tipo
```

---

## 5. Fluxo de Detalhe de Propriedade

```
PropertyCard (em qualquer lista)
  → Tocar no card
    → PropertyDetailScreen(id)
      → PropertyProvider.loadProperty(id)
        → PropertyRepository.getPropertyById(id)
          → Supabase: .from('properties').select().eq('id', id).single()
      → Exibir:
        → Galeria de imagens (swipeable)
        → Título e preço
        → Localização
        → Características (chips)
        → Descrição completa
        → Mapa (Google Maps)
        → Informações do agente
      → Ações:
        → ❤️ Favoritar / Remover favorito
        → 💬 Enviar mensagem ao agente
        → 📅 Agendar visita
        → 📞 Ligar ao agente
        → 💚 Contactar via WhatsApp
```

---

## 6. Fluxo de Favoritos

### 6.1 Adicionar Favorito

```
PropertyDetailScreen / PropertyCard
  → Tocar no ícone de favorito (coração)
    → FavoriteProvider.toggleFavorite(itemId, itemType)
      → FavoriteRepository:
        → Se já é favorito → remove
        → Se não é favorito → adiciona
      → Supabase: INSERT / DELETE na tabela favorites
    → Ícone anima (fill/vaziar)
    → SnackBar de confirmação
```

### 6.2 Ver Favoritos

```
BottomNav → "Favoritos" (tab 2)
  → FavoritesScreen
    → Tabs: Propriedades | Terrenos
      → FavoriteProvider.loadFavorites()
        → FavoriteRepository.getFavorites(userId)
          → Supabase: .from('favorites').select().eq('user_id', userId)
        → Para cada favorito, carrega detalhe do item
      → Lista de PropertyCards / LandCards
      → Estado vazio: "Nenhum favorito ainda"
```

---

## 7. Fluxo de Agendamento

```
PropertyDetailScreen
  → Tocar "Agendar Visita"
    → Bottom Sheet / Diálogo:
      → Selecionar data e hora
      → Adicionar notas (opcional)
      → Clicar "Confirmar"
        → BookingProvider.createBooking(booking)
          → BookingRepository:
            → Supabase: INSERT na tabela bookings
              → user_id: utilizador atual
              → property_id: propriedade selecionada
              → scheduled_date: data/hora escolhida
              → status: 'pending'
          → Sucesso → SnackBar + navegação para BookingsScreen
```

### Gerir Agendamentos

```
ProfileScreen → "Agendamentos"
  → BookingsScreen
    → Lista de agendamentos do utilizador
      → Status: pendente (amarelo), confirmado (verde), cancelado (vermelho)
      → Ações: Cancelar agendamento
```

---

## 8. Fluxo de Mensagens

```
BottomNav → "Mensagens" (tab 3)
  → MessagesScreen
    → Lista de conversas
      → Cada conversa: avatar, nome, última mensagem, timestamp
      → Badge de não lidas

PropertyDetailScreen
  → Tocar "Enviar Mensagem"
    → Mensagem pré-definida: "Olá! Vim pelo app e gostaria de mais informações sobre [propriedade]."
    → Enviar para o agente
      → MessageRepository.sendMessage(senderId, receiverId, content)
        → Supabase: INSERT na tabela messages
```

---

## 9. Fluxos Administrativos

### 9.1 Dashboard

```
ProfileScreen → "Painel Admin" (apenas para role=admin)
  → AdminDashboard
    → Métricas: total propriedades, total utilizadores, agendamentos pendentes
    → Acesso rápido para gestão
```

### 9.2 Gestão de Propriedades

```
AdminDashboard → "Propriedades"
  → AdminPropertiesScreen
    → Lista de todas as propriedades
    → Ações: Criar, Editar, Eliminar, Alternar destaque
```

### 9.3 Gestão de Utilizadores

```
AdminDashboard → "Utilizadores"
  → AdminUsersScreen
    → Lista de todos os utilizadores
    → Ações: Ver detalhe, Alterar role
```

---

## 10. Fluxo de Contacto WhatsApp

```
PropertyDetailScreen / LandDetailScreen
  → Tocar ícone WhatsApp
    → url_launcher: abre WhatsApp com:
      → Número: +244 923 456 789
      → Mensagem pré-definida: "Olá! Vim pelo app e gostaria de mais informações."
    → Se WhatsApp não instalado → erro silencioso
```

---

## Mapa de Navegação

```
SplashScreen (/)
├── LoginScreen (/login)
│   └── RegisterScreen (/register)
└── HomeScreen (/home) ←──────┐
    ├── SearchScreen (/search) │ (BottomNav tabs)
    ├── FavoritesScreen (/favorites) │
    ├── MessagesScreen (/messages) │
    └── ProfileScreen (/profile) ─┘
        ├── BookingsScreen (/bookings)
        └── AdminDashboard (/admin/dashboard)
            ├── AdminPropertiesScreen (/admin/properties)
            └── AdminUsersScreen (/admin/users)

PropertiesScreen (/properties)
└── PropertyDetailScreen (/properties/:id)

LandsScreen (/lands)
└── LandDetailScreen (/lands/:id)
```
