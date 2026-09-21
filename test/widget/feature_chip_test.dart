import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/feature_chip.dart';

void main() {
  group('FeatureChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FeatureChip(label: 'Piscina'))),
      );

      expect(find.text('Piscina'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeatureChip(label: 'Garagem', icon: Icons.garage_outlined),
          ),
        ),
      );

      expect(find.byIcon(Icons.garage_outlined), findsOneWidget);
    });

    testWidgets('does not render icon when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FeatureChip(label: 'Varanda'))),
      );

      expect(find.byIcon(Icons.garage_outlined), findsNothing);
    });

    testWidgets('renders multiple chips in a row', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                FeatureChip(label: 'Piscina'),
                FeatureChip(label: 'Garagem'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Piscina'), findsOneWidget);
      expect(find.text('Garagem'), findsOneWidget);
    });
  });
}