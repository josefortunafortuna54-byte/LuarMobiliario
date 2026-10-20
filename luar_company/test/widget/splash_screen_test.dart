import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luar_company/core/utils/routes.dart';
import 'package:luar_company/l10n/app_localizations.dart';
import 'package:luar_company/screens/splash/splash_screen.dart';
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
        initialRoute: AppRoutes.splash,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }

  testWidgets('mostra logo com anel, nome e barra de carregamento', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(PremiumSplashBackground), findsOneWidget);
    expect(find.byType(GoldShimmerRing), findsOneWidget);
    expect(find.text('Luar Mobiliario'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Consome o timer de navegação de 2s para não ficar pendente no fim.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 450));
  });

  testWidgets('navega para as boas-vindas após o tempo de arranque', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SplashScreen), findsOneWidget);

    // O fundo e o anel têm animações infinitas: usar pumps explícitos
    // (pumpAndSettle nunca terminaria).
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });
}
