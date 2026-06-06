import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, mode.name);
  }

  Future<void> toggleDarkMode() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
