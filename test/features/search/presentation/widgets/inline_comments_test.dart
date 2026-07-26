import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/post/data/providers/post_data_providers.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/search/presentation/widgets/inline_comments.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  const userId = 'user-1';
  late MockPostRepository postRepository;

  setUpAll(registerFallbackValues);

  setUp(() {
    postRepository = MockPostRepository();
  });

  List<Override> overrides() => [
        postRepositoryProvider.overrideWithValue(postRepository),
        currentUserIdProvider.overrideWithValue(userId),
      ];

  Post post({int commentsCount = 0}) => Post(
        id: 'post-1',
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        createdAt: DateTime(2026, 1, 1),
        commentsCount: commentsCount,
      );

  Comment comment(String id, {String? parentId}) => Comment(
        id: id,
        postId: 'post-1',
        author: const PostAuthor(id: 'author-2', username: 'b', displayName: 'B'),
        text: 'text-$id',
        createdAt: DateTime(2026, 1, 1),
        parentId: parentId,
      );

  testWidgets('renders nothing when the post has no comments', (tester) async {
    await pumpApp(
      tester,
      InlineComments(post: post(commentsCount: 0)),
      overrides: overrides(),
    );

    expect(find.textContaining(AppStrings.viewComments), findsNothing);
  });

  testWidgets('shows a "view comments" link with the count when collapsed',
      (tester) async {
    await pumpApp(
      tester,
      InlineComments(post: post(commentsCount: 3)),
      overrides: overrides(),
    );

    expect(find.textContaining('${AppStrings.viewComments} (3)'),
        findsOneWidget);
  });

  testWidgets('expanding loads and renders top-level comments only',
      (tester) async {
    when(() => postRepository.getComments(
          postId: 'post-1',
          currentUserId: userId,
        )).thenAnswer((_) async => Ok([
          comment('c1'),
          comment('r1', parentId: 'c1'),
        ]));

    await pumpApp(
      tester,
      InlineComments(post: post(commentsCount: 2)),
      overrides: overrides(),
    );

    await tester.tap(find.textContaining(AppStrings.viewComments));
    await tester.pumpAndSettle();

    expect(find.textContaining('text-c1', findRichText: true), findsOneWidget);
    expect(
        find.textContaining('text-r1', findRichText: true), findsNothing);
    expect(find.text(AppStrings.showLess), findsOneWidget);
  });

  testWidgets('collapsing hides the comments again', (tester) async {
    when(() => postRepository.getComments(
          postId: 'post-1',
          currentUserId: userId,
        )).thenAnswer((_) async => Ok([comment('c1')]));

    await pumpApp(
      tester,
      InlineComments(post: post(commentsCount: 1)),
      overrides: overrides(),
    );

    await tester.tap(find.textContaining(AppStrings.viewComments));
    await tester.pumpAndSettle();
    expect(find.textContaining('text-c1', findRichText: true), findsOneWidget);

    await tester.tap(find.text(AppStrings.showLess));
    await tester.pumpAndSettle();

    expect(find.textContaining('text-c1', findRichText: true), findsNothing);
    expect(find.textContaining(AppStrings.viewComments), findsOneWidget);
  });

  testWidgets('shows a "no comments yet" message when the list is empty',
      (tester) async {
    when(() => postRepository.getComments(
          postId: 'post-1',
          currentUserId: userId,
        )).thenAnswer((_) async => const Ok([]));

    await pumpApp(
      tester,
      InlineComments(post: post(commentsCount: 1)),
      overrides: overrides(),
    );

    await tester.tap(find.textContaining(AppStrings.viewComments));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noCommentsYet), findsOneWidget);
  });
}
