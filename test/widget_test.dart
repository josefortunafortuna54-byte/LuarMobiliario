import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luar_company/app.dart';

void main() {
  testWidgets('LuarCompanyApp renders MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const LuarCompanyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('app title matches AppConstants.appName', (WidgetTester tester) async {
    await tester.pumpWidget(const LuarCompanyApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Luar Company Imobiliária');
  });

  testWidgets('debug banner is disabled', (WidgetTester tester) async {
    await tester.pumpWidget(const LuarCompanyApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
  });

  testWidgets('app builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const LuarCompanyApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
