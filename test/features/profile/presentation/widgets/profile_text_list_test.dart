import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/profile/presentation/widgets/profile_text_list.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Post post(String id, {String caption = 'hello world'}) => Post(
        id: id,
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        caption: caption,
        createdAt: DateTime(2026, 1, 1),
      );

  Widget wrapInScrollView(Widget sliver) =>
      CustomScrollView(slivers: [sliver]);

  testWidgets('renders nothing for an empty post list', (tester) async {
    await pumpApp(
      tester,
      wrapInScrollView(ProfileTextList(
        posts: const [],
        onPostTap: (_) {},
        onUserTap: (_) {},
        onLikeTap: (_) {},
        onSaveTap: (_) {},
      )),
    );

    expect(find.text('hello world'), findsNothing);
  });

  testWidgets('renders each post\'s caption', (tester) async {
    await pumpApp(
      tester,
      wrapInScrollView(ProfileTextList(
        posts: [post('p1', caption: 'first'), post('p2', caption: 'second')],
        onPostTap: (_) {},
        onUserTap: (_) {},
        onLikeTap: (_) {},
        onSaveTap: (_) {},
      )),
    );

    expect(find.textContaining('first', findRichText: true), findsOneWidget);
    expect(find.textContaining('second', findRichText: true), findsOneWidget);
  });

  testWidgets('tapping the like icon calls onLikeTap with the post',
      (tester) async {
    Post? liked;
    await pumpApp(
      tester,
      wrapInScrollView(ProfileTextList(
        posts: [post('p1')],
        onPostTap: (_) {},
        onUserTap: (_) {},
        onLikeTap: (p) => liked = p,
        onSaveTap: (_) {},
      )),
    );

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    expect(liked?.id, 'p1');
  });

  testWidgets('tapping the save icon calls onSaveTap with the post',
      (tester) async {
    Post? saved;
    await pumpApp(
      tester,
      wrapInScrollView(ProfileTextList(
        posts: [post('p1')],
        onPostTap: (_) {},
        onUserTap: (_) {},
        onLikeTap: (_) {},
        onSaveTap: (p) => saved = p,
      )),
    );

    await tester.tap(find.byIcon(Icons.bookmark_outline_rounded));
    expect(saved?.id, 'p1');
  });
}
