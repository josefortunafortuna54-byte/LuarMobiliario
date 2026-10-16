import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) return ScreenSize.mobile;
    if (width < tabletMax) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getScreenSize(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      getScreenSize(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      getScreenSize(context) == ScreenSize.desktop;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double horizontalPadding(BuildContext context) {
    final w = width(context);
    if (w >= tabletMax) return 64;
    if (w >= mobileMax) return 40;
    return 24;
  }

  static double contentMaxWidth(BuildContext context) {
    final w = width(context);
    if (w >= tabletMax) return 600;
    if (w >= mobileMax) return 480;
    return w;
  }

  static double fontSize(BuildContext context, double base) {
    final w = width(context);
    if (w >= tabletMax) return base * 1.15;
    if (w >= mobileMax) return base * 1.05;
    return base;
  }
}
