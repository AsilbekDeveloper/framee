import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/follow/data/providers/follow_data_providers.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/follow/domain/failures/follow_failure.dart';
import 'package:framee/features/post/data/providers/post_data_providers.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/failures/post_failure.dart';
import 'package:framee/features/search/data/providers/search_data_providers.dart';
import 'package:framee/features/search/domain/entities/search_result.dart';
import 'package:framee/features/search/domain/failures/search_failure.dart';
import 'package:framee/features/search/presentation/providers/search_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const userId = 'user-1';

  late MockSearchRepository searchRepository;
  late MockFollowRepository followRepository;
  late MockPostRepository postRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    searchRepository = MockSearchRepository();
    followRepository = MockFollowRepository();
    postRepository = MockPostRepository();

    when(() => searchRepository.getExplorePosts(
          currentUserId: any(named: 'currentUserId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => const Ok([]));

    container = ProviderContainer(overrides: [
      searchRepositoryProvider.overrideWithValue(searchRepository),
      followRepositoryProvider.overrideWithValue(followRepository),
      postRepositoryProvider.overrideWithValue(postRepository),
      currentUserIdProvider.overrideWithValue(userId),
    ]);
    addTearDown(container.dispose);
  });

  SearchUser searchUser(String id, {FollowStatus followStatus = FollowStatus.none}) =>
      SearchUser(id: id, username: 'u$id', displayName: 'U$id', followStatus: followStatus);

  Post post(String id, {bool isLiked = false, bool isSaved = false}) => Post(
        id: id,
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        createdAt: DateTime(2026, 1, 1),
        isLiked: isLiked,
        isSaved: isSaved,
      );

  test('loads explore posts shortly after build', () async {
    when(() => searchRepository.getExplorePosts(
          currentUserId: userId,
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => Ok([post('p1')]));

    container.read(searchProvider.notifier);
    expect(container.read(searchProvider).isLoadingExplore, isTrue);

    await Future<void>.delayed(Duration.zero);

    expect(container.read(searchProvider).explorePosts, hasLength(1));
    expect(container.read(searchProvider).isLoadingExplore, isFalse);
  });

  test('search sets the query immediately and debounces the request',
      () async {
    when(() => searchRepository.searchUsers(
          query: 'jane',
          currentUserId: userId,
        )).thenAnswer((_) async => Ok([searchUser('u1')]));

    final notifier = container.read(searchProvider.notifier);
    notifier.search('jane');

    expect(container.read(searchProvider).query, 'jane');
    expect(container.read(searchProvider).isSearching, isTrue);
    verifyNever(() => searchRepository.searchUsers(
          query: any(named: 'query'),
          currentUserId: any(named: 'currentUserId'),
        ));

    await Future<void>.delayed(const Duration(milliseconds: 450));

    expect(container.read(searchProvider).userResults, hasLength(1));
    expect(container.read(searchProvider).isSearching, isFalse);
  });

  test('search with blank text clears results without a network call',
      () async {
    final notifier = container.read(searchProvider.notifier);
    notifier.search('   ');

    expect(container.read(searchProvider).query, '');
    expect(container.read(searchProvider).isSearching, isFalse);
    verifyNever(() => searchRepository.searchUsers(
          query: any(named: 'query'),
          currentUserId: any(named: 'currentUserId'),
        ));
    // Flush the explore-load microtask scheduled by build() before teardown
    // disposes the container.
    await Future<void>.delayed(Duration.zero);
  });

  test('retrySearch re-runs the current query immediately', () async {
    when(() => searchRepository.searchUsers(
          query: any(named: 'query'),
          currentUserId: userId,
        )).thenAnswer((_) async => const Err(EmptyQueryFailure()));

    final notifier = container.read(searchProvider.notifier);
    notifier.search('ab');
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(container.read(searchProvider).errorMessage, isNotNull);

    when(() => searchRepository.searchUsers(
          query: any(named: 'query'),
          currentUserId: userId,
        )).thenAnswer((_) async => Ok([searchUser('u1')]));
    notifier.retrySearch();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(searchProvider).userResults, hasLength(1));
    expect(container.read(searchProvider).errorMessage, isNull);
  });

  test('clearSearch resets the query and results', () async {
    when(() => searchRepository.searchUsers(
          query: any(named: 'query'),
          currentUserId: userId,
        )).thenAnswer((_) async => Ok([searchUser('u1')]));
    final notifier = container.read(searchProvider.notifier);
    notifier.search('jane');
    await Future<void>.delayed(const Duration(milliseconds: 450));

    notifier.clearSearch();

    expect(container.read(searchProvider).query, '');
    expect(container.read(searchProvider).userResults, isEmpty);
  });

  group('toggleFollow', () {
    test('follows and patches the user result on success', () async {
      when(() => searchRepository.searchUsers(
            query: any(named: 'query'),
            currentUserId: userId,
          )).thenAnswer((_) async => Ok([searchUser('u1')]));
      final notifier = container.read(searchProvider.notifier);
      notifier.search('jane');
      await Future<void>.delayed(const Duration(milliseconds: 450));

      when(() => followRepository.followUser(
            currentUserId: userId,
            targetUserId: 'u1',
          )).thenAnswer((_) async => const Ok(FollowStatus.following));

      await notifier.toggleFollow('u1');

      expect(container.read(searchProvider).userResults.single.followStatus,
          FollowStatus.following);
    });

    test('rolls back on failure', () async {
      when(() => searchRepository.searchUsers(
            query: any(named: 'query'),
            currentUserId: userId,
          )).thenAnswer((_) async => Ok([searchUser('u1')]));
      final notifier = container.read(searchProvider.notifier);
      notifier.search('jane');
      await Future<void>.delayed(const Duration(milliseconds: 450));

      when(() => followRepository.followUser(
            currentUserId: userId,
            targetUserId: 'u1',
          )).thenAnswer(
          (_) async => const Err(FollowOperationFailure()));

      await notifier.toggleFollow('u1');

      expect(container.read(searchProvider).userResults.single.followStatus,
          FollowStatus.none);
    });
  });

  group('explore post like/save', () {
    test('toggleLike applies the server-confirmed value on success',
        () async {
      when(() => searchRepository.getExplorePosts(
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('p1')]));
      final notifier = container.read(searchProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      when(() => postRepository.toggleLike(
            postId: 'p1',
            currentUserId: userId,
          )).thenAnswer((_) async => const Ok((likesCount: 5, isLiked: true)));

      await notifier.toggleLike('p1');

      final patched = container.read(searchProvider).explorePosts.single;
      expect(patched.isLiked, isTrue);
      expect(patched.likesCount, 5);
    });

    test('toggleSave rolls back on failure', () async {
      when(() => searchRepository.getExplorePosts(
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('p1', isSaved: false)]));
      final notifier = container.read(searchProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      when(() => postRepository.toggleSave(
            postId: 'p1',
            currentUserId: userId,
          )).thenAnswer(
          (_) async => const Err(PostInteractionFailure()));

      await notifier.toggleSave('p1');

      expect(container.read(searchProvider).explorePosts.single.isSaved,
          isFalse);
    });
  });
}
