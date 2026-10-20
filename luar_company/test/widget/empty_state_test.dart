import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/empty_state.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders icon, title and message', (tester) async {
    await tester.pumpWidget(
      wrap(
        const EmptyState(
          icon: Icons.home_outlined,
          title: 'Sem resultados',
          message: 'Não há imóveis disponíveis.',
        ),
      ),
    );

    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.text('Sem resultados'), findsOneWidget);
    expect(find.text('Não há imóveis disponíveis.'), findsOneWidget);
  });

  testWidgets('renders without message', (tester) async {
    await tester.pumpWidget(
      wrap(
        const EmptyState(
          icon: Icons.search_off,
          title: 'Sem resultados',
        ),
      ),
    );

    expect(find.text('Sem resultados'), findsOneWidget);
    expect(find.text('Subtítulo'), findsNothing);
  });

  testWidgets('renders action button when provided', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        EmptyState(
          icon: Icons.search_off,
          title: 'Sem resultados',
          message: 'Subtítulo',
          actionLabel: 'Limpar filtros',
          onAction: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Limpar filtros'), findsOneWidget);
    await tester.tap(find.text('Limpar filtros'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('message is centered', (tester) async {
    await tester.pumpWidget(
      wrap(
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Vazio',
          message: 'Subtítulo extenso para testar alinhamento central.',
        ),
      ),
    );

    final subtitle = tester.widget<Text>(find.textContaining('Subtítulo'));
    expect(subtitle.textAlign, TextAlign.center);
  });
}
