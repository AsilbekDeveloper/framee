import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Framee centralized typography system.
/// All text styles must come from this class.
abstract final class AppTextStyles {
  static const String _fontFamily = 'DMSans';
  static const String _serifFamily = 'InstrumentSerif';

  // ─── Display ──────────────────────────────────────────────
  static TextStyle get displayLarge => TextStyle(
    fontFamily: _serifFamily,
    fontSize: 52.sp,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.primary,
    letterSpacing: -1,
    height: 1.0,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: _serifFamily,
    fontSize: 36.sp,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  // ─── Headings ─────────────────────────────────────────────
  static TextStyle get h1 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get h2 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static TextStyle get h3 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static TextStyle get h4 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  // ─── Body ─────────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Labels ───────────────────────────────────────────────
  static TextStyle get labelLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get labelSmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ─── Caption / Overline ───────────────────────────────────
  static TextStyle get caption => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get overline => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get overlineBold => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // ─── Username / Handle ────────────────────────────────────
  static TextStyle get username => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get handle => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextMuted,
  );

  // ─── Stat numbers ─────────────────────────────────────────
  static TextStyle get statNumber => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle get statLabel => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );

  // ─── Button ───────────────────────────────────────────────
  static TextStyle get buttonLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get buttonMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get buttonSmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
  );

  // ─── Input ────────────────────────────────────────────────
  static TextStyle get inputText => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get inputLabel => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static TextStyle get inputHint => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
  );

  // ─── Section label ────────────────────────────────────────
  static TextStyle get sectionLabel => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
}
