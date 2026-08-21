# Diretrizes UI/UX

Guia de interface do utilizador e experiência do utilizador para a plataforma Luar Company Imobiliária.

---

## Filosofia de Design

A Luar Company Imobiliária adota uma filosofia de design **premium e sofisticada**, inspirada em marcas de luxo do sector imobiliário. A experiência deve transmitir:

- **Confiança**: Visual limpo, organizado e profissional
- **Luxo**: Paleta navy + gold, tipografia serif nos títulos
- **Simplicidade**: Navegação intuitiva, poucos passos para ações principais
- **Acessibilidade**: Contraste adequado, alvos de toque generosos

---

## Navegação

### Bottom Navigation Bar (5 tabs)

A navegação principal é feita via barra de navegação inferior fixa:

| Tab | Ícone (inativo) | Ícone (ativo) | Label | Ecrã |
|---|---|---|---|---|
| 1 | home_outlined | home_rounded | Início | HomeScreen |
| 2 | search_outlined | search_rounded | Pesquisar | SearchScreen |
| 3 | favorite_outline | favorite_rounded | Favoritos | FavoritesScreen |
| 4 | chat_bubble_outline_rounded | chat_bubble_rounded | Mensagens | MessagesScreen |
| 5 | person_outline | person_rounded | Perfil | ProfileScreen |

**Comportamento:**
- Fundo navy com sombra suave
- Item ativo: ícone e label em gold, fundo com 12% opacidade gold
- Item inativo: ícone e label em gray400
- Indicador ativo: background gold 12%, border radius 12px
- Animação de transição: 200ms

### Navegação por Rotas

- Rotas nomeadas definidas em `lib/core/utils/routes.dart`
- Transições: slide horizontal + fade (300ms entrada, 250ms saída)
- Detalhes de propriedades/terrenos: navegação via argumentos (ID)

---

## Layout dos Ecrãs

### Estrutura Padrão

```
┌─────────────────────────────┐
│          AppBar (Navy)       │  ← Título centrado, branco
├─────────────────────────────┤
│                             │
│       Conteúdo Principal    │  ← ScrollView / ListView
│                             │
├─────────────────────────────┤
│     Bottom Nav Bar (Navy)   │  ← 5 tabs fixas
└─────────────────────────────┘
```

### Ecrã de Splash
- Fundo: Gradiente navy
- Logo centrado
- Nome da empresa em Playfair Display
- Slogan: "Seu novo lar começa aqui"
- Loader animado (gold shimmer)

### Ecrã de Login/Registo
- Fundo: Gradiente navy
- Card centralizado (branco, border radius 24px)
- Campos de input: email, senha, nome (registo)
- Botão primário gold
- Link para trocar entre login/registo
- Logo no topo

### Ecrã Principal (Home)
- Header com saudação e avatar
- Barra de pesquisa
- Secção "Destaques" — carrossel horizontal
- Secção "Categorias" — grid de CategoryCards
- Secção "Recentes" — lista vertical de PropertyCards
- Secção "Terrenos" — lista vertical de LandCards

### Ecrã de Pesquisa
- Barra de pesquisa no topo
- Filtros ativos (chips removíveis)
- Filtros avançados (bottom sheet):
  - Tipo de propriedade
  - Tipo de transação (Venda/Arrendamento)
  - Faixa de preço
  - Área mínima/máxima
  - Número de quartos
  - Cidade
- Resultados: lista de PropertyCards
- Estado vazio quando sem resultados

### Ecrã de Detalhe (Propriedade/Terreno)
- Galeria de imagens (photo_view para zoom)
- Título e preço (gold, Playfair Display)
- Localização com ícone de mapa
- Características (chips)
- Descrição completa
- Informações do agente (avatar, nome, telefone)
- Botões: WhatsApp, Ligar, Mensagem, Agendar Visita
- Mapa de localização (Google Maps)

