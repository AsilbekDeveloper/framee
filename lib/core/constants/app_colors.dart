import 'package:flutter/material.dart';

/// Framee centralized color palette.
/// All colors in the app must come from this class.
abstract final class AppColors {
  // ─── Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF6C4EF6);
  static const Color primaryLight = Color(0xFF8B72F8);
  static const Color primaryDark = Color(0xFF5035D4);
  static const Color primaryMuted = Color(0x1A6C4EF6); // ~10% opacity
  static const Color primaryGlow = Color(0x396C4EF6);  // ~22% opacity

  // ─── Light Theme Surfaces ─────────────────────────────────
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF2F1FA);
  static const Color lightInput = Color(0xFFF0EFF9);

  // ─── Light Theme Text ─────────────────────────────────────
  static const Color lightTextPrimary = Color(0xFF0D0B1A);
  static const Color lightTextSecondary = Color(0xFF6B6880);
  static const Color lightTextMuted = Color(0xFFA09DBB);

  // ─── Light Theme Borders ──────────────────────────────────
  static const Color lightBorder = Color(0x216C4EF6);     // ~13%
  static const Color lightBorderSubtle = Color(0xFFEDEEF5);

  // ─── Dark Theme Surfaces ──────────────────────────────────
  static const Color darkBackground = Color(0xFF0E0C1A);
  static const Color darkSurface = Color(0xFF19172B);
  static const Color darkElevated = Color(0xFF211E35);
  static const Color darkInput = Color(0xFF211E35);

  // ─── Dark Theme Text ──────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF0EEFF);
  static const Color darkTextSecondary = Color(0xFF9490B8);
  static const Color darkTextMuted = Color(0xFF5E5A80);

  // ─── Dark Theme Borders ───────────────────────────────────
  static const Color darkBorder = Color(0x336C4EF6);      // ~20%
  static const Color darkBorderSubtle = Color(0xFF211E35);

  // ─── Semantic ─────────────────────────────────────────────
  static const Color success = Color(0xFF40C480);
  static const Color error = Color(0xFFF04060);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF4FACFE);

  // ─── Social Actions ───────────────────────────────────────
  static const Color like = Color(0xFFF04060);
  static const Color likeBackground = Color(0x1AF04060);
  static const Color followBg = Color(0x1A40C480);
  static const Color commentBg = Color(0x1A40C480);

  // ─── Gradients ────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, Color(0xFFE040FB)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightBackground, lightElevated],
  );

  // ─── Shadows ──────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    const BoxShadow(
      color: Color(0x0F6C4EF6),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
