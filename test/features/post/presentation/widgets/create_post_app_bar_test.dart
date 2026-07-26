import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/post/presentation/widgets/create_post_app_bar.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the title and Post button', (tester) async {
    await pumpApp(
      tester,
      CreatePostAppBar(onClose: () {}, onPost: () async {}, isLoading: false),
    );

    expect(find.text(AppStrings.createPost), findsOneWidget);
    expect(find.text(AppStrings.post), findsOneWidget);
  });

  testWidgets('tapping close calls onClose', (tester) async {
    var closed = false;
    await pumpApp(
      tester,
      CreatePostAppBar(
        onClose: () => closed = true,
        onPost: () async {},
        isLoading: false,
      ),
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    expect(closed, isTrue);
  });

  testWidgets('tapping Post calls onPost when enabled', (tester) async {
    var posted = false;
    await pumpApp(
      tester,
      CreatePostAppBar(
        onClose: () {},
        onPost: () async => posted = true,
        isLoading: false,
      ),
    );

    await tester.tap(find.text(AppStrings.post));
    expect(posted, isTrue);
  });

  testWidgets('shows a spinner instead of the label while loading',
      (tester) async {
    await pumpApp(
      tester,
      CreatePostAppBar(onClose: () {}, onPost: () async {}, isLoading: true),
      settle: false,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(AppStrings.post), findsNothing);
  });

  testWidgets('Post is not tappable when onPost is null', (tester) async {
    var posted = false;
    await pumpApp(
      tester,
      CreatePostAppBar(onClose: () {}, onPost: null, isLoading: false),
    );

    await tester.tap(find.text(AppStrings.post));
    expect(posted, isFalse);
  });
}
