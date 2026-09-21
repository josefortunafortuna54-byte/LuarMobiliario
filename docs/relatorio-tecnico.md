# Relatório Técnico — Luar Mobiliário

**Data:** 03/09/2026
**Âmbito:** Código-fonte em `lib/` e testes em `test/`
**Stack:** Flutter · Supabase · Provider · Firebase Messaging · Google Fonts · dotenv

---

## 1. Resumo Geral

O **Luar Mobiliário** é um aplicativo Flutter bem estruturado, com separação clara de camadas
(`core/`, `screens/`, `widgets/`, `components/`) e uma arquitetura de estado baseada em
Provider (`MultiProvider` em `main.dart`). O código segue boas convenções de estilo, possui
constantes centralizadas (`AppColors`, `AppTextStyles`, `AppConstants`), utilitários
(`formatters.dart`, `validators.dart`, `responsive.dart`) e uma suíte de testes unitários e de
widgets razoavelmente abrangente (17+ testes).

O projeto está **funcionalmente no estado "quase pronto"**: os fluxos principais
(welcome → home → listas → detalhes → favoritos → agendamentos → mensagens → perfil → admin)
estão implementados de ponta a ponta. Porém, existem **bugs reais e riscos de segurança**
que devem ser corrigidos antes de qualquer lançamento público, destacando-se:

- **Segurança:** as credenciais do Supabase (`supabaseUrl`/`anonKey`) e a API key do Firebase
  são carregadas e usadas em runtime, mas a infraestrutura de segredos não é verificável;
  o Fluxo de Admin depende **exclusivamente** de um campo `role` no modelo de utilizador,
  sem autenticação de segundo fator nem verificação de identidade robusta.
- **Bugs de lógica:** interpolação literal de string em `search_provider.dart`,
  `switch` sem `break` em três providers (filtros), e dessincronização entre a `HomeScreen`
  e os providers de dados (dois carregamentos independentes).
- **Robustez:** tratamento de erro inconsistente (algumas operações mostram `SnackBar`,
  outras são silenciosas), e defaults inseguros (`is_null: true`) nos `fromJson` dos modelos.
- **Estado real vs. documentado:** o `README.md` documenta funcionalidades que a implementação
  atual não entrega por completo (ex: filtros combinados, tratamento de erros uniforme).

---

## 2. Bugs Críticos

### 2.1 Interpolação literal de string na pesquisa (quebra a busca)
`lib/core/providers/search_provider.dart`
```dart
// A query é interpolada como literal "{provider.query}"
// em vez de usar o valor real da variável (faltou aspas / interpolação correta).
final url = '...?${'{provider.query}'}';
```
**Impacto:** a pesquisa nunca retorna resultados, pois o termo pesquisado nunca é enviado
ao backend — o parâmetro chega com o texto literal. **A avaliação da consulta falha sempre.**

### 2.2 `switch` sem `break` nos filtros (ordem dos filtros corrompe o resultado)
- `lib/core/providers/property_provider.dart` — `_applyFilters`
- `lib/core/providers/land_provider.dart` — `_applyFilters`
- `lib/core/providers/search_provider.dart` — `_applyFilters`

```dart
switch (filter) {
  case 'priceAsc': _items.sort(...);      // sem `break`
  case 'priceDesc': _items.sort(...);     // também executa o case anterior
  case 'areaAsc': ...
}
```
**Impacto:** ao avaliar um filtro, todos os `case` seguintes também correm (fall-through),
o que pode reordenar/re-filtrar a lista de forma imprevisível. Deve-se adicionar `break`
(ou converter para comparações `if/else if`).

### 2.3 Dessincronização HomeScreen vs. providers (dados a dobrar)
`lib/screens/home/home_screen.dart` e `lib/core/providers/property_provider.dart`,
`land_provider.dart`
- A `HomeScreen` chama `loadProperties()`/`loadLands()`, mas os `HomeViewModel`/providers
  também carregam dados por conta própria, causando **duas chamadas de rede** e estados
  inconsistentes (por exemplo, uma secção mostra resultados de um carregamento e outra
  de outro).

### 2.4 `fromJson` com defaults inseguros (`is_null`)
`lib/core/models/*_model.dart` (favorite, property, land, booking, message)
```dart
favorite: (json['is_favorite'] as bool?) ?? true,
```
**Impacto:** se um campo booleano vier `null` no payload, o modelo assume o valor
*verdadeiro*, invertendo o estado real (ex: um favorito que o utilizador nunca marcou
é tratado como marcado, ou uma propriedade disponible é tratada como reservada).

### 2.5 Falta de validação de data no agendamento
`lib/screens/bookings/booking_bottom_sheet.dart`
- O utilizador pode confirmar um agendamento sem data válida (datas passadas, vazias ou
  contraditórias). Não há validação de `date >= today` nem de faixa de horário.

### 2.6 `formatDate`/`formatDateTime` não tratam timestamps string
`lib/core/utils/formatters.dart`
- As funções esperam `DateTime`, mas os dados vêm do Supabase frequentemente como string
  ISO. Se chamadas com `String`, lançam erro de tipo (crash em runtime) ao deserializar
  listas de agendamentos/mensagens.

---

## 3. Funcionalidades Incompletas

1. **Filtros combinados** — A UI expõe vários filtros (preço, área, localização), mas
   `_applyFilters` não os combina corretamente (ver bug 2.2). O utilizador acredita estar
   a filtrar por mais de um critério ao mesmo tempo, mas apenas o último surte efeito.
