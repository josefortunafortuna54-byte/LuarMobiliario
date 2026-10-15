import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/price_tag.dart';

import '../helpers/test_app.dart';

void main() {
  group('PriceTag', () {
    testWidgets('renders formatted price with default currency',
        (tester) async {
      await tester.pumpWidget(
        testApp(home: Scaffold(body: PriceTag(price: 1500000))),
      );

      expect(find.text('1.500.000 Kz'), findsOneWidget);
      expect(find.text('/mês'), findsNothing);
    });

    testWidgets('shows /mes suffix when isRent is true', (tester) async {
      await tester.pumpWidget(
        testApp(
          home: Scaffold(body: PriceTag(price: 250000, isRent: true)),
        ),
      );

      expect(find.text('250.000 Kz'), findsOneWidget);
      expect(find.text('/mês'), findsOneWidget);
    });

    testWidgets('hides currency when showCurrency is false', (tester) async {
      await tester.pumpWidget(
        testApp(
          home: Scaffold(body: PriceTag(price: 5000, showCurrency: false)),
        ),
      );

      expect(find.text('5.000 Kz'), findsNothing);
      expect(find.text('5.000'), findsOneWidget);
    });

    testWidgets('formats large numbers with dots', (tester) async {
      await tester.pumpWidget(
        testApp(
          home: Scaffold(body: PriceTag(price: 123456789)),
        ),
      );

      expect(find.text('123.456.789 Kz'), findsOneWidget);
    });

    testWidgets('handles zero price', (tester) async {
      await tester.pumpWidget(
        testApp(home: Scaffold(body: PriceTag(price: 0))),
      );

      expect(find.text('0 Kz'), findsOneWidget);
    });

    testWidgets('applies different fontSize per size variant', (tester) async {
      await tester.pumpWidget(
        testApp(
          home: Scaffold(body: PriceTag(price: 100, size: PriceTagSize.large)),
        ),
      );

      final text = tester.widget<Text>(find.text('100 Kz'));
      expect(text.style?.fontSize, isNotNull);
    });
  });
}