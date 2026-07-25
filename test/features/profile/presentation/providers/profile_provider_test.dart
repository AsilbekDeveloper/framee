import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/follow/data/providers/follow_data_providers.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/follow/domain/failures/follow_failure.dart';
import 'package:framee/features/profile/data/providers/profile_data_providers.dart';
import 'package:framee/features/profile/domain/entities/profile.dart';
import 'package:framee/features/profile/presentation/providers/profile_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const viewerId = 'viewer-1';
  const targetId = 'target-1';

  late MockProfileRepository profileRepository;
  late MockFollowRepository followRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    profileRepository = MockProfileRepository();
    followRepository = MockFollowRepository();

    container = ProviderContainer(overrides: [
      profileRepositoryProvider.overrideWithValue(profileRepository),
      followRepositoryProvider.overrideWithValue(followRepository),
      currentUserIdProvider.overrideWithValue(viewerId),
    ]);
    addTearDown(container.dispose);
  });

  Future<Profile> loadProfile(Profile profile) async {
    when(() => profileRepository.getProfile(targetId,
            currentUserId: viewerId))
        .thenAnswer((_) async => Ok(profile));
    return container.read(profileProvider(targetId).future);
  }

  test('build fetches the profile using the viewer id', () async {
    final profile = await loadProfile(makeProfile(id: targetId));

    expect(profile.id, targetId);
    verify(() => profileRepository.getProfile(targetId,
        currentUserId: viewerId)).called(1);
  });

  group('toggleFollow — following a public account', () {
    test('optimistically follows and keeps the result on success', () async {
      await loadProfile(makeProfile(id: targetId).copyWith(
        followersCount: 10,
      ));
      when(() => followRepository.followUser(
            currentUserId: viewerId,
            targetUserId: targetId,
          )).thenAnswer((_) async => const Ok(FollowStatus.following));

      await container.read(profileProvider(targetId).notifier).toggleFollow();

      final state = container.read(profileProvider(targetId)).value!;
      expect(state.isFollowing, isTrue);
      expect(state.isRequested, isFalse);
      expect(state.followersCount, 11);
    });

    test('corrects to a pending request when the account is private',
        () async {
      await loadProfile(makeProfile(id: targetId, isPrivate: true).copyWith(
        followersCount: 10,
      ));
      when(() => followRepository.followUser(
            currentUserId: viewerId,
            targetUserId: targetId,
          )).thenAnswer((_) async => const Ok(FollowStatus.requested));

      await container.read(profileProvider(targetId).notifier).toggleFollow();

      final state = container.read(profileProvider(targetId)).value!;
      expect(state.isFollowing, isFalse);
      expect(state.isRequested, isTrue);
    });

    test('rolls back to the original profile on failure', () async {
      final original = await loadProfile(makeProfile(id: targetId).copyWith(
        followersCount: 10,
      ));
      when(() => followRepository.followUser(
            currentUserId: viewerId,
            targetUserId: targetId,
          )).thenAnswer(
          (_) async => const Err(CannotFollowSelfFailure()));

      await container.read(profileProvider(targetId).notifier).toggleFollow();

      final state = container.read(profileProvider(targetId)).value!;
      expect(state.isFollowing, original.isFollowing);
      expect(state.followersCount, original.followersCount);
    });
  });

  group('toggleFollow — undoing an active follow or request', () {
    test('unfollows and decrements the follower count on success', () async {
      await loadProfile(makeProfile(id: targetId).copyWith(
        isFollowing: true,
        followersCount: 10,
      ));
      when(() => followRepository.unfollowUser(
            currentUserId: viewerId,
            targetUserId: targetId,
          )).thenAnswer((_) async => const Ok(true));

      await container.read(profileProvider(targetId).notifier).toggleFollow();

      final state = container.read(profileProvider(targetId)).value!;
      expect(state.isFollowing, isFalse);
      expect(state.followersCount, 9);
    });

    test('cancels a pending request without touching the follower count',
        () async {
      await loadProfile(makeProfile(id: targetId, isPrivate: true).copyWith(
        isRequested: true,
        followersCount: 10,
      ));
      when(() => followRepository.unfollowUser(
            currentUserId: viewerId,
            targetUserId: targetId,
          )).thenAnswer((_) async => const Ok(true));

      await container.read(profileProvider(targetId).notifier).toggleFollow();

      final state = container.read(profileProvider(targetId)).value!;
      expect(state.isRequested, isFalse);
      expect(state.followersCount, 10);
    });

    test('rolls back to the original profile on failure', () async {
      final original = await loadProfile(makeProfile(id: targetId).copyWith(
        isFollowing: true,
        followersCount: 10,
      ));
      when(() => followRepository.unfollowUser(
            currentUserId: viewerId,
            targetUserId: targetId,
          )).thenAnswer(
          (_) async => const Err(FollowOperationFailure()));

      await container.read(profileProvider(targetId).notifier).toggleFollow();

      final state = container.read(profileProvider(targetId)).value!;
      expect(state.isFollowing, original.isFollowing);
      expect(state.followersCount, original.followersCount);
    });
  });

  test('updateProfile overwrites the state directly', () async {
    final profile = await loadProfile(makeProfile(id: targetId));

    container
        .read(profileProvider(targetId).notifier)
        .updateProfile(profile.copyWith(displayName: 'New Name'));

    expect(container.read(profileProvider(targetId)).value!.displayName,
        'New Name');
  });
}
