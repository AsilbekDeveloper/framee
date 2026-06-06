import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Localization setup for Framee.
/// Currently ships English only.
/// To add Uzbek/Russian: run `flutter gen-l10n` with ARB files.
abstract final class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    // Locale('uz'), // Uzbek — add ARB file first
    // Locale('ru'), // Russian — add ARB file first
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
