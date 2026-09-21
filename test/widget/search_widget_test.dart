import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/search_widget.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('SearchWidget', () {
    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const SearchWidget(hintText: 'Pesquisar imóveis...')),
      );

      expect(find.text('Pesquisar imóveis...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('calls onChanged when typing', (tester) async {
      String? value;

      await tester.pumpWidget(
        wrapInApp(SearchWidget(onChanged: (v) => value = v)),
      );

      await tester.enterText(find.byType(TextField), 'Luanda');
      expect(value, 'Luanda');
    });

    testWidgets('calls onSearch when submitted', (tester) async {
      String? submitted;

      await tester.pumpWidget(
        wrapInApp(SearchWidget(onSearch: (v) => submitted = v)),
      );

      await tester.enterText(find.byType(TextField), 'Viana');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(submitted, 'Viana');
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      await tester.pumpWidget(
        wrapInApp(SearchWidget(onSearch: (v) {})),
      );

      expect(find.byIcon(Icons.close_rounded), findsNothing);

      await tester.enterText(find.byType(TextField), 'texto');
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('clear button clears text and calls onSearch with empty',
        (tester) async {
      String? submitted;

      await tester.pumpWidget(
        wrapInApp(SearchWidget(onSearch: (v) => submitted = v)),
      );

      await tester.enterText(find.byType(TextField), 'texto');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(submitted, '');
      expect(find.text('texto'), findsNothing);
    });

    testWidgets('shows filter (tune) button when onFilterTap is provided',
        (tester) async {
      var filterTapped = false;

      await tester.pumpWidget(
        wrapInApp(
          SearchWidget(onFilterTap: () => filterTapped = true),
        ),
      );

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.tune_rounded));
      expect(filterTapped, isTrue);
    });

    testWidgets('does not show filter button when onFilterTap is null',
        (tester) async {
      await tester.pumpWidget(wrapInApp(const SearchWidget()));

      expect(find.byIcon(Icons.tune_rounded), findsNothing);
    });

    testWidgets('respects external controller', (tester) async {
      final controller = TextEditingController(text: 'Kilamba');

      await tester.pumpWidget(
        wrapInApp(SearchWidget(controller: controller)),
      );

      expect(find.text('Kilamba'), findsOneWidget);

      controller.dispose();
    });
  });
}