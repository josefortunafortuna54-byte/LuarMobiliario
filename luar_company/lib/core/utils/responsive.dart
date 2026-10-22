import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  /// Largura máxima de uma célula de grelha (cartões) — colunas adaptam-se
  /// automaticamente à largura do ecrã (1/2/3/4+ colunas).
  static const double maxGridCellExtent = 300;

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

  /// Largura máxima do conteúdo linear (formulários, detalhes, listas) para
  /// evitar campos/textos esticados em ecrãs grandes.
  static double contentMaxWidth(BuildContext context) {
    final w = width(context);
    if (w >= tabletMax) return 720;
    if (w >= mobileMax) return 640;
    return w;
  }

  /// Largura máxima para grelhas de cartões (mais larga que [contentMaxWidth]
  /// para aproveitar o espaço em tablet/desktop).
  static double gridMaxWidth(BuildContext context) {
    final w = width(context);
    if (w >= tabletMax) return 1200;
    if (w >= mobileMax) return 900;
    return w;
  }

  /// Número de colunas para grelhas adaptativas.
  static int gridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
    }
  }

  static double fontSize(BuildContext context, double base) {
    final w = width(context);
    if (w >= tabletMax) return base * 1.15;
    if (w >= mobileMax) return base * 1.05;
    return base;
  }
}
