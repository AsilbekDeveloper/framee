import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/post/data/providers/post_data_providers.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/failures/post_failure.dart';
import 'package:framee/features/profile/presentation/providers/user_posts_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const userId = 'user-1';

  late MockPostRepository postRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  Post post(String id, {bool isLiked = false, bool isSaved = false}) => Post(
        id: id,
        author: const PostAuthor(id: userId, username: 'a', displayName: 'A'),
        createdAt: DateTime(2026, 1, 1),
        isLiked: isLiked,
        isSaved: isSaved,
      );

  void makeContainer() {
    postRepository = MockPostRepository();
    container = ProviderContainer(overrides: [
      postRepositoryProvider.overrideWithValue(postRepository),
      currentUserIdProvider.overrideWithValue(userId),
    ]);
    addTearDown(container.dispose);
  }

  group('with an empty cache', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      makeContainer();
    });

    test('build fetches from the repository and saves to the cache',
        () async {
      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('p1')]));

      final posts = await container.read(userPostsProvider(userId).future);

      expect(posts, hasLength(1));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('post_cache_user_$userId'), isNotNull);
    });

    test('toggleLike applies the server-confirmed value on success',
        () async {
      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('p1')]));
      await container.read(userPostsProvider(userId).future);
      when(() => postRepository.toggleLike(
            postId: 'p1',
            currentUserId: userId,
          )).thenAnswer((_) async => const Ok((likesCount: 1, isLiked: true)));

      await container
          .read(userPostsProvider(userId).notifier)
          .toggleLike(post('p1'));

      expect(container.read(userPostsProvider(userId)).value!.single.isLiked,
          isTrue);
    });

    test('toggleSave rolls back on failure', () async {
      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('p1', isSaved: false)]));
      await container.read(userPostsProvider(userId).future);
      when(() => postRepository.toggleSave(
            postId: 'p1',
            currentUserId: userId,
          )).thenAnswer(
          (_) async => const Err(PostInteractionFailure()));

      await container
          .read(userPostsProvider(userId).notifier)
          .toggleSave(post('p1', isSaved: false));

      expect(container.read(userPostsProvider(userId)).value!.single.isSaved,
          isFalse);
    });

    test('refresh replaces the list on success', () async {
      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('p1')]));
      await container.read(userPostsProvider(userId).future);

      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('p1'), post('p2')]));

      await container.read(userPostsProvider(userId).notifier).refresh();

      expect(container.read(userPostsProvider(userId)).value, hasLength(2));
    });

    test('refresh keeps the existing value when the server call fails',
        () async {
      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('p1')]));
      await container.read(userPostsProvider(userId).future);

      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer(
          (_) async => const Err(PostNotFoundFailure()));

      await container.read(userPostsProvider(userId).notifier).refresh();

      expect(container.read(userPostsProvider(userId)).value, hasLength(1),
          reason: 'a failed refresh must not wipe out already-loaded posts');
    });
  });

  group('with a warm cache', () {
    test('build returns the cached posts immediately, then refreshes',
        () async {
      SharedPreferences.setMockInitialValues({
        'post_cache_user_$userId':
            jsonEncode([post('cached').toJson()]),
      });
      makeContainer();
      when(() => postRepository.getUserPosts(
            userId: userId,
            currentUserId: userId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Ok([post('fresh')]));

      final posts = await container.read(userPostsProvider(userId).future);
      expect(posts.single.id, 'cached');

      await Future<void>.delayed(Duration.zero);

      expect(container.read(userPostsProvider(userId)).value!.single.id,
          'fresh',
          reason: 'the background refresh should replace the cached list');
    });
  });
}
