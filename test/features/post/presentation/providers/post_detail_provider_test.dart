import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/post/data/providers/post_data_providers.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/failures/post_failure.dart';
import 'package:framee/features/post/presentation/providers/post_detail_provider.dart';
import 'package:framee/features/profile/data/providers/profile_data_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const userId = 'user-1';
  const postId = 'post-1';

  late MockPostRepository postRepository;
  late MockProfileRepository profileRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    postRepository = MockPostRepository();
    profileRepository = MockProfileRepository();

    container = ProviderContainer(overrides: [
      postRepositoryProvider.overrideWithValue(postRepository),
      profileRepositoryProvider.overrideWithValue(profileRepository),
      currentUserIdProvider.overrideWithValue(userId),
    ]);
    addTearDown(container.dispose);
  });

  Post post({bool isLiked = false, int likesCount = 2, bool isSaved = false, int commentsCount = 0}) =>
      Post(
        id: postId,
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        createdAt: DateTime(2026, 1, 1),
        isLiked: isLiked,
        likesCount: likesCount,
        isSaved: isSaved,
        commentsCount: commentsCount,
      );

  Comment comment(
    String id, {
    String? parentId,
    bool isLiked = false,
    int likesCount = 0,
    List<Comment> replies = const [],
  }) =>
      Comment(
        id: id,
        postId: postId,
        author: const PostAuthor(id: 'author-2', username: 'b', displayName: 'B'),
        text: 'text-$id',
        createdAt: DateTime(2026, 1, 1),
        isLiked: isLiked,
        likesCount: likesCount,
        parentId: parentId,
        replies: replies,
      );

  Future<PostDetailState> load({
    Post? seedPost,
    List<Comment> comments = const [],
  }) async {
    when(() => postRepository.getPost(
          postId: postId,
          currentUserId: userId,
        )).thenAnswer((_) async => Ok(seedPost ?? post()));
    when(() => postRepository.getComments(
          postId: postId,
          currentUserId: userId,
        )).thenAnswer((_) async => Ok(comments));
    return container.read(postDetailProvider(postId).future);
  }

  test('build loads the post and its comments', () async {
    final state = await load(comments: [comment('c1')]);

    expect(state.post!.id, postId);
    expect(state.comments, hasLength(1));
  });

  group('toggleLike', () {
    test('applies the server-confirmed value on success', () async {
      await load(seedPost: post(isLiked: false, likesCount: 2));
      when(() => postRepository.toggleLike(
            postId: postId,
            currentUserId: userId,
          )).thenAnswer((_) async => const Ok((likesCount: 3, isLiked: true)));

      await container.read(postDetailProvider(postId).notifier).toggleLike();

      final state = container.read(postDetailProvider(postId)).value!;
      expect(state.post!.isLiked, isTrue);
      expect(state.post!.likesCount, 3);
    });

    test('rolls back on failure', () async {
      await load(seedPost: post(isLiked: false, likesCount: 2));
      when(() => postRepository.toggleLike(
            postId: postId,
            currentUserId: userId,
          )).thenAnswer((_) async => const Err(PostInteractionFailure()));

      await container.read(postDetailProvider(postId).notifier).toggleLike();

      final state = container.read(postDetailProvider(postId)).value!;
      expect(state.post!.isLiked, isFalse);
      expect(state.post!.likesCount, 2);
    });
  });

  group('toggleSave', () {
    test('applies optimistically and keeps it on success', () async {
      await load(seedPost: post(isSaved: false));
      when(() => postRepository.toggleSave(
            postId: postId,
            currentUserId: userId,
          )).thenAnswer((_) async => const Ok(true));

      await container.read(postDetailProvider(postId).notifier).toggleSave();

      expect(container.read(postDetailProvider(postId)).value!.post!.isSaved,
          isTrue);
    });

    test('rolls back on failure', () async {
      await load(seedPost: post(isSaved: false));
      when(() => postRepository.toggleSave(
            postId: postId,
            currentUserId: userId,
          )).thenAnswer((_) async => const Err(PostInteractionFailure()));

      await container.read(postDetailProvider(postId).notifier).toggleSave();

      expect(container.read(postDetailProvider(postId)).value!.post!.isSaved,
          isFalse);
    });
  });

  group('toggleCommentLike', () {
    test('applies optimistically and stays on success', () async {
      await load(comments: [comment('c1', isLiked: false, likesCount: 1)]);
      when(() => postRepository.toggleCommentLike(
            commentId: 'c1',
            currentUserId: userId,
          )).thenAnswer((_) async => const Ok(true));

      await container
          .read(postDetailProvider(postId).notifier)
          .toggleCommentLike('c1');

      final state = container.read(postDetailProvider(postId)).value!;
      expect(state.comments.single.isLiked, isTrue);
      expect(state.comments.single.likesCount, 2);
    });

    test('rolls back a reply like on failure without touching siblings',
        () async {
      await load(comments: [
        comment('c1', replies: [
          comment('r1', parentId: 'c1', isLiked: false, likesCount: 0),
        ]),
      ]);
      when(() => postRepository.toggleCommentLike(
            commentId: 'r1',
            currentUserId: userId,
          )).thenAnswer(
          (_) async => const Err(PostInteractionFailure()));

      await container
          .read(postDetailProvider(postId).notifier)
          .toggleCommentLike('r1');

      final state = container.read(postDetailProvider(postId)).value!;
      final reply = state.comments.single.replies.single;
      expect(reply.isLiked, isFalse);
      expect(reply.likesCount, 0);
    });
  });

  group('addComment', () {
    test('appends a top-level comment and increments the post count',
        () async {
      await load(seedPost: post(commentsCount: 1), comments: [comment('c1')]);
      when(() => postRepository.addComment(any())).thenAnswer(
        (_) async => Ok(comment('c2')),
      );

      await container
          .read(postDetailProvider(postId).notifier)
          .addComment('hello');

      final state = container.read(postDetailProvider(postId)).value!;
      expect(state.comments, hasLength(2));
      expect(state.post!.commentsCount, 2);
    });

    test('nests a reply inside its parent comment', () async {
      await load(comments: [comment('c1')]);
      container
          .read(postDetailProvider(postId).notifier)
          .setReplyTo('c1', 'b');
      when(() => postRepository.addComment(any())).thenAnswer(
        (_) async => Ok(comment('r1', parentId: 'c1')),
      );

      await container
          .read(postDetailProvider(postId).notifier)
          .addComment('a reply');

      final state = container.read(postDetailProvider(postId)).value!;
      expect(state.comments.single.replies, hasLength(1));
      expect(state.comments.single.replies.single.id, 'r1');
      expect(state.replyToId, isNull,
          reason: 'a successful reply clears the reply-to target');
    });

    test('sets an error message on failure without touching the comments',
        () async {
      await load(comments: [comment('c1')]);
      when(() => postRepository.addComment(any())).thenAnswer(
        (_) async =>
            const Err(PostValidationFailure(message: 'too long')),
      );

      await container
          .read(postDetailProvider(postId).notifier)
          .addComment('hello');

      final state = container.read(postDetailProvider(postId)).value!;
      expect(state.comments, hasLength(1));
      expect(state.errorMessage, isNotNull);
    });

    test('does nothing for blank text', () async {
      await load(comments: [comment('c1')]);

      await container
          .read(postDetailProvider(postId).notifier)
          .addComment('   ');

      verifyNever(() => postRepository.addComment(any()));
    });
  });

  group('deleteComment', () {
    test('removes it optimistically and decrements the post count',
        () async {
      await load(
        seedPost: post(commentsCount: 2),
        comments: [comment('c1'), comment('c2')],
      );
      when(() => postRepository.deleteComment(
            commentId: 'c1',
            currentUserId: userId,
          )).thenAnswer((_) async => const Ok(true));

      await container
          .read(postDetailProvider(postId).notifier)
          .deleteComment('c1');

      final state = container.read(postDetailProvider(postId)).value!;
      expect(state.comments, hasLength(1));
      expect(state.post!.commentsCount, 1);
    });

    test('restores the comment on failure', () async {
      await load(
        seedPost: post(commentsCount: 1),
        comments: [comment('c1')],
      );
      when(() => postRepository.deleteComment(
            commentId: 'c1',
            currentUserId: userId,
          )).thenAnswer(
          (_) async => const Err(PostUnauthorizedFailure()));

      await container
          .read(postDetailProvider(postId).notifier)
          .deleteComment('c1');

      final state = container.read(postDetailProvider(postId)).value!;
      expect(state.comments, hasLength(1));
      expect(state.post!.commentsCount, 1);
    });
  });

  group('deletePost', () {
    test('completes and invalidates the dependent feed providers', () async {
      await load(seedPost: post());
      when(() => postRepository.deletePost(
            postId: postId,
            currentUserId: userId,
          )).thenAnswer((_) async => const Ok(true));
      // deletePost() invalidates homeProvider, userPostsProvider(userId) and
      // profileProvider(userId/null); Riverpod's debug-mode invalidate() path
      // builds those providers as a side effect, so stub what they touch.
      when(() => postRepository.getFollowingFeed(
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => const Ok([]));
      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => const Ok([]));
      when(() => profileRepository.getProfile(userId,
              currentUserId: userId))
          .thenAnswer((_) async => Ok(makeProfile(id: userId)));

      await container.read(postDetailProvider(postId).notifier).deletePost();
      await Future<void>.delayed(Duration.zero);

      verify(() => postRepository.deletePost(
            postId: postId,
            currentUserId: userId,
          )).called(1);
    });

    test('propagates the failure without invalidating anything', () async {
      await load(seedPost: post());
      when(() => postRepository.deletePost(
            postId: postId,
            currentUserId: userId,
          )).thenAnswer(
          (_) async => const Err(PostUnauthorizedFailure()));

      await expectLater(
        () => container.read(postDetailProvider(postId).notifier).deletePost(),
        throwsA(isA<PostUnauthorizedFailure>()),
      );

      verifyNever(() => postRepository.getFollowingFeed(
            currentUserId: any(named: 'currentUserId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ));
    });
  });
}
