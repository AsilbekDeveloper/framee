// Covers post use cases that add no logic of their own beyond delegating to
// the repository — one confirmation test each pins the wiring without
// duplicating the repository's own behavior.
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/usecases/delete_comment_usecase.dart';
import 'package:framee/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:framee/features/post/domain/usecases/get_comments_usecase.dart';
import 'package:framee/features/post/domain/usecases/get_feed_usecase.dart';
import 'package:framee/features/post/domain/usecases/get_following_feed_usecase.dart';
import 'package:framee/features/post/domain/usecases/get_post_usecase.dart';
import 'package:framee/features/post/domain/usecases/get_saved_posts_usecase.dart';
import 'package:framee/features/post/domain/usecases/get_user_posts_usecase.dart';
import 'package:framee/features/post/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:framee/features/post/domain/usecases/toggle_like_usecase.dart';
import 'package:framee/features/post/domain/usecases/toggle_save_usecase.dart';
import 'package:framee/features/post/domain/usecases/update_post_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockPostRepository repository;

  setUpAll(registerFallbackValues);

  setUp(() {
    repository = MockPostRepository();
  });

  test('GetFeedUseCase delegates to PostRepository.getFeed', () async {
    when(() => repository.getFeed(currentUserId: 'user-1'))
        .thenAnswer((_) async => const Ok([]));

    final result = await GetFeedUseCase(repository)
        .call(currentUserId: 'user-1');

    expect(result, isA<Ok<List<Post>>>());
    verify(() => repository.getFeed(currentUserId: 'user-1')).called(1);
  });

  test('GetFollowingFeedUseCase delegates to PostRepository.getFollowingFeed',
      () async {
    when(() => repository.getFollowingFeed(currentUserId: 'user-1'))
        .thenAnswer((_) async => const Ok([]));

    final result = await GetFollowingFeedUseCase(repository)
        .call(currentUserId: 'user-1');

    expect(result, isA<Ok<List<Post>>>());
    verify(() => repository.getFollowingFeed(currentUserId: 'user-1'))
        .called(1);
  });

  test('GetPostUseCase delegates to PostRepository.getPost', () async {
    final post = Post(
      id: 'post-1',
      author:
          const PostAuthor(id: 'user-1', username: 'u', displayName: 'U'),
      createdAt: DateTime(2026, 1, 1),
    );
    when(() => repository.getPost(
          postId: 'post-1',
          currentUserId: 'user-1',
        )).thenAnswer((_) async => Ok(post));

    final result = await GetPostUseCase(repository)
        .call(postId: 'post-1', currentUserId: 'user-1');

    expect((result as Ok).value, post);
  });

  test('DeletePostUseCase delegates to PostRepository.deletePost', () async {
    when(() => repository.deletePost(
          postId: 'post-1',
          currentUserId: 'user-1',
        )).thenAnswer((_) async => const Ok(true));

    final result = await DeletePostUseCase(repository)
        .call(postId: 'post-1', currentUserId: 'user-1');

    expect((result as Ok).value, isTrue);
  });

  test('ToggleLikeUseCase delegates to PostRepository.toggleLike', () async {
    when(() => repository.toggleLike(
          postId: 'post-1',
          currentUserId: 'user-1',
        )).thenAnswer(
        (_) async => const Ok((likesCount: 5, isLiked: true)));

    final result = await ToggleLikeUseCase(repository)
        .call(postId: 'post-1', currentUserId: 'user-1');

    final value = (result as Ok).value;
    expect(value.likesCount, 5);
    expect(value.isLiked, isTrue);
  });

  test('ToggleSaveUseCase delegates to PostRepository.toggleSave', () async {
    when(() => repository.toggleSave(
          postId: 'post-1',
          currentUserId: 'user-1',
        )).thenAnswer((_) async => const Ok(true));

    final result = await ToggleSaveUseCase(repository)
        .call(postId: 'post-1', currentUserId: 'user-1');

    expect((result as Ok).value, isTrue);
  });

  test('GetCommentsUseCase delegates to PostRepository.getComments',
      () async {
    when(() => repository.getComments(
          postId: 'post-1',
          currentUserId: 'user-1',
        )).thenAnswer((_) async => const Ok([]));

    final result = await GetCommentsUseCase(repository)
        .call(postId: 'post-1', currentUserId: 'user-1');

    expect(result, isA<Ok<List<Comment>>>());
  });

  test('DeleteCommentUseCase delegates to PostRepository.deleteComment',
      () async {
    when(() => repository.deleteComment(
          commentId: 'comment-1',
          currentUserId: 'user-1',
        )).thenAnswer((_) async => const Ok(true));

    final result = await DeleteCommentUseCase(repository)
        .call(commentId: 'comment-1', currentUserId: 'user-1');

    expect((result as Ok).value, isTrue);
  });

  test(
      'ToggleCommentLikeUseCase delegates to PostRepository.toggleCommentLike',
      () async {
    when(() => repository.toggleCommentLike(
          commentId: 'comment-1',
          currentUserId: 'user-1',
        )).thenAnswer((_) async => const Ok(true));

    final result = await ToggleCommentLikeUseCase(repository)
        .call(commentId: 'comment-1', currentUserId: 'user-1');

    expect((result as Ok).value, isTrue);
  });

  test('GetUserPostsUseCase delegates to PostRepository.getUserPosts',
      () async {
    when(() => repository.getUserPosts(
          userId: 'user-1',
          currentUserId: 'user-2',
        )).thenAnswer((_) async => const Ok([]));

    final result = await GetUserPostsUseCase(repository)
        .call(userId: 'user-1', currentUserId: 'user-2');

    expect(result, isA<Ok<List<Post>>>());
  });

  test('GetSavedPostsUseCase delegates to PostRepository.getSavedPosts',
      () async {
    when(() => repository.getSavedPosts(userId: 'user-1'))
        .thenAnswer((_) async => const Ok([]));

    final result =
        await GetSavedPostsUseCase(repository).call(userId: 'user-1');

    expect(result, isA<Ok<List<Post>>>());
  });

  test('UpdatePostUseCase delegates to PostRepository.updatePost', () async {
    final post = Post(
      id: 'post-1',
      author:
          const PostAuthor(id: 'user-1', username: 'u', displayName: 'U'),
      createdAt: DateTime(2026, 1, 1),
    );
    const params = UpdatePostParams(postId: 'post-1', userId: 'user-1');
    when(() => repository.updatePost(params))
        .thenAnswer((_) async => Ok(post));

    final result = await UpdatePostUseCase(repository).call(params);

    expect((result as Ok).value, post);
  });
}
