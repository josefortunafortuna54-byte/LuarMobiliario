import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/custom_input.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('CustomInput', () {
    testWidgets('renders label and hint', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const CustomInput(label: 'Nome', hint: 'Digite o seu nome')),
      );

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Digite o seu nome'), findsOneWidget);
    });

    testWidgets('renders prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const CustomInput(prefixIcon: Icons.person_outline)),
      );

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('does not render label when null', (tester) async {
      await tester.pumpWidget(wrapInApp(const CustomInput()));

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows errorText when provided', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const CustomInput(errorText: 'Email inválido', hint: 'Email'),
        ),
      );

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changed;

      await tester.pumpWidget(
        wrapInApp(CustomInput(onChanged: (value) => changed = value)),
      );

      await tester.enterText(find.byType(TextFormField), 'Luanda');
      expect(changed, 'Luanda');
    });

    testWidgets('toggles obscure text visibility', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const CustomInput(obscureText: true, hint: 'Password')),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      final fieldAfter = tester.widget<TextField>(find.byType(TextField));
      expect(fieldAfter.obscureText, isFalse);
    });

    testWidgets('respects readOnly flag', (tester) async {
      await tester.pumpWidget(wrapInApp(const CustomInput(readOnly: true)));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isTrue);
    });

    testWidgets('respects enabled=false as disabled', (tester) async {
      await tester.pumpWidget(wrapInApp(const CustomInput(enabled: false)));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('uses initialValue when provided without controller',
        (tester) async {
      await tester.pumpWidget(
        wrapInApp(const CustomInput(initialValue: 'Pré-preenchido')),
      );

      expect(find.text('Pré-preenchido'), findsOneWidget);
    });
  });
}