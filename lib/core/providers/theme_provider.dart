import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

/// Theme holati — SharedPreferences dan async yuklaydi.
///
/// `AsyncNotifier<ThemeMode>` ishlatiladi, shuning uchun app birinchi
/// renderda to'g'ri ThemeMode ni ko'rsatadi (race condition yo'q).
///
/// UI tomonida:
/// ```dart
/// final themeAsync = ref.watch(themeModeProvider);
/// final isDark = themeAsync.valueOrNull == ThemeMode.dark;
/// ```
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    if (saved == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, mode.name);
  }

  Future<void> toggleDarkMode() async {
    final current = state.valueOrNull ?? ThemeMode.system;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  bool get isDark => state.valueOrNull == ThemeMode.dark;
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
