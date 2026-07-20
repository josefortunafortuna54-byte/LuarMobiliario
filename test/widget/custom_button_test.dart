import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/custom_button.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('CustomButton', () {
    group('renders', () {
      testWidgets('displays text', (tester) async {
        await tester.pumpWidget(wrapInApp(const CustomButton(text: 'Salvar')));
        await tester.pumpAndSettle();

        expect(find.text('Salvar'), findsOneWidget);
      });

      testWidgets('renders ElevatedButton for primary variant', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const CustomButton(
              text: 'Primary',
              variant: CustomButtonVariant.primary,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders ElevatedButton for secondary variant', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapInApp(
            const CustomButton(
              text: 'Secondary',
              variant: CustomButtonVariant.secondary,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders OutlinedButton for outline variant', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const CustomButton(
              text: 'Outline',
              variant: CustomButtonVariant.outline,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('renders TextButton for text variant', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const CustomButton(text: 'Text', variant: CustomButtonVariant.text),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TextButton), findsOneWidget);
      });
    });

    group('onPressed', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          wrapInApp(
            CustomButton(text: 'Tap me', onPressed: () => tapped = true),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tap me'));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('does not call onPressed when disabled', (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          wrapInApp(
            CustomButton(
              text: 'Disabled',
              enabled: false,
              onPressed: () => tapped = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Disabled'));
        await tester.pumpAndSettle();

        expect(tapped, isFalse);
      });

      testWidgets('does not call onPressed when loading', (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          wrapInApp(
            CustomButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        );
        await tester.pump();

        // When loading, text is replaced by CircularProgressIndicator.
        // Tap the spinner area — onPressed should be null.
        await tester.tap(
          find.byType(CircularProgressIndicator),
          warnIfMissed: false,
        );
        await tester.pump();

        expect(tapped, isFalse);
      });
    });

    group('loading state', () {
      testWidgets('shows CircularProgressIndicator when loading', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapInApp(const CustomButton(text: 'Save', isLoading: true)),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Save'), findsNothing);
      });

      testWidgets('does not show CircularProgressIndicator when not loading', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapInApp(const CustomButton(text: 'Save', isLoading: false)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Save'), findsOneWidget);
      });
    });

    group('disabled state', () {
      testWidgets('button is disabled when enabled is false', (tester) async {
        await tester.pumpWidget(
          wrapInApp(const CustomButton(text: 'Off', enabled: false)),
        );
        await tester.pumpAndSettle();

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('button is enabled when enabled is true', (tester) async {
        await tester.pumpWidget(
          wrapInApp(CustomButton(text: 'On', enabled: true, onPressed: () {})),
        );
        await tester.pumpAndSettle();

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('isFullWidth', () {
      testWidgets('wraps button in SizedBox when full width', (tester) async {
        await tester.pumpWidget(
          wrapInApp(const CustomButton(text: 'Full', isFullWidth: true)),
        );
        await tester.pumpAndSettle();

        final sizedBox = tester.widget<SizedBox>(
          find
              .ancestor(
                of: find.byType(ElevatedButton),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(sizedBox.width, double.infinity);
      });

      testWidgets('does not wrap when not full width', (tester) async {
        await tester.pumpWidget(
          wrapInApp(const CustomButton(text: 'Not Full', isFullWidth: false)),
        );
        await tester.pumpAndSettle();

        final sizedBoxes = tester.widgetList<SizedBox>(
          find.ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          ),
        );

        final hasInfinity = sizedBoxes.any((sb) => sb.width == double.infinity);
        expect(hasInfinity, isFalse);
      });
    });

    group('icon', () {
      testWidgets('shows icon at start by default', (tester) async {
        await tester.pumpWidget(
          wrapInApp(const CustomButton(text: 'With Icon', icon: Icons.add)),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('With Icon'), findsOneWidget);
      });

      testWidgets('shows icon at end when specified', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const CustomButton(
              text: 'End Icon',
              icon: Icons.arrow_forward,
              iconPosition: IconPosition.end,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
        expect(find.text('End Icon'), findsOneWidget);
      });

      testWidgets('does not show icon when icon is null', (tester) async {
        await tester.pumpWidget(wrapInApp(const CustomButton(text: 'No Icon')));
        await tester.pumpAndSettle();

        expect(find.byType(Icon), findsNothing);
      });
    });

    group('sizes', () {
      testWidgets('small size renders', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const CustomButton(text: 'Small', size: CustomButtonSize.small),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('medium size renders (default)', (tester) async {
        await tester.pumpWidget(wrapInApp(const CustomButton(text: 'Medium')));
        await tester.pumpAndSettle();

        expect(find.text('Medium'), findsOneWidget);
      });

      testWidgets('large size renders', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const CustomButton(text: 'Large', size: CustomButtonSize.large),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Large'), findsOneWidget);
      });
    });
  });
}