### Ecrã de Favoritos
- Lista de propriedades/terrenos favoritos
- Tabs: Propriedades | Terrenos
- Card com ícone de favorito preenchido
- Estado vazio quando sem favoritos

### Ecrã de Mensagens
- Lista de conversas
- Cada conversa: avatar, nome, última mensagem, timestamp
- Indicador de não lida (badge gold)
- Estado vazio quando sem mensagens

### Ecrã de Perfil
- Avatar (circular, border radius 999px)
- Nome e email
- Opções: Editar Perfil, Agendamentos, Admin (se admin), Sair
- Divisores entre secções

### Ecrã Administrativo
- Dashboard com métricas
- Gestão de propriedades (CRUD)
- Gestão de utilizadores

---

## Estados de UI

### Estado de Carregamento
- **Skeleton loading**: Shimmer animation com gray50 → gray100
- **Spinner**: CircularProgressIndicator com cor gold
- **Props**: Sempre exibir durante operações de rede

### Estado Vazio
- Ícone ilustrativo grande
- Título descritivo (ex: "Nenhuma propriedade encontrada")
- Subtítulo com instrução (ex: "Tente ajustar os filtros")
- Botão de ação (quando aplicável)
- Componente: `EmptyState`

### Estado de Erro
- Ícone de erro (vermelho)
- Mensagem descritiva do erro
- Botão "Tentar novamente"
- SnackBar com mensagem de erro (navy, flutuante)

### Estado de Sucesso
- SnackBar de confirmação (navy)
- Navegação automática (quando aplicável)

---

## Touch Targets

- **Mínimo**: 48x48dp (recomendação Material Design)
- **Bottom Nav items**: padding horizontal 14px, vertical 8px
- **Botões**: padding 32px horizontal, 16px vertical
- **Cards**: padding 16px
- **Ícones de ação**: mínimo 44x44dp

---

## Acessibilidade

### Contraste

| Combinação | Razão | WCAG |
|---|---|---|
| Navy sobre Branco | 12.63:1 | AAA ✅ |
| Gold sobre Navy | 5.74:1 | AA ✅ |
| Gray 800 sobre Branco | 10.92:1 | AAA ✅ |
| Gray 400 sobre Branco | 3.95:1 | AA (grande texto) ✅ |

### Recomendações

- Todos os textos devem ter contraste mínimo de 4.5:1 (AA)
- Textos grandes (>= 18px bold ou >= 24px) devem ter 3:1
- Ícones interativos devem ter contraste de 3:1 contra o fundo
- Imagens informativas devem ter texto alternativo
- Campos de formulário devem ter labels associados

---

## Imagens e Media

### Galeria de Imagens
- Utiliza `cached_network_image` para cache
- `photo_view` para zoom em ecrã de detalhe
- Indicador de posição (dots) no carrossel
- Placeholder com shimmer durante carregamento

### Avatares
- Formato circular (border radius 999px)
- Tamanho padrão: 48x48dp
- Tamanho grande: 96x96dp
- Fallback: ícone de pessoa

### Ícones
- Material Icons (rounded variant para itens ativos)
- Material Icons outlined para itens inativos
- Tamanho padrão: 24px

---

## Formatação de Dados

### Preços
- Formato: `1.500.000 Kz` (mill separators, sufixo Kz)
- Cor: Gold (AppColors.gold)
- Fonte: Playfair Display Bold

### Datas
- Formato: `19 Jul 2026` (dd MMM yyyy)
- Via pacote `intl`

### Números de Telefone
- Formato: `+244 923 456 789`
- Regex: `^(\+244\s?)?9[1-9]\d{7}$`

---

## Responsive Design

- **Mobile**: Layout padrão (portrait)
- **Tablet**: Layout expandido com grid de 2 colunas para cards
- **Web**: Layout desktop com sidebar e grid de 3+ colunas
- Orientação: portrait only (configurado via `SystemChrome`)
