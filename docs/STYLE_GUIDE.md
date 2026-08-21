# Guia de Estilo de Código

Convenções e padrões de código para o projeto Luar Company Imobiliária.

---

## Dart / Flutter

Siga as convenções oficiais do [Dart Style Guide](https://dart.dev/effective-dart/style).

### Formatação

```bash
# Formatar todo o projeto
dart format .

# Verificar sem alterar
dart format --output=none --set-exit-if-changed .

# Analisar
flutter analyze
```

---

## Nomenclatura de Ficheiros

| Tipo | Padrão | Exemplo |
|---|---|---|
| Screens | `lib/screens/{modulo}/{nome}_screen.dart` | `home_screen.dart` |
| Widgets | `lib/widgets/{nome}_widget.dart` | `property_card.dart` |
| Components | `lib/components/{nome}.dart` | `bottom_nav.dart` |
| Providers | `lib/core/providers/{nome}_provider.dart` | `auth_provider.dart` |
| Repositories | `lib/core/repositories/{nome}_repository.dart` | `property_repository.dart` |
| Models | `lib/core/models/{nome}_model.dart` | `user_model.dart` |
| Services | `lib/core/services/{nome}_service.dart` | `auth_service.dart` |
| Constants | `lib/core/constants/app_{nome}.dart` | `app_colors.dart` |
| Utils | `lib/core/utils/{nome}.dart` | `routes.dart` |
| Config | `lib/core/config/{nome}.dart` | `env_config.dart` |

**Formato:** `snake_case.dart`

---

## Nomenclatura de Classes

| Tipo | Padrão | Exemplo |
|---|---|---|
| Classes | `PascalCase` | `PropertyModel`, `AuthProvider` |
| Classes abstratas | `PascalCase` | `AppColors`, `AppConstants` |
| Mixins | `PascalCase` com `Mixin` sufixo | `ValidMixin` |
| Enums | `PascalCase` | `UserRole`, `TransactionType` |
| Enums values | `camelCase` | `UserRole.client`, `UserRole.agent` |

---

## Nomenclatura de Variáveis e Funções

| Tipo | Padrão | Exemplo |
|---|---|---|
| Variáveis | `camelCase` | `propertyName`, `isLoading` |
| Funções | `camelCase` | `loadProperties()`, `signIn()` |
| Constantes de classe | `camelCase` | `AppConstants.appName` |
| Parâmetros nomeados | `camelCase` | `{String? type}` |
| Flags booleanas | prefixo `is`/`has` | `isAvailable`, `hasError` |

---

## Organização de Imports

Agrupar imports por ordem, separados por linhas em branco:

```dart
// 1. Dart/Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 2. Pacotes de terceiros
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// 3. Ficheiros do projeto (relativos)
import '../core/constants/app_colors.dart';
import '../core/providers/auth_provider.dart';
import '../models/property_model.dart';
```

### Regras

- Usar imports relativos para ficheiros dentro do projeto
- Não usar `dart:` imports quando `package:` está disponível
- Agrupar imports do mesmo módulo
- Ordenar alfabeticamente dentro de cada grupo

---

## Padrões de Widget

### Estrutura de um Screen

```dart
class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  // Estado local

  @override
  void initState() {
    super.initState();
    // Inicialização
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Título')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Lógica de construção do corpo
    return const SizedBox.shrink();
  }
}
```

### Estrutura de um Widget Reutilizável

```dart
class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ...
      ),
    );
  }
}
```

### Regras

- Usar `StatefulWidget` apenas quando necessário (estado mutável)
- Usar `const` sempre que o widget for imutável
- Extrair widgets construídos em métodos privados (`_buildHeader()`, `_buildBody()`)
- Não aninhar mais de 3 widgets construídos inline
- Preferir `Column`/`Row` + `Expanded` sobre `Stack` quando possível

---

## Padrões de Provider

### Estrutura de um Provider

```dart
class PropertyProvider extends ChangeNotifier {
  // Estado privado
  List<PropertyModel> _properties = [];
  bool _isLoading = false;
  String? _error;

  // Getters públicos
  List<PropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Métodos públicos
  Future<void> loadProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _properties = await _repository.getProperties();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### Regras

- Cada Provider encapsula um domínio
- Estado sempre privado (`_variavel`)
- Expor apenas getters leituras
- Chamar `notifyListeners()` após cada mudança de estado
- Usar `try/catch` em todas as operações assíncronas
- Gerir estados `isLoading` e `error` em todas as operações
- Registar providers no `MultiProvider` em `main.dart`

### Uso na UI

```dart
// Ler estado (rebuild quando muda)
context.watch<PropertyProvider>().properties

// Ler uma vez (sem rebuild)
context.read<PropertyProvider>().loadProperties()
```

---

## Padrões de Repository

```dart
class PropertyRepository {
  final _client = SupabaseService.client;
  static const _table = 'properties';

  Future<List<PropertyModel>> getProperties({
    String? type,
    String? city,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from(_table).select().eq('is_available', true);

      if (type != null) query = query.eq('type', type);
      if (city != null) query = query.eq('city', city);

      final response = await query
          .order('created_at', ascending: false)
          .range(offset ?? 0, (offset ?? 0) + (limit ?? 20) - 1);

      return (response as List)
          .map((json) => PropertyModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
```

### Regras

- Cada repositório encapsula uma tabela
- Usar `_client` privado via `SupabaseService.client`
- Usar `_table` constante para nome da tabela
- Sempre retornar `List<T>` ou `T` em vez de `dynamic`
- Tratar erros com `try/catch`, retornar lista vazia ou null
- Usar filtros condicionais (encadear queries)

---

## Padrões de Model

```dart
class PropertyModel {
  final String id;
  final String title;
  final double price;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.price,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
    };
  }

  PropertyModel copyWith({
    String? id,
    String? title,
    double? price,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
    );
  }
}
```

### Regras

- Todos os campos devem ser `final`
- Usar construtor `const` quando possível
- Implementar `fromJson()`, `toJson()`, `copyWith()`
- Usar `as num` para campos numéricos que podem vir como int ou double
- Não usar `dynamic` nos campos do modelo

---

## Comentários

### Quando Comentar

- Funções públicas: documentar com `///`
- Lógica complexa: explicar o "porquê", não o "o quê"
- TODOs: usar `// TODO: descrição`
- Evitar comentários óbvios

### Formato

```dart
/// Carrega a lista de propriedades com os filtros especificados.
///
/// [type] Filtra por tipo de propriedade.
/// [city] Filtra por cidade.
/// Retorna uma lista de [PropertyModel].
Future<List<PropertyModel>> getProperties({
  String? type,
  String? city,
}) async {
  // ...
}
```

### Regras

- Usar `///` para documentação de API
- Usar `//` para comentários inline
- Não documentar código óbvio (`// incrementa i`)
- Manter comentários atualizados
- Remover código comentado (usar git para histórico)

---

## Boas Práticas

### Geral

- Usar `const` sempre que possível
- Preferir `final` sobre `var`
- Não usar `print()` em produção (usar logging apropriado)
- Nunca fazer commit de chaves ou segredos
- Manter ficheiros com < 300 linhas (extrair widgets)

### Flutter

- Usar `key` em todos os widgets construídos
- Preferir `ListView.builder` sobre `ListView` com children
- Usar `RepaintBoundary` em listas grandes
- Evitar `setState` desnecessário — preferir Provider
- Usar `PreferredSize` para AppBar customizado

### Segurança

- Nunca logar dados sensíveis
- Validar todos os inputs do utilizador
- Usar `EnvConfig` para variáveis de ambiente
- Não expor `service_role` key no cliente
