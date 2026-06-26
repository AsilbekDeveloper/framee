import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Persists the selected locale locally and syncs it to Supabase.
  Future<void> setLocale(AppLocale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageTag);
    LocaleSettings.setLocale(locale);
    state = AsyncData(locale);
    await _syncToSupabase(locale);
  }

  /// Call after login to push the locally stored locale to Supabase.
  Future<void> syncAfterLogin() async {
    final locale = state.valueOrNull;
    if (locale != null) await _syncToSupabase(locale);
  }

  Future<void> _syncToSupabase(AppLocale locale) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;
      await client
          .from('profiles')
          .update({'locale': locale.languageTag})
          .eq('id', userId);
    } catch (e) {
      if (kDebugMode) debugPrint('[Locale] Failed to sync locale: $e');
    }
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, AppLocale>(
  LocaleNotifier.new,
);
