import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/l10n/app_localizations.dart';
import 'package:luar_company/widgets/property_card.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: child),
    );
  }

  testWidgets('PropertyCard vertical renderiza título', (tester) async {
    await tester.pumpWidget(
      wrap(
        const PropertyCard(
          imageUrl: 'https://example.com/image.jpg',
          title: 'Casa em Luanda',
          location: 'Luanda, Angola',
          price: 150000000,
          listingType: PropertyListingType.venda,
          bedrooms: 3,
          bathrooms: 2,
          area: 120,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Casa em Luanda'), findsOneWidget);
  });

  testWidgets('PropertyCard vertical renderiza', (tester) async {
    await tester.pumpWidget(
      wrap(
        const PropertyCard(
          imageUrl: 'https://example.com/image.jpg',
          title: 'Apartamento',
          location: 'Talatona',
          price: 85000000,
          listingType: PropertyListingType.venda,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PropertyCard), findsOneWidget);
  });
}
