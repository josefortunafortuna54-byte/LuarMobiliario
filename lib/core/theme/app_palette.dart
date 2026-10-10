import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Tokens semânticos de cor que mudam com o tema (claro/escuro).
///
/// Usar via `context.palette` em vez de cores neutras fixas
/// (`AppColors.white`, `AppColors.gray*`, `AppColors.navy` como texto)
/// para que as superfícies e textos acompanhem o `Brightness` ativo.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.inputFill,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.textTitle,
    required this.textBody,
    required this.textSecondary,
    required this.textMuted,
    required this.onEmphasis,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color inputFill;
  final Color border;
  final Color borderStrong;
  final Color divider;
  final Color textTitle;
  final Color textBody;
  final Color textSecondary;
  final Color textMuted;
  final Color onEmphasis;

  static const AppPalette light = AppPalette(
    background: AppColors.offWhite,
    surface: AppColors.white,
    surfaceAlt: AppColors.gray100,
    inputFill: AppColors.white,
    border: AppColors.gray100,
    borderStrong: AppColors.gray200,
    divider: AppColors.gray200,
    textTitle: AppColors.navy,
    textBody: AppColors.gray800,
    textSecondary: AppColors.gray500,
    textMuted: AppColors.gray400,
    onEmphasis: AppColors.white,
  );

  static const AppPalette dark = AppPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceAlt: AppColors.darkCard,
    inputFill: AppColors.darkSurface,
    border: AppColors.darkBorder,
    borderStrong: AppColors.darkBorderStrong,
    divider: AppColors.darkBorderStrong,
    textTitle: AppColors.darkTextTitle,
    textBody: AppColors.darkTextBody,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    onEmphasis: AppColors.white,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? inputFill,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? textTitle,
    Color? textBody,
    Color? textSecondary,
    Color? textMuted,
    Color? onEmphasis,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      inputFill: inputFill ?? this.inputFill,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      textTitle: textTitle ?? this.textTitle,
      textBody: textBody ?? this.textBody,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      onEmphasis: onEmphasis ?? this.onEmphasis,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textTitle: Color.lerp(textTitle, other.textTitle, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      onEmphasis: Color.lerp(onEmphasis, other.onEmphasis, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}