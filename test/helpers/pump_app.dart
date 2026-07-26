import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] with the same [ScreenUtilInit]/[MaterialApp] shell the real
/// app builds, plus a [ProviderScope] carrying [overrides], so widgets that
/// use `.w`/`.h`/`.sp` sizing and Riverpod providers render the same way
/// they do in the app.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  // Set to false when the widget renders a perpetually-animating widget
  // (e.g. an indeterminate CircularProgressIndicator) on its first frame —
  // pumpAndSettle() never converges against those and times out.
  bool settle = true,
}) async {
  // Match the app's phone-sized design so ScreenUtil-scaled layouts (built
  // for a 393x852 screen) don't overflow the default 800x600 test surface.
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        // Material wraps bare (non-Scaffold) widgets under test — e.g. list
        // tiles — that rely on an InkWell/Ink ancestor providing Material,
        // the same way their real Scaffold-based parent screen would.
        builder: (context, _) => MaterialApp(home: Material(child: child)),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
