import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:luar_company/main.dart' as app;
import 'package:luar_company/core/utils/routes.dart';
import 'package:luar_company/screens/splash/splash_screen.dart';
import 'package:luar_company/screens/welcome/welcome_screen.dart';

/// Testes de integração (T-036).
///
/// Executar num dispositivo/emulador:
///   flutter test integration_test -d {device}
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('A app arranca e mostra o ecrã de arranque', (tester) async {
    app.main();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Sem sessão, o splash navega para o ecrã de boas-vindas',
      (tester) async {
    app.main();
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    // SplashScreen aguarda ~2s antes de navegar (sem rede nesta fase).
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('onGenerateRoute resolve a rota de splash', (tester) async {
    final route = onGenerateRoute(const RouteSettings(name: AppRoutes.splash));
    expect(route, isNotNull);
    expect(route.settings.name, AppRoutes.splash);
  });
}