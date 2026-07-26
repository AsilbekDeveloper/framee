import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/home/presentation/widgets/post_options_sheet.dart';
import 'package:framee/features/post/domain/entities/post.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Post post() => Post(
        id: 'post-1',
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        createdAt: DateTime(2026, 1, 1),
      );

  group('SheetOption', () {
    testWidgets('renders the icon and label and calls onTap', (tester) async {
      var tapped = false;
      await pumpApp(
        tester,
        SheetOption(
          icon: Icons.link_rounded,
          label: 'Copy link',
          onTap: () => tapped = true,
        ),
      );

      expect(find.byIcon(Icons.link_rounded), findsOneWidget);
      expect(find.text('Copy link'), findsOneWidget);
      await tester.tap(find.byType(SheetOption));
      expect(tapped, isTrue);
    });
  });

  group('PostOptionsSheet', () {
    testWidgets('shows the unsaved-post label and icon when not saved',
        (tester) async {
      await pumpApp(
        tester,
        PostOptionsSheet(post: post(), isSaved: false, onToggleSave: () {}),
      );

      expect(find.text(AppStrings.savePost), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline_rounded), findsOneWidget);
      expect(find.text(AppStrings.postSaved), findsNothing);
    });

    testWidgets('shows the saved-post label and icon when saved',
        (tester) async {
      await pumpApp(
        tester,
        PostOptionsSheet(post: post(), isSaved: true, onToggleSave: () {}),
      );

      expect(find.text(AppStrings.postSaved), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });

    testWidgets('shows Delete only when onDelete is provided', (tester) async {
      await pumpApp(
        tester,
        PostOptionsSheet(post: post(), isSaved: false, onToggleSave: () {}),
      );
      expect(find.text(AppStrings.deletePost), findsNothing);

      await pumpApp(
        tester,
        PostOptionsSheet(
          post: post(),
          isSaved: false,
          onToggleSave: () {},
          onDelete: () {},
        ),
      );
      expect(find.text(AppStrings.deletePost), findsOneWidget);
    });

    testWidgets('always shows Copy Link and Share', (tester) async {
      await pumpApp(
        tester,
        PostOptionsSheet(post: post(), isSaved: false, onToggleSave: () {}),
      );

      expect(find.text(AppStrings.copyLink), findsOneWidget);
      expect(find.text(AppStrings.sharePost), findsOneWidget);
    });
  });
}
