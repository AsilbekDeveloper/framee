import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/core/providers/locale_provider.dart';
import 'package:framee/features/settings/presentation/widgets/settings_language_tile.dart';
import 'package:framee/i18n/strings.g.dart';

import '../../../../helpers/pump_app.dart';

/// Records the requested locale instead of touching SharedPreferences,
/// Supabase, or the global LocaleSettings singleton — those side effects
/// would otherwise leak into other tests running in the same process.
class _RecordingLocaleNotifier extends LocaleNotifier {
  AppLocale? lastSet;

  @override
  Future<AppLocale> build() async => AppLocale.en;

  @override
  Future<void> setLocale(AppLocale locale) async {
    lastSet = locale;
  }
}

void main() {
  testWidgets('renders the current locale name', (tester) async {
    await pumpApp(
      tester,
      const SettingsLanguageTile(currentLocale: AppLocale.en),
    );

    expect(find.text(AppStrings.language), findsOneWidget);
    expect(find.text(AppStrings.english), findsOneWidget);
  });

  testWidgets('opening the menu shows every supported language',
      (tester) async {
    await pumpApp(
      tester,
      const SettingsLanguageTile(currentLocale: AppLocale.en),
    );

    await tester.tap(find.byType(PopupMenuButton<AppLocale>));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.uzbek), findsOneWidget);
    expect(find.text(AppStrings.russian), findsOneWidget);
  });

  testWidgets('selecting a language calls setLocale with it', (tester) async {
    final notifier = _RecordingLocaleNotifier();
    await pumpApp(
      tester,
      const SettingsLanguageTile(currentLocale: AppLocale.en),
      overrides: [localeProvider.overrideWith(() => notifier)],
    );

    await tester.tap(find.byType(PopupMenuButton<AppLocale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.uzbek));
    await tester.pumpAndSettle();

    expect(notifier.lastSet, AppLocale.uz);
  });
}
