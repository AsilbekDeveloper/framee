import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/post/presentation/widgets/image_picker_area.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_image.dart';

void main() {
  testWidgets('ImagePickerArea renders the prompt and calls onTap',
      (tester) async {
    var tapped = false;
    await pumpApp(tester, ImagePickerArea(onTap: () => tapped = true));

    expect(find.text(AppStrings.addPhoto), findsOneWidget);
    await tester.tap(find.byType(ImagePickerArea));
    expect(tapped, isTrue);
  });

  group('SelectedImage', () {
    late String path;
    late void Function() cleanup;

    setUp(() {
      (path, cleanup) = createTestImageFile();
    });

    tearDown(() => cleanup());

    testWidgets('tapping crop calls onCrop', (tester) async {
      var cropped = false;
      await pumpApp(
        tester,
        SelectedImage(path: path, onRemove: () {}, onCrop: () => cropped = true),
      );

      await tester.tap(find.byIcon(Icons.crop_rounded));
      expect(cropped, isTrue);
    });

    testWidgets('tapping remove calls onRemove', (tester) async {
      var removed = false;
      await pumpApp(
        tester,
        SelectedImage(
            path: path, onRemove: () => removed = true, onCrop: () {}),
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(removed, isTrue);
    });
  });
}
