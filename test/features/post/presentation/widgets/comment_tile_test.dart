import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/components/app_avatar.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/presentation/widgets/comment_tile.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Comment comment(
    String id, {
    String authorId = 'author-1',
    String username = 'jane',
    String text = 'hello world',
    bool isLiked = false,
    int likesCount = 0,
    List<Comment> replies = const [],
  }) =>
      Comment(
        id: id,
        postId: 'post-1',
        author: PostAuthor(id: authorId, username: username, displayName: 'Jane'),
        text: text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isLiked: isLiked,
        likesCount: likesCount,
        replies: replies,
      );

  testWidgets('renders the comment text, author, and reply action',
      (tester) async {
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1', username: 'jane', text: 'hello world'),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (_) {},
      ),
    );

    expect(find.textContaining('jane', findRichText: true), findsOneWidget);
    expect(find.textContaining('hello world', findRichText: true),
        findsOneWidget);
    expect(find.text(AppStrings.reply), findsOneWidget);
  });

  testWidgets('shows the like count only when greater than zero',
      (tester) async {
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1', likesCount: 0),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (_) {},
      ),
    );
    expect(find.textContaining(AppStrings.likes), findsNothing);

    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c2', likesCount: 3),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (_) {},
      ),
    );
    expect(find.textContaining(AppStrings.likes), findsOneWidget);
  });

  testWidgets('tapping the like icon calls onLikeTap', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1'),
        onLikeTap: () => tapped = true,
        onReplyTap: (_) {},
        onUserTap: (_) {},
      ),
    );

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    expect(tapped, isTrue);
  });

  testWidgets('the like icon reflects isLiked', (tester) async {
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1', isLiked: true),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (_) {},
      ),
    );

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
  });

  testWidgets('tapping Reply passes the comment author\'s username',
      (tester) async {
    String? repliedTo;
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1', username: 'jane'),
        onLikeTap: () {},
        onReplyTap: (username) => repliedTo = username,
        onUserTap: (_) {},
      ),
    );

    await tester.tap(find.text(AppStrings.reply));
    expect(repliedTo, 'jane');
  });

  testWidgets('the Delete action only appears when onDeleteTap is provided',
      (tester) async {
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1'),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (_) {},
      ),
    );
    expect(find.text(AppStrings.delete), findsNothing);

    var deleted = false;
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1'),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (_) {},
        onDeleteTap: () => deleted = true,
      ),
    );
    expect(find.text(AppStrings.delete), findsOneWidget);
    await tester.tap(find.text(AppStrings.delete));
    expect(deleted, isTrue);
  });

  testWidgets('renders replies and forwards their like/delete taps',
      (tester) async {
    String? likedReplyId;
    String? deletedReplyId;
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1', replies: [
          comment('r1', authorId: 'reply-author', username: 'bob', text: 'a reply'),
        ]),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (_) {},
        currentUserId: 'reply-author',
        onReplyLikeTap: (id) => likedReplyId = id,
        onReplyDeleteTap: (id) => deletedReplyId = id,
      ),
    );

    expect(
        find.textContaining('a reply', findRichText: true), findsOneWidget);
    // Two like icons now: the reply's (nested inside the replies section,
    // found first in tree order) and the top-level comment's.
    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    expect(likedReplyId, 'r1');

    await tester.tap(find.text(AppStrings.delete));
    expect(deletedReplyId, 'r1');
  });

  testWidgets('tapping the avatar calls onUserTap with the author id',
      (tester) async {
    String? tappedUserId;
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1', authorId: 'author-1'),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (id) => tappedUserId = id,
      ),
    );

    await tester.tap(find.byType(AppAvatar));
    expect(tappedUserId, 'author-1');
  });

  testWidgets('tapping the username in the bubble calls onUserTap',
      (tester) async {
    String? tappedUserId;
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1', authorId: 'author-1', username: 'jane'),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (id) => tappedUserId = id,
      ),
    );

    await tester.tapAt(
      tester.getTopLeft(find.textContaining('jane', findRichText: true)) +
          const Offset(4, 8),
    );
    expect(tappedUserId, 'author-1');
  });

  testWidgets('tapping a reply\'s avatar calls onUserTap with the reply author id',
      (tester) async {
    String? tappedUserId;
    await pumpApp(
      tester,
      CommentTile(
        comment: comment('c1', replies: [
          comment('r1', authorId: 'reply-author', username: 'bob'),
        ]),
        onLikeTap: () {},
        onReplyTap: (_) {},
        onUserTap: (id) => tappedUserId = id,
      ),
    );

    await tester.tap(find.byType(AppAvatar).last);
    expect(tappedUserId, 'reply-author');
  });
}
