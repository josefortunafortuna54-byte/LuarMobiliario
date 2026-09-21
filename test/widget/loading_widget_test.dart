import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/loading_widget.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: child);
  }

  group('LoadingWidget', () {
    testWidgets('renders CircularProgressIndicator by default', (tester) async {
      await tester.pumpWidget(wrapInApp(const LoadingWidget()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders custom size', (tester) async {
      await tester.pumpWidget(wrapInApp(const LoadingWidget(size: 60)));

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(LoadingWidget),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 60);
      expect(sizedBox.height, 60);
    });

    testWidgets('renders message when provided', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const LoadingWidget(message: 'A carregar...')),
      );

      expect(find.text('A carregar...'), findsOneWidget);
    });

    testWidgets('does not render message when null', (tester) async {
      await tester.pumpWidget(wrapInApp(const LoadingWidget()));

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders full screen scaffold variant', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const LoadingWidget(isFullScreen: true, message: 'Abrindo')),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Abrindo'), findsOneWidget);
    });
  });

  group('PropertyCardShimmer', () {
    testWidgets('renders vertical variant by default', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const PropertyCardShimmer()),
      );

      expect(find.byType(PropertyCardShimmer), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsWidgets);
    });

    testWidgets('renders horizontal variant', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const PropertyCardShimmer(isHorizontal: true)),
      );

      expect(find.byType(PropertyCardShimmer), findsOneWidget);
    });
  });
}