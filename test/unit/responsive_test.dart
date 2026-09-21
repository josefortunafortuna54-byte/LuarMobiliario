import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/responsive.dart';

void main() {
  Widget wrapWithSize(Widget child, Size size) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: child,
    );
  }

  group('Responsive.getScreenSize', () {
    testWidgets('returns mobile for width < 600', (tester) async {
      late ScreenSize result;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              result = Responsive.getScreenSize(context);
              return const SizedBox();
            },
          ),
          const Size(375, 800),
        ),
      );

      expect(result, ScreenSize.mobile);
    });

    testWidgets('returns tablet for 600 <= width < 1024', (tester) async {
      late ScreenSize result;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              result = Responsive.getScreenSize(context);
              return const SizedBox();
            },
          ),
          const Size(800, 800),
        ),
      );

      expect(result, ScreenSize.tablet);
    });

    testWidgets('returns desktop for width >= 1024', (tester) async {
      late ScreenSize result;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              result = Responsive.getScreenSize(context);
              return const SizedBox();
            },
          ),
          const Size(1280, 800),
        ),
      );

      expect(result, ScreenSize.desktop);
    });
  });

  group('Responsive helpers', () {
    testWidgets('isMobile is true for small screens', (tester) async {
      var isMobile = false;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              isMobile = Responsive.isMobile(context);
              return const SizedBox();
            },
          ),
          const Size(375, 800),
        ),
      );

      expect(isMobile, isTrue);
    });

    testWidgets('isDesktop is true for large screens', (tester) async {
      var isDesktop = false;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              isDesktop = Responsive.isDesktop(context);
              return const SizedBox();
            },
          ),
          const Size(1440, 900),
        ),
      );

      expect(isDesktop, isTrue);
    });
  });

  group('Responsive.horizontalPadding', () {
    testWidgets('returns 24 for mobile', (tester) async {
      double padding = 0;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              padding = Responsive.horizontalPadding(context);
              return const SizedBox();
            },
          ),
          const Size(375, 800),
        ),
      );

      expect(padding, 24);
    });

    testWidgets('returns 40 for tablet', (tester) async {
      double padding = 0;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              padding = Responsive.horizontalPadding(context);
              return const SizedBox();
            },
          ),
          const Size(800, 800),
        ),
      );

      expect(padding, 40);
    });

    testWidgets('returns 64 for desktop', (tester) async {
      double padding = 0;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              padding = Responsive.horizontalPadding(context);
              return const SizedBox();
            },
          ),
          const Size(1280, 800),
        ),
      );

      expect(padding, 64);
    });
  });

  group('Responsive.fontSize', () {
    testWidgets('returns base size on mobile', (tester) async {
      double size = 0;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              size = Responsive.fontSize(context, 16);
              return const SizedBox();
            },
          ),
          const Size(375, 800),
        ),
      );

      expect(size, 16);
    });

    testWidgets('scales up on desktop', (tester) async {
      double size = 0;

      await tester.pumpWidget(
        wrapWithSize(
          Builder(
            builder: (context) {
              size = Responsive.fontSize(context, 16);
              return const SizedBox();
            },
          ),
          const Size(1280, 800),
        ),
      );

      expect(size, closeTo(18.4, 0.01));
    });
  });
}