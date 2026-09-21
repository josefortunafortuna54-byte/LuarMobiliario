import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/avatar_widget.dart';

void main() {
  group('AvatarWidget', () {
    testWidgets('renders initials when no image is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AvatarWidget(name: 'Carlos Menezes')),
        ),
      );

      expect(find.text('CM'), findsOneWidget);
    });

    testWidgets('renders single initial for single name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AvatarWidget(name: 'Ana'))),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders question mark when name is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AvatarWidget())),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('renders question mark for empty name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AvatarWidget(name: '   '))),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('renders online indicator when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              name: 'Carlos',
              showOnlineIndicator: true,
            ),
          ),
        ),
      );

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('triggers onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              name: 'Carlos',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('C'));
      expect(tapped, isTrue);
    });

    testWidgets('uses uppercase initials', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AvatarWidget(name: 'joao silva')),
        ),
      );

      expect(find.text('JS'), findsOneWidget);
    });
  });
}