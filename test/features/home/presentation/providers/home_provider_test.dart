import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/home/presentation/providers/home_provider.dart';
import 'package:framee/features/post/data/providers/post_data_providers.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/failures/post_failure.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockPostRepository postRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    postRepository = MockPostRepository();
    container = ProviderContainer(overrides: [
      currentUserIdProvider.overrideWithValue('user-1'),
      postRepositoryProvider.overrideWithValue(postRepository),
    ]);
    addTearDown(container.dispose);
  });

  Post post({bool isLiked = false, int likesCount = 2}) => Post(
        id: 'post-1',
        author: const PostAuthor(
            id: 'author-1', username: 'a', displayName: 'A'),
        createdAt: DateTime(2026, 1, 1),
        isLiked: isLiked,
        likesCount: likesCount,
      );

  test('toggleLike applies the server-confirmed value on success', () async {
    when(() => postRepository.getFollowingFeed(
          currentUserId: 'user-1',
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => Ok([post()]));
    when(() => postRepository.toggleLike(
          postId: 'post-1',
          currentUserId: 'user-1',
        )).thenAnswer((_) async => const Ok((likesCount: 3, isLiked: true)));

    await container.read(homeProvider.future);
    await container.read(homeProvider.notifier).toggleLike('post-1');

    final state = container.read(homeProvider).value!;
    expect(state.posts.single.isLiked, isTrue);
    expect(state.posts.single.likesCount, 3);
  });

  test('toggleLike rolls back to the original values on failure', () async {
    when(() => postRepository.getFollowingFeed(
          currentUserId: 'user-1',
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => Ok([post(isLiked: false, likesCount: 2)]));
    when(() => postRepository.toggleLike(
          postId: 'post-1',
          currentUserId: 'user-1',
        )).thenAnswer(
        (_) async => const Err(PostInteractionFailure()));

    await container.read(homeProvider.future);
    await container.read(homeProvider.notifier).toggleLike('post-1');

    final state = container.read(homeProvider).value!;
    expect(state.posts.single.isLiked, isFalse);
    expect(state.posts.single.likesCount, 2);
  });

  test('deletePost removes it optimistically and restores it on failure',
      () async {
    when(() => postRepository.getFollowingFeed(
          currentUserId: 'user-1',
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => Ok([post()]));
    when(() => postRepository.deletePost(
          postId: 'post-1',
          currentUserId: 'user-1',
        )).thenAnswer(
        (_) async => const Err(PostUnauthorizedFailure()));

    await container.read(homeProvider.future);
    final notifier = container.read(homeProvider.notifier);

    await expectLater(
      () => notifier.deletePost('post-1'),
      throwsA(isA<PostUnauthorizedFailure>()),
    );

    final state = container.read(homeProvider).value!;
    expect(state.posts, hasLength(1),
        reason: 'the post should be restored after the server rejects the delete');
  });
}
