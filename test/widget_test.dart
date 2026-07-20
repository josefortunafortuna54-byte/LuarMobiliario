import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luar_company/core/constants/app_constants.dart';

void main() {
  testWidgets('MaterialApp renders with correct title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(title: AppConstants.appName, home: const Scaffold()),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Luar Company Imobiliária');
  });

  testWidgets('debug banner is disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
  });
}
