# Guia de Testes - Luar Mobiliário

## Comandos

```bash
cd luar_company

# Instalar dependências
flutter pub get

# Análise estática
flutter analyze

# Formatação
dart format .

# Testes unitários + widget
flutter test

# Testes com coverage
flutter test --coverage

# Testes de integração (dispositivo/emulador)
flutter test integration_test -d <device_id>
```

## Estrutura de Testes

```
luar_company/test/
├── helpers/          # Helpers/mocks reutilizáveis
├── unit/             # Testes unitários (providers, utils, repositories)
│   ├── providers/
│   └── utils/
├── widget/           # Testes de widget
└── widget_test.dart  # Teste base existente
```

## Cobertura Atual (Fase 1)

- `test/unit/utils/routes_test.dart` - Testes de `AppRoutes.parse()`
- `test/widget_test.dart` - Testes básicos

## Próximos Testes (Planeados)

- `test/unit/providers/auth_provider_test.dart` - AuthProvider com mocktail
- `test/widget/property_card_test.dart` - Renderização de cards
- Testes para repositórios críticos

## Boas Práticas

- Usar `mocktail` para mocks
- Evitar dependências reais (Supabase/Firebase) em unit tests
- Testar casos felizes e edge cases
- Usar `setUp`/`tearDown` para limpeza
- Nomes descritivos em PT-BR

## CI

Workflow em `.github/workflows/flutter_ci.yml` executa:
1. `flutter pub get`
2. `dart format --set-exit-if-changed`
3. `flutter analyze`
4. `flutter test`
