import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/constants/app_constants.dart';
import 'package:luar_company/core/models/property_model.dart';
import 'package:luar_company/core/providers/auth_provider.dart';
import 'package:luar_company/core/providers/comparison_provider.dart';
import 'package:luar_company/core/providers/discover_provider.dart';
import 'package:luar_company/core/providers/favorite_provider.dart';
import 'package:luar_company/core/providers/playback_provider.dart';
import 'package:luar_company/core/providers/review_provider.dart';
import 'package:luar_company/core/providers/search_provider.dart';
import 'package:luar_company/core/repositories/property_repository.dart';
import 'package:luar_company/core/services/connectivity_service.dart';
import 'package:luar_company/screens/discover/discover_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

PropertyModel _property() {
  return PropertyModel(
    id: 'p1',
    title: 'Imóvel de teste',
    description: 'Descrição do imóvel para o cartão do feed.',
    type: PropertyType.house,
    transactionType: TransactionType.sale,
    price: 1000000,
    area: 100,
    bedrooms: 2,
    bathrooms: 1,
    garage: 1,
    address: 'Rua 1',
    city: 'Luanda',
    municipality: 'Belas',
    neighborhood: 'Talatona',
    latitude: -8.9,
    longitude: 13.2,
    images: const [],
    features: const [],
    agentName: 'Agente',
    agentPhone: '+244900000000',
    isFeatured: false,
    isAvailable: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

class _FakePropertyRepository extends PropertyRepository {
  @override
  Future<List<PropertyModel>> fetchProperties({
    Map<String, dynamic>? filters,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    return page == 0 ? [_property()] : const [];
  }
}

Future<void> _pumpDiscover(
  WidgetTester tester, {
  double textScale = 1.0,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    testApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<DiscoverProvider>(
            create: (_) =>
                DiscoverProvider(repository: _FakePropertyRepository()),
          ),
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
          ChangeNotifierProvider<FavoriteProvider>(
            create: (_) => FavoriteProvider(),
          ),
          ChangeNotifierProvider<ReviewProvider>(
            create: (_) => ReviewProvider(),
          ),
          ChangeNotifierProvider<PlaybackProvider>(
            create: (_) => PlaybackProvider(prefs),
          ),
          ChangeNotifierProvider<ComparisonProvider>(
            create: (_) => ComparisonProvider(),
          ),
          ChangeNotifierProvider<SearchProvider>(
            create: (_) => SearchProvider(),
          ),
          ChangeNotifierProvider<ConnectivityService>(
            create: (_) => ConnectivityService(),
          ),
        ],
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: const DiscoverScreen(),
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _showCard(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.info_outline_rounded));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  group('DiscoverScreen — cartão do imóvel', () {
    testWidgets('cartão começa escondido e o rail continua visível', (
      tester,
    ) async {
      await _pumpDiscover(tester);

      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.text('Ver imóvel'), findsNothing);
      // Rail de ações sempre visível.
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('botão ℹ mostra o cartão e ⌄ volta a escondê-lo', (
      tester,
    ) async {
      await _pumpDiscover(tester);

      await _showCard(tester);
      expect(find.text('Ver imóvel'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Ver imóvel'), findsNothing);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final scale in const [1.0, 1.5, 2.0, 2.5]) {
      testWidgets('texto "Ver imóvel" nunca é cortado (escala $scale)', (
        tester,
      ) async {
        await _pumpDiscover(tester, textScale: scale);
        await _showCard(tester);

        final button = find.widgetWithText(ElevatedButton, 'Ver imóvel');
        final label = find.text('Ver imóvel');
        expect(button, findsOneWidget);

        // O cartão limita a escala de fonte a 1.4.
        final effectiveScale = scale.clamp(1.0, 1.4);
        // buttonLarge: fontSize 16 com height 1.2 por linha.
        final minLineHeight = 16 * 1.2 * effectiveScale;

        final labelSize = tester.getSize(label);
        final buttonSize = tester.getSize(button);

        expect(tester.takeException(), isNull, reason: 'sem overflow');
        expect(
          labelSize.height,
          greaterThanOrEqualTo(minLineHeight - 0.75),
          reason: 'rótulo "Ver imóvel" cortado verticalmente',
        );
        expect(buttonSize.height, greaterThanOrEqualTo(46));
        expect(
          buttonSize.height,
          greaterThanOrEqualTo(labelSize.height + 24 - 0.5),
          reason: 'rótulo não cabe dentro do botão com o padding vertical',
        );
      });
    }
  });
}
