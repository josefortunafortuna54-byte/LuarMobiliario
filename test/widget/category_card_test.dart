import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/category_card.dart';

void main() {
  group('CategoryCard', () {
    testWidgets('renders title, icon and count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CategoryCard(icon: Icons.home, title: 'Casas', count: 5)),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.text('Casas'), findsOneWidget);
      expect(find.text('5 imóveis'), findsOneWidget);
    });

    testWidgets('uses singular for count of 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CategoryCard(icon: Icons.home, title: 'Casas', count: 1)),
        ),
      );

      expect(find.text('1 imóvel'), findsOneWidget);
    });

    testWidgets('triggers onTap when card is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              icon: Icons.landscape,
              title: 'Terrenos',
              count: 3,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Terrenos'));
      expect(tapped, isTrue);
    });

    testWidgets('does not throw when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CategoryCard(icon: Icons.grid_view, title: 'Todas', count: 0)),
        ),
      );

      expect(find.text('0 imóveis'), findsOneWidget);
    });
  });
}