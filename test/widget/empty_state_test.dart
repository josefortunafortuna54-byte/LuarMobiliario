import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders icon, title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.home_outlined,
              title: 'Sem imóveis',
              subtitle: 'Não há imóveis disponíveis.',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.text('Sem imóveis'), findsOneWidget);
      expect(find.text('Não há imóveis disponíveis.'), findsOneWidget);
    });

    testWidgets('does not show action button when actionLabel is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.star_outline,
              title: 'Título',
              subtitle: 'Subtítulo',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('shows action button and triggers onAction when tapped',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.refresh,
              title: 'Título',
              subtitle: 'Subtítulo',
              actionLabel: 'Tentar novamente',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(button);
      expect(tapped, isTrue);
    });

    testWidgets('applies textAlign center to texts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.info_outline,
              title: 'Título',
              subtitle: 'Subtítulo extenso para testar alinhamento central.',
            ),
          ),
        ),
      );

      final subtitle = tester.widget<Text>(find.textContaining('Subtítulo'));
      expect(subtitle.textAlign, TextAlign.center);
    });
  });
}