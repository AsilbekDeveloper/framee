import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/search/presentation/widgets/explore_grid.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Post post(String id, {String? imageUrl, String caption = 'hello'}) => Post(
        id: id,
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        imageUrl: imageUrl,
        caption: imageUrl == null ? caption : null,
        createdAt: DateTime(2026, 1, 1),
      );

  testWidgets('shows a placeholder icon when the photo grid is empty',
      (tester) async {
    await pumpApp(
      tester,
      ExploreGrid(
        posts: const [],
        onPostTap: (_) {},
        onUserTap: (_) {},
        onRefresh: () async {},
        onLikeTap: (_) {},
        onSaveTap: (_) {},
      ),
    );

    expect(find.byIcon(Icons.photo_outlined), findsOneWidget);
  });

  testWidgets('tapping a grid cell calls onPostTap with the post id',
      (tester) async {
    String? tappedId;
    await pumpApp(
      tester,
      ExploreGrid(
        posts: [post('p1', imageUrl: 'https://example.com/a.jpg')],
        onPostTap: (id) => tappedId = id,
        onUserTap: (_) {},
        onRefresh: () async {},
        onLikeTap: (_) {},
        onSaveTap: (_) {},
      ),
    );

    await tester.tap(find.ancestor(
      of: find.byType(ExploreCell),
      matching: find.byType(GestureDetector),
    ));
    expect(tappedId, 'p1');
  });

  testWidgets(
      'switching to the text tab renders text-only posts and their like/save taps',
      (tester) async {
    String? likedId;
    String? savedId;
    await pumpApp(
      tester,
      ExploreGrid(
        posts: [post('p1', caption: 'a text post')],
        onPostTap: (_) {},
        onUserTap: (_) {},
        onRefresh: () async {},
        onLikeTap: (id) => likedId = id,
        onSaveTap: (id) => savedId = id,
      ),
    );

    await tester.tap(find.byIcon(Icons.format_list_bulleted_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('a text post', findRichText: true),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    expect(likedId, 'p1');

    await tester.tap(find.byIcon(Icons.bookmark_outline_rounded));
    expect(savedId, 'p1');
  });

  testWidgets('the text tab shows a placeholder icon when empty',
      (tester) async {
    await pumpApp(
      tester,
      ExploreGrid(
        posts: const [],
        onPostTap: (_) {},
        onUserTap: (_) {},
        onRefresh: () async {},
        onLikeTap: (_) {},
        onSaveTap: (_) {},
      ),
    );

    await tester.tap(find.byIcon(Icons.format_list_bulleted_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.text_fields_rounded), findsOneWidget);
  });
}
