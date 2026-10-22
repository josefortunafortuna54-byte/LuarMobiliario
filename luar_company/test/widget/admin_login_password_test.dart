import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luar_company/screens/auth/admin_login_screen.dart';
import 'package:luar_company/widgets/custom_input.dart';

import '../helpers/fake_asset_bundle.dart';
import '../helpers/test_app.dart';

void main() {
  Widget buildApp() {
    return DefaultAssetBundle(
      bundle: FakeAssetBundle(),
      child: testApp(home: const AdminLoginScreen()),
    );
  }

  testWidgets('rejeita o PIN legado de 6 dígitos sem tentar autenticar', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));

    await tester.enterText(fields.first, 'admin@luarcompany.ao');
    await tester.enterText(fields.last, '123456');

    final entrar = find.text('Entrar');
    await tester.ensureVisible(entrar);
    await tester.tap(entrar);
    await tester.pump();

    expect(
      find.text('A palavra-passe deve ter pelo menos 10 caracteres'),
      findsOneWidget,
    );

    // A validação falhou antes de qualquer autenticação: não há erro de
    // credenciais no ecrã.
    expect(find.text('Email ou palavra-passe incorretos'), findsNothing);
    expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
  });

  testWidgets('o campo da palavra-passe aceita 10 ou mais caracteres', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    final passwordInput = tester.widget<CustomInput>(
      find.byType(CustomInput).last,
    );
    final validator = passwordInput.validator!;

    expect(validator('123456'), isNotNull);
    expect(validator('abc1234xyz'), isNull);
  });
}
