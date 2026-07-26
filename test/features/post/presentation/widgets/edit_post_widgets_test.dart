import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/post/presentation/widgets/edit_post_widgets.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_image.dart';

void main() {
  group('EditRemoteImagePreview', () {
    testWidgets('tapping the image calls onReplace, close calls onRemove',
        (tester) async {
      var replaced = false;
      var removed = false;
      await pumpApp(
        tester,
        EditRemoteImagePreview(
          url: 'https://example.com/a.jpg',
          onReplace: () => replaced = true,
          onRemove: () => removed = true,
          isDark: false,
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(replaced, isTrue);

      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });
  });

  group('EditLocalImagePreview', () {
    late String path;
    late void Function() cleanup;

    setUp(() {
      (path, cleanup) = createTestImageFile();
    });

    tearDown(() => cleanup());

    testWidgets('tapping the image calls onReplace, close calls onRemove',
        (tester) async {
      var replaced = false;
      var removed = false;
      await pumpApp(
        tester,
        EditLocalImagePreview(
          path: path,
          onReplace: () => replaced = true,
          onRemove: () => removed = true,
          isDark: false,
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(replaced, isTrue);

      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });
  });

  testWidgets('EditImagePlaceholder renders the prompt and calls onTap',
      (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      EditImagePlaceholder(onTap: () => tapped = true, isDark: false),
    );

    expect(find.text(AppStrings.addPhoto), findsOneWidget);
    await tester.tap(find.byType(EditImagePlaceholder));
    expect(tapped, isTrue);
  });

  testWidgets('EditBottomToolbar renders the gallery action and calls onTap',
      (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      EditBottomToolbar(onGalleryTap: () => tapped = true, isDark: false),
    );

    expect(find.text(AppStrings.addPhoto), findsOneWidget);
    await tester.tap(find.text(AppStrings.addPhoto));
    expect(tapped, isTrue);
  });
}