2. **Mensagens em tempo real** — `MessageProvider.subscribeToMessages()` está implementado,
   mas a `MessagesScreen` não o utiliza; as mensagens só são sincronizadas com pull manual.
   O chat não apresenta atualizações em tempo real para o utilizador final.
3. **Tratamento de erro uniforme** — Algumas operações (login, registo, favorito) mostram
   `SnackBar`; outras (carregamento de dados, parte dos agendamentos) são silenciosas e
   deixam a UI parada com `loading=true` para sempre. Faltam estados de erro e refresh.
4. **Perfil/edição de perfil** — `edit_profile_screen` não atualiza o estado global após
   salvar em todos os fluxos (dropdowns/Provider do utilizador ficam dessincronizados).
5. **Busca com debounce** — O `SearchScreen` usa debounce, mas o provider re-executa a
   pesquisa mesmo quando a string está vazia em alguns caminhos (ver bug 2.1), o que
   pode disparar chamadas desnecessárias.

---

## 4. Problemas de Segurança

1. **Segredos em runtime** — `supabaseUrl` e `anonKey` vêm de `EnvConfig` (dotenv) e a API
   key do Firebase em `firebase_options`/`google-services`. Embora o `anonKey` seja público
   por definição do Supabase, não existe validação de que o `.env` não foi commitado nem
   rotação de chaves documentada. **Verificar que `.env` está no `.gitignore`.**
2. **Admin apenas por `role`** — `AdminDashboard` e `admin_properties` (e restantes telas
   admin) verificam apenas `user.role` no cliente. Se o SGBD não tiver Row Level Security
   (RLS) aplicado, **qualquer utilizador com `role` alterada poderia aceder às rotas admin**.
   A confiança no cliente é um anti-padrão; deve haver proteção no servidor (Supabase RLS
   + policies).
3. **Sem rate-limiting / brute-force** — Login e registo não têm proteção contra tentativas
   repetidas no cliente; fica a cargo do Supabase Auth. Recomenda-se verificar as políticas
   do Supabase.
4. **Logs/erros** — Em `core/services`, alguns `print()`/erros expõem detalhes internos
   (URLs, payloads) que devem ser removidos ou mascarados para produção.
5. **Testes sensíveis** — Os testes unitários contêm `expect` sobre strings internas
   (mensagens de erro em português), o que torna o `test` frágil a mudanças de UX, mas não
   é por si um risco de segurança; é mencionado como nota de manutenção.

---

## 5. Melhorias Priorizadas

| # | Melhoria | Prioridade | Esforço |
|---|----------|------------|---------|
| 1 | Corrigir interpolação em `search_provider.dart` (bug 2.1) | Alta | Baixo |
| 2 | Adicionar `break` aos switches de `_applyFilters` (bug 2.2) | Alta | Baixo |
| 3 | Unificar carregamento HomeScreen vs. providers (bug 2.3) | Alta | Médio |
| 4 | Endurecer `fromJson` (defaults `false`/valores seguros) (bug 2.4) | Alta | Baixo |
| 5 | Validar datas no `booking_bottom_sheet` (bug 2.5) | Média | Baixo |
| 6 | Ligar `subscribeToMessages` ao `MessagesScreen` (tempo real) | Média | Médio |
| 7 | Uniformizar tratamento de erros (estados loading/erro/empty em todas as telas) | Média | Médio |
| 8 | Implementar RLS e policies no Supabase / proteger rotas admin no servidor | **Alta** | Alto |
| 9 | Adicionar teste de widget para filtros combinados e pesquisa | Média | Médio |
| 10 | Rever `formatDate`/`formatDateTime` para aceitar strings ISO | Média | Baixo |
| 11 | Adicionar `break` e testes de unidade para `_applyFilters` | Média | Baixo |
| 12 | Mover/remover `print()` de debug antes de produção | Média | Baixo |

---

## 6. Estado Real vs. Documentado

| Documentado | Estado real |
|-------------|-------------|
| "Pesquisa completa com debounce" | Pesquisa **não funciona** (bug 2.1) — query literal nunca chega ao backend |
| "Filtros avançados combinados" | Filtros **não combinam** (bug 2.2) — fall-through do `switch` |
| "Mensagens em tempo real" | **Não implementado** na UI — `subscribeToMessages` existe mas não é usado |
| "Tratamento de erro uniforme" | **Inconsistente** — apenas parte dos fluxos mostra erro |
| "Suporte multi-dispositivo/responsive" | Implementado em `responsive.dart` e nas telas (confirma-se) |
| "Agendamentos com feedback" | Falta validação de data (bug 2.5) |

---

## Anexo — Ficheiros-Chave Citados

- `lib/core/providers/search_provider.dart` — interpolação `"{provider.query}"`
- `lib/core/providers/property_provider.dart`, `land_provider.dart` — `_applyFilters` sem `break`
- `lib/core/models/*_model.dart` — defaults `is_null: true` em `fromJson`
- `lib/screens/bookings/booking_bottom_sheet.dart` — sem validação de data
- `lib/screens/home/home_screen.dart` — dessincronização com providers
- `lib/core/services/*` — tratamento de erros e `print()` de debug
- `lib/screens/messages/messages_screen.dart` — não usa `subscribeToMessages`
- `lib/screens/admin/*` — bloqueio por `role` no cliente
- `lib/core/utils/formatters.dart`, `validators.dart`, `responsive.dart` — utilitários (OK)
