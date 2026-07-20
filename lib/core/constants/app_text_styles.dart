import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle _headingBase({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color color = AppColors.navy,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle _bodyBase({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color color = AppColors.gray800,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  // ── Heading styles (Playfair Display) ──────────────────────────────

  static TextStyle get h1 => _headingBase(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static TextStyle get h2 => _headingBase(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.15,
  );

  static TextStyle get h3 =>
      _headingBase(fontSize: 32, fontWeight: FontWeight.w600, height: 1.2);

  static TextStyle get h4 =>
      _headingBase(fontSize: 28, fontWeight: FontWeight.w600, height: 1.25);

  static TextStyle get h5 =>
      _headingBase(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get h6 =>
      _headingBase(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);

  // ── Gold heading variants ──────────────────────────────────────────

  static TextStyle get h1Gold => h1.copyWith(color: AppColors.gold);
  static TextStyle get h2Gold => h2.copyWith(color: AppColors.gold);
  static TextStyle get h3Gold => h3.copyWith(color: AppColors.gold);
  static TextStyle get h4Gold => h4.copyWith(color: AppColors.gold);
  static TextStyle get h5Gold => h5.copyWith(color: AppColors.gold);

  static TextStyle get h1White => h1.copyWith(color: AppColors.white);
  static TextStyle get h2White => h2.copyWith(color: AppColors.white);
  static TextStyle get h3White => h3.copyWith(color: AppColors.white);
  static TextStyle get h4White => h4.copyWith(color: AppColors.white);
  static TextStyle get h5White => h5.copyWith(color: AppColors.white);

  // ── Body styles (DM Sans) ──────────────────────────────────────────

  static TextStyle get bodyLarge =>
      _bodyBase(fontSize: 18, fontWeight: FontWeight.w400, height: 1.6);

  static TextStyle get bodyMedium =>
      _bodyBase(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall =>
      _bodyBase(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyTiny =>
      _bodyBase(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);

  // ── Body bold variants ─────────────────────────────────────────────

  static TextStyle get bodyLargeBold =>
      bodyLarge.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get bodyMediumBold =>
      bodyMedium.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get bodySmallBold =>
      bodySmall.copyWith(fontWeight: FontWeight.w700);

  // ── Button styles ──────────────────────────────────────────────────

  static TextStyle get buttonLarge => _bodyBase(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.white,
  );

  static TextStyle get buttonMedium => _bodyBase(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.white,
  );

  static TextStyle get buttonSmall => _bodyBase(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.white,
  );

  // ── Label / Overline styles ────────────────────────────────────────

  static TextStyle get labelLarge => _bodyBase(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.4,
  );

  static TextStyle get labelMedium => _bodyBase(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.4,
  );

  static TextStyle get labelSmall => _bodyBase(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.4,
  );

  static TextStyle get overline => _bodyBase(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.4,
    color: AppColors.gold,
  );

  // ── Caption / Helper ───────────────────────────────────────────────

  static TextStyle get caption => _bodyBase(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.gray500,
  );

  static TextStyle get helper => _bodyBase(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.gray600,
  );

  // ── Price styles ───────────────────────────────────────────────────

  static TextStyle get priceLarge => _headingBase(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static TextStyle get priceMedium => _headingBase(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static TextStyle get priceSmall => _bodyBase(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );
}
