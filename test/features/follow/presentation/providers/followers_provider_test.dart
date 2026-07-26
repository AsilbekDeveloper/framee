import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/follow/data/providers/follow_data_providers.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/follow/domain/failures/follow_failure.dart';
import 'package:framee/features/profile/presentation/providers/followers_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const viewerId = 'viewer-1';
  const targetId = 'target-1';

  late MockFollowRepository followRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    followRepository = MockFollowRepository();
    container = ProviderContainer(overrides: [
      followRepositoryProvider.overrideWithValue(followRepository),
      currentUserIdProvider.overrideWithValue(viewerId),
    ]);
    addTearDown(container.dispose);
  });

  FollowUser user(String id, {FollowStatus followStatus = FollowStatus.none}) =>
      FollowUser(
        id: id,
        username: 'u$id',
        displayName: 'U$id',
        followStatus: followStatus,
      );

  Future<FollowersState> load({
    List<FollowUser> followers = const [],
    List<FollowUser> following = const [],
  }) async {
    when(() => followRepository.getFollowers(
          userId: targetId,
          currentUserId: viewerId,
        )).thenAnswer((_) async => Ok(followers));
    when(() => followRepository.getFollowing(
          userId: targetId,
          currentUserId: viewerId,
        )).thenAnswer((_) async => Ok(following));
    return container.read(followersProvider(targetId).future);
  }

  test('build loads followers and following lists', () async {
    final state = await load(
      followers: [user('f1')],
      following: [user('g1'), user('g2')],
    );

    expect(state.followers, hasLength(1));
    expect(state.following, hasLength(2));
  });

  group('toggleFollow — in the followers list', () {
    test('follows and applies the server-confirmed status on success',
        () async {
      await load(followers: [user('f1')]);
      when(() => followRepository.followUser(
            currentUserId: viewerId,
            targetUserId: 'f1',
          )).thenAnswer((_) async => const Ok(FollowStatus.following));

      await container
          .read(followersProvider(targetId).notifier)
          .toggleFollow('f1', isFollowers: true);

      final state = container.read(followersProvider(targetId)).value!;
      expect(state.followers.single.followStatus, FollowStatus.following);
    });

    test('reverts to the original status on failure', () async {
      await load(followers: [user('f1')]);
      when(() => followRepository.followUser(
            currentUserId: viewerId,
            targetUserId: 'f1',
          )).thenAnswer(
          (_) async => const Err(FollowOperationFailure()));

      await container
          .read(followersProvider(targetId).notifier)
          .toggleFollow('f1', isFollowers: true);

      final state = container.read(followersProvider(targetId)).value!;
      expect(state.followers.single.followStatus, FollowStatus.none);
    });
  });

  group('toggleFollow — in the following list', () {
    test('unfollows on success and leaves the followers list untouched',
        () async {
      await load(
        followers: [user('f1', followStatus: FollowStatus.following)],
        following: [user('g1', followStatus: FollowStatus.following)],
      );
      when(() => followRepository.unfollowUser(
            currentUserId: viewerId,
            targetUserId: 'g1',
          )).thenAnswer((_) async => const Ok(true));

      await container
          .read(followersProvider(targetId).notifier)
          .toggleFollow('g1', isFollowers: false);

      final state = container.read(followersProvider(targetId)).value!;
      expect(state.following.single.followStatus, FollowStatus.none);
      expect(state.followers.single.followStatus, FollowStatus.following,
          reason: 'toggling in the following list must not touch followers');
    });

    test('reverts to the original status on failure', () async {
      await load(following: [user('g1', followStatus: FollowStatus.following)]);
      when(() => followRepository.unfollowUser(
            currentUserId: viewerId,
            targetUserId: 'g1',
          )).thenAnswer(
          (_) async => const Err(FollowOperationFailure()));

      await container
          .read(followersProvider(targetId).notifier)
          .toggleFollow('g1', isFollowers: false);

      final state = container.read(followersProvider(targetId)).value!;
      expect(state.following.single.followStatus, FollowStatus.following);
    });
  });

  test('toggleFollow is a no-op for a user not present in the list',
      () async {
    await load(followers: [user('f1')]);

    await container
        .read(followersProvider(targetId).notifier)
        .toggleFollow('missing', isFollowers: true);

    verifyNever(() => followRepository.followUser(
          currentUserId: any(named: 'currentUserId'),
          targetUserId: any(named: 'targetUserId'),
        ));
  });
}
