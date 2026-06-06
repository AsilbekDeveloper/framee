import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);
  static ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryMuted,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primaryMuted,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.info,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      surfaceContainerHighest:
          isDark ? AppColors.darkElevated : AppColors.lightElevated,
      outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      outlineVariant:
          isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface:
          isDark ? AppColors.lightSurface : AppColors.darkSurface,
      onInverseSurface:
          isDark ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
      inversePrimary: AppColors.primaryLight,
    );

    final textTheme = TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      headlineLarge: AppTextStyles.h2,
      headlineMedium: AppTextStyles.h3,
      headlineSmall: AppTextStyles.h4,
      titleLarge: AppTextStyles.h3,
      titleMedium: AppTextStyles.labelLarge,
      titleSmall: AppTextStyles.labelMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonLarge,
      labelMedium: AppTextStyles.buttonMedium,
      labelSmall: AppTextStyles.buttonSmall,
    ).apply(
      bodyColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      displayColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: 'DMSans',
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      cardColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      dividerColor: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor:
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              ),
        shape: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor:
            isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.overlineBold,
        unselectedLabelStyle: AppTextStyles.overline,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        indicatorColor: AppColors.primaryMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.overlineBold
                .copyWith(color: AppColors.primary);
          }
          return AppTextStyles.overline.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            size: 24,
          );
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkInput : AppColors.lightInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color:
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          side: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
            width: 1.5,
          ),
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonMedium,
          shape: const StadiumBorder(),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        selectedColor: AppColors.primaryMuted,
        labelStyle: AppTextStyles.labelSmall,
        side: BorderSide(
          color: isDark
              ? AppColors.darkBorderSubtle
              : AppColors.lightBorderSubtle,
          width: 1.5,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        showCheckmark: false,
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor:
            isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTextStyles.labelMedium,
        unselectedLabelStyle: AppTextStyles.labelMedium,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
        thickness: 1,
        space: 0,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        titleTextStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        subtitleTextStyle: AppTextStyles.caption.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark
              ? AppColors.darkTextMuted
              : AppColors.lightTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return isDark
              ? AppColors.darkElevated
              : AppColors.lightElevated;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.darkBackground : AppColors.lightSurface,
        ),
        shape: const StadiumBorder(),
        elevation: 0,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
