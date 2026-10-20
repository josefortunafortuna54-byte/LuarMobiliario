import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luar_company/core/utils/routes.dart' as routes;
import 'package:luar_company/l10n/app_localizations.dart';
import 'package:luar_company/screens/welcome/welcome_screen.dart';
import 'package:luar_company/widgets/gold_shimmer_ring.dart';
import 'package:luar_company/widgets/premium_splash_background.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  Widget buildApp() {
    return DefaultAssetBundle(
      bundle: FakeAssetBundle(),
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // `home` em vez de `initialRoute` para não montar também o splash
        // (o Navigator empilha "/" sob "/welcome").
        home: const WelcomeScreen(),
        onGenerateRoute: (settings) {
          // Substitui o MainShell real (precisa de providers) por um fake.
          if (settings.name == routes.AppRoutes.home) {
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('home-fake')),
            );
          }
          return routes.onGenerateRoute(settings);
        },
      ),
    );
  }

  testWidgets('mostra marca, headline, features e CTA', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(PremiumSplashBackground), findsOneWidget);
    expect(find.byType(GoldShimmerRing), findsOneWidget);
    expect(find.text('Luar Mobiliario'), findsOneWidget);
    expect(
      find.text('Mais que imóveis. É o seu próximo capítulo.'),
      findsOneWidget,
    );
    expect(find.text('Por que escolher o Luar Mobiliário?'), findsOneWidget);
    expect(find.text('Explorar Imóveis'), findsOneWidget);
    // 7 features em cartões glass.
    expect(find.text('Vídeos em alta definição'), findsOneWidget);
    expect(find.text('Mapa interativo'), findsOneWidget);
    expect(find.text('Notificações em tempo real'), findsOneWidget);
  });

  testWidgets('o CTA "Explorar Imóveis" navega para o Home', (tester) async {
    // Viewport alta para o ecrã de boas-vindas caber todo (sem scroll).
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Explorar Imóveis'));
    // Um pump sem duração para instalar a nova rota e outro para a transição.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('home-fake'), findsOneWidget);

    // A rota anterior é removida quando a transição termina.
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(WelcomeScreen), findsNothing);
  });
}
