import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/post/data/providers/post_data_providers.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/failures/post_failure.dart';
import 'package:framee/features/search/presentation/providers/explore_feed_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const userId = 'user-1';
  const tappedId = 'tapped-1';

  late MockPostRepository postRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    postRepository = MockPostRepository();
    container = ProviderContainer(overrides: [
      postRepositoryProvider.overrideWithValue(postRepository),
      currentUserIdProvider.overrideWithValue(userId),
    ]);
    addTearDown(container.dispose);
  });

  Post post(String id, {bool isLiked = false, bool isSaved = false}) => Post(
        id: id,
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        createdAt: DateTime(2026, 1, 1),
        isLiked: isLiked,
        isSaved: isSaved,
      );

  void stubGetPost(Result<Post> result) => when(() => postRepository.getPost(
        postId: tappedId,
        currentUserId: userId,
      )).thenAnswer((_) async => result);

  void stubGetFeed(Result<List<Post>> result, {int offset = 0}) =>
      when(() => postRepository.getFeed(
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: offset,
          )).thenAnswer((_) async => result);

  test('build puts the tapped post first and drops the duplicate from the feed',
      () async {
    stubGetPost(Ok(post(tappedId)));
    stubGetFeed(Ok([post(tappedId), post('p2')]));

    final state = await container.read(exploreFeedProvider(tappedId).future);

    expect(state.posts.map((p) => p.id), [tappedId, 'p2']);
  });

  test('build still shows the feed when the tapped post fails to load',
      () async {
    stubGetPost(const Err(PostNotFoundFailure()));
    stubGetFeed(Ok([post('p1'), post('p2')]));

    final state = await container.read(exploreFeedProvider(tappedId).future);

    expect(state.posts.map((p) => p.id), ['p1', 'p2']);
  });

  test('loadMore appends new posts and de-duplicates by id', () async {
    stubGetPost(Ok(post(tappedId)));
    stubGetFeed(Ok(List.generate(20, (i) => post('p$i'))));
    await container.read(exploreFeedProvider(tappedId).future);

    stubGetFeed(Ok([post('p0'), post('p20')]), offset: 20);

    await container.read(exploreFeedProvider(tappedId).notifier).loadMore();

    final state = container.read(exploreFeedProvider(tappedId)).value!;
    expect(state.posts.map((p) => p.id), contains('p20'));
    expect(state.posts.where((p) => p.id == 'p0'), hasLength(1),
        reason: 'a post already present must not be duplicated');
  });

  test('loadMore is a no-op once hasMore is false', () async {
    stubGetPost(Ok(post(tappedId)));
    stubGetFeed(Ok([post('p1')])); // fewer than a full page → hasMore=false
    await container.read(exploreFeedProvider(tappedId).future);

    await container.read(exploreFeedProvider(tappedId).notifier).loadMore();

    verifyNever(() => postRepository.getFeed(
          currentUserId: userId,
          limit: any(named: 'limit'),
          offset: 1,
        ));
  });

  group('toggleLike', () {
    test('applies the server-confirmed value on success', () async {
      stubGetPost(Ok(post(tappedId)));
      stubGetFeed(Ok([post(tappedId)]));
      await container.read(exploreFeedProvider(tappedId).future);
      when(() => postRepository.toggleLike(
            postId: tappedId,
            currentUserId: userId,
          )).thenAnswer((_) async => const Ok((likesCount: 4, isLiked: true)));

      await container
          .read(exploreFeedProvider(tappedId).notifier)
          .toggleLike(tappedId);

      final patched = container.read(exploreFeedProvider(tappedId)).value!.posts.single;
      expect(patched.isLiked, isTrue);
      expect(patched.likesCount, 4);
    });

    test('rolls back on failure', () async {
      stubGetPost(Ok(post(tappedId)));
      stubGetFeed(Ok([post(tappedId)]));
      await container.read(exploreFeedProvider(tappedId).future);
      when(() => postRepository.toggleLike(
            postId: tappedId,
            currentUserId: userId,
          )).thenAnswer((_) async => const Err(PostInteractionFailure()));

      await container
          .read(exploreFeedProvider(tappedId).notifier)
          .toggleLike(tappedId);

      final patched = container.read(exploreFeedProvider(tappedId)).value!.posts.single;
      expect(patched.isLiked, isFalse);
    });
  });

  test('refresh reloads the feed from the start', () async {
    stubGetPost(Ok(post(tappedId)));
    stubGetFeed(Ok(List.generate(20, (i) => post('p$i'))));
    await container.read(exploreFeedProvider(tappedId).future);
    stubGetFeed(Ok([post('p0')]), offset: 20);
    await container.read(exploreFeedProvider(tappedId).notifier).loadMore();

    stubGetFeed(Ok([post('fresh')]));
    await container.read(exploreFeedProvider(tappedId).notifier).refresh();

    final state = container.read(exploreFeedProvider(tappedId)).value!;
    expect(state.posts.map((p) => p.id), [tappedId, 'fresh']);
  });
}
