# Design System

Guia de design system da plataforma Luar Company Imobiliária — identidade visual, componentes e padrões de UI.

---

## Identidade Visual

A identidade visual da Luar Company transmite **luxo, confiança e sofisticação**. A combinação navy + gold cria uma atmosfera premium que diferencia a marca no mercado imobiliário angolano.

---

## Cores

### Primárias

| Cor | Nome | Hex | Uso |
|---|---|---|---|
| 🟦 | Navy | `#0F1B2D` | Cor principal, AppBar, fundo do BottomNav |
| 🟦 | Navy Light | `#1A2D47` | Variação mais clara do navy |
| 🟦 | Navy Dark | `#091220` | Variação mais escura do navy |
| 🟨 | Gold | `#C9A84C` | Cor de destaque, botões, preços |
| 🟨 | Gold Light | `#D4BA6A` | Variação mais clara do gold |
| 🟨 | Gold Dark | `#B08F35` | Variação mais escura do gold |

### Neutros

| Cor | Hex | Uso |
|---|---|---|
| White | `#FFFFFF` | Fundo de cards, superfícies |
| Off White | `#F8F8F8` | Scaffold background |
| Gray 50 | `#F9FAFB` | Fundo suave |
| Gray 100 | `#F3F4F6` | Bordas leves, divisões |
| Gray 200 | `#E5E7EB` | Bordas de inputs, dividers |
| Gray 300 | `#D1D5DB` | Bordas secundárias |
| Gray 400 | `#9CA3AF` | Texto placeholder, ícones inativos |
| Gray 500 | `#6B7280` | Texto secundário, captions |
| Gray 600 | `#4B5563` | Texto corpo alternativo |
| Gray 700 | `#374151` | Texto escuro |
| Gray 800 | `#1F2937` | Texto principal (corpo) |
| Gray 900 | `#111827` | Texto mais escuro |

### Semânticas

| Cor | Hex | Uso |
|---|---|---|
| Success | `#22C55E` | Operações bem-sucedidas |
| Error | `#EF4444` | Erros, validação |
| Warning | `#F59E0B` | Alertas |
| Info | `#3B82F6` | Informações |
| WhatsApp | `#25D366` | Ícone e botão WhatsApp |

### Gradientes

| Gradiente | Cores | Uso |
|---|---|---|
| Gold Gradient | Gold Light → Gold → Gold Dark | Botões de destaque, badges |
| Navy Gradient | Navy Light → Navy | Fundos de ecrã, headers |
| Hero Gradient | Navy → Navy Light → #1E3A5F | Ecrãs principais, hero sections |
| Gold Shimmer | Gold Dark → Gold Light → Gold Dark | Animações de loading |

---

## Tipografia

### Fontes

| Fonte | Uso | Estilo |
|---|---|---|
| **Playfair Display** | Títulos e headings | Serif, premium |
| **DM Sans** | Corpo, labels, botões | Sans-serif, limpa |

### Hierarquia Tipográfica

| Estilo | Fonte | Tamanho | Peso | Altura de Linha | Uso |
|---|---|---|---|---|---|
| h1 | Playfair Display | 48px | Bold (700) | 1.1 | Títulos de ecrã |
| h2 | Playfair Display | 40px | Bold (700) | 1.15 | Subtítulos grandes |
| h3 | Playfair Display | 32px | SemiBold (600) | 1.2 | Títulos de secção |
| h4 | Playfair Display | 28px | SemiBold (600) | 1.25 | Títulos médios |
| h5 | Playfair Display | 24px | SemiBold (600) | 1.3 | Títulos pequenos |
| h6 | Playfair Display | 20px | SemiBold (600) | 1.3 | Títulos menores |
| Body Large | DM Sans | 18px | Regular (400) | 1.6 | Texto corpo grande |
| Body Medium | DM Sans | 16px | Regular (400) | 1.5 | Texto corpo padrão |
| Body Small | DM Sans | 14px | Regular (400) | 1.5 | Texto corpo pequeno |
| Body Tiny | DM Sans | 12px | Regular (400) | 1.4 | Texto mínimo |
| Label Large | DM Sans | 14px | SemiBold (600) | 1.4 | Labels de formulário |
| Label Medium | DM Sans | 12px | SemiBold (600) | 1.4 | Labels médios |
| Label Small | DM Sans | 10px | SemiBold (600) | 1.4 | Labels pequenos |
| Overline | DM Sans | 10px | SemiBold (600) | 1.4 | Tags, categorias (cor gold) |
| Button Large | DM Sans | 16px | Bold (700) | 1.2 | Botões grandes |
| Button Medium | DM Sans | 14px | Bold (700) | 1.2 | Botões médios |
| Button Small | DM Sans | 12px | Bold (700) | 1.2 | Botões pequenos |
| Caption | DM Sans | 12px | Regular (400) | 1.4 | Texto auxiliar (gray500) |
| Helper | DM Sans | 12px | Medium (500) | 1.4 | Texto de ajuda (gray600) |
| Price Large | Playfair Display | 32px | Bold (700) | — | Preço em destaque |
| Price Medium | Playfair Display | 24px | Bold (700) | — | Preço médio |
| Price Small | DM Sans | 16px | Bold (700) | — | Preço em card |

### Variantes de Cor dos Títulos

Todos os headings estão disponíveis em três variantes de cor:
- **Padrão**: Navy (`#0F1B2D`)
- **Gold**: Gold (`#C9A84C`) — para destaques
- **White**: Branco (`#FFFFFF`) — para fundos escuros

---

## Espaçamento

Sistema de espaçamento baseado em escala de 4px.

