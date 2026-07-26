import 'dart:async';

import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's real fonts before any widget test runs. Without this,
/// text renders with Flutter's fallback test font, whose glyphs are wider
/// than DMSans/InstrumentSerif — enough to make tight rows (icon + label
/// buttons) report a false RenderFlex overflow that doesn't happen in the
/// real app.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont('DMSans', const [
      'assets/fonts/DMSans-Regular.ttf',
      'assets/fonts/DMSans-Medium.ttf',
      'assets/fonts/DMSans-SemiBold.ttf',
      'assets/fonts/DMSans-Bold.ttf',
    ]);
    await _loadFont('InstrumentSerif', const [
      'assets/fonts/InstrumentSerif-Regular.ttf',
      'assets/fonts/InstrumentSerif-Italic.ttf',
    ]);
  });

  await testMain();
}

Future<void> _loadFont(String family, List<String> assetPaths) async {
  final loader = FontLoader(family);
  for (final path in assetPaths) {
    loader.addFont(rootBundle.load(path));
  }
  await loader.load();
}
