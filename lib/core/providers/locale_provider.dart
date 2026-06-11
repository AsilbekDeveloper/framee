import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../i18n/strings.g.dart';

/// Manages the app locale, persisting the user's selection across sessions.
class LocaleNotifier extends AsyncNotifier<AppLocale> {
  static const _key = 'app_locale';

  @override
  Future<AppLocale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final tag = prefs.getString(_key);
    final locale = tag != null ? AppLocaleUtils.parse(tag) : AppLocale.en;
    LocaleSettings.setLocale(locale);
    return locale;
  }

  /// Persists the selected locale and applies it immediately.
  Future<void> setLocale(AppLocale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageTag);
    LocaleSettings.setLocale(locale);
    state = AsyncData(locale);
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, AppLocale>(
  LocaleNotifier.new,
);