| Token | Valor | Uso |
|---|---|---|
| `spacingXxs` | 2px | Micro-espaçamento |
| `spacingXs` | 4px | Espaçamento entre ícones e texto |
| `spacingSm` | 8px | Espaçamento entre elementos próximos |
| `spacingMd` | 16px | Espaçamento padrão entre secções |
| `spacingLg` | 24px | Espaçamento entre secções |
| `spacingXl` | 32px | Espaçamento generoso |
| `spacingXxl` | 48px | Espaçamento de destaque |
| `spacingXxxl` | 64px | Espaçamento máximo |

---

## Border Radius

| Token | Valor | Uso |
|---|---|---|
| `radiusSm` | 8px | Cards pequenos, badges |
| `radiusMd` | 12px | Botões, inputs, BottomNav items |
| `radiusLg` | 16px | Cards grandes, modais |
| `radiusXl` | 24px | Cards de detalhe, bottom sheets |
| `radiusFull` | 999px | Avatares, pills, botões circulares |

---

## Sombras

| Token | Blur | Uso |
|---|---|---|
| `shadowSm` | 2px | Elevação sutil |
| `shadowMd` | 4px | Cards em repouso |
| `shadowLg` | 8px | Cards com elevação |
| `shadowXl` | 16px | Elementos flutuantes (BottomNav) |

### Padrão de Sombra

```dart
BoxShadow(
  color: AppColors.black.withValues(alpha: 0.08),
  blurRadius: AppConstants.shadowMd,
  offset: const Offset(0, 2),
)
```

---

## Animações

| Token | Duração | Uso |
|---|---|---|
| `animationFast` | 200ms | Micro-interações (hover, tap) |
| `animationNormal` | 350ms | Transições de estado |
| `animationSlow` | 500ms | Transições de ecrã |

### Transições de Navegação

- **Duração de entrada**: 300ms
- **Duração de saída**: 250ms
- **Curva**: `Curves.easeInOut`
- **Tipo**: Slide horizontal + Fade

---

## Componentes

### Botões

#### Elevated Button (Primário)
- Fundo: Gold
- Texto: Branco, DM Sans Bold 16px
- Padding: 32px horizontal, 16px vertical
- Border radius: 12px
- Sem elevação (elevation: 0)
- Uso: Ações principais (Pesquisar, Agendar, Enviar)

#### Outlined Button (Secundário)
- Fundo: Transparente
- Borda: Navy 1.5px
- Texto: Navy, DM Sans Bold 16px
- Padding: 32px horizontal, 16px vertical
- Border radius: 12px
- Uso: Ações secundárias (Cancelar, Voltar)

#### Floating Action Button
- Fundo: Gold
- Texto/Ícone: Branco
- Elevação: 6
- Border radius: 16px
- Uso: Ação principal contextual

### Cards

#### PropertyCard / LandCard
- Fundo: Branco
- Borda: 1px Gray 100
- Border radius: 16px
- Sem elevação (elevation: 0)
- Conteúdo: Imagem, título, preço (gold), localização, badges

#### CategoryCard
- Fundo: Branco
- Borda: 1px Gray 100
- Border radius: 12px
- Ícone + label

### Inputs (InputDecorationTheme)
- Fundo: Branco (filled)
- Padding: 16px horizontal, 16px vertical
- Borda: Gray 200, 1px, border radius 12px
- Foco: Gold, 2px
- Erro: Error, 1px
- Placeholder: DM Sans 14px, Gray 400

### AppBar
- Fundo: Navy
- Texto: Branco, DM Sans Bold 18px
- Sem elevação
- Center title: true

### Bottom Navigation Bar
- Fundo: Navy
- 5 itens: Início, Pesquisar, Favoritos, Mensagens, Perfil
- Item ativo: Gold (ícone + label)
- Item inativo: Gray 400
- Indicador ativo: Fundo gold com 12% opacidade, border radius 12px
- Sombra: 16px blur, 15% opacidade

### SnackBar
- Fundo: Navy
- Texto: Branco, DM Sans 14px
- Comportamento: Floating
- Border radius: 12px

### PriceTag
- Fonte: Playfair Display Bold
- Cor: Gold
- Tamanhos: Large (32px), Medium (24px), Small (16px)

### Badges / Chips
- Background: Gold 12% opacidade
- Texto: Gold, DM Sans SemiBold
- Border radius: 8px
- Uso: Tipo de propriedade, transação

---

## Tema Material 3

### ColorScheme

```dart
ColorScheme.light(
  primary: AppColors.navy,        // Cor principal
  onPrimary: AppColors.white,     // Texto sobre primária
  secondary: AppColors.gold,      // Cor secundária
  onSecondary: AppColors.white,   // Texto sobre secundária
  surface: AppColors.white,       // Superfícies
  onSurface: AppColors.gray800,   // Texto sobre superfícies
  error: AppColors.error,         // Erros
  onError: AppColors.white,       // Texto sobre erro
)
```

### Scaffold Background

```dart
scaffoldBackgroundColor: AppColors.offWhite  // #F8F8F8
```

### Tema Claro / Escuro / Sistema

A aplicação suporta **tema claro, escuro e do sistema**, gerido pelo `ThemeProvider`
(`lib/core/providers/theme_provider.dart`) e pela paleta dinâmica `AppPalette`
(`lib/core/theme/app_palette.dart`). Os componentes leem as cores via `context.palette`,
pelo que os tokens navy/gold são adaptados automaticamente ao modo escuro.

### Uso de Constantes

Todas as constantes visuais estão centralizadas em:
- `lib/core/constants/app_colors.dart` — Cores e gradiente
- `lib/core/constants/app_constants.dart` — Espaçamentos, border radius, sombras, durações
- `lib/core/constants/app_text_styles.dart` — Estilos de texto
