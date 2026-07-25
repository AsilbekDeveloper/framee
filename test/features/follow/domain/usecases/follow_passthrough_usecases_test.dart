// Covers follow use cases that add no logic of their own beyond delegating
// to the repository.
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/follow/domain/usecases/get_followers_usecase.dart';
import 'package:framee/features/follow/domain/usecases/get_following_usecase.dart';
import 'package:framee/features/follow/domain/usecases/unfollow_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFollowRepository repository;

  setUp(() {
    repository = MockFollowRepository();
  });

  test('UnfollowUserUseCase delegates to FollowRepository.unfollowUser',
      () async {
    when(() => repository.unfollowUser(
          currentUserId: 'user-1',
          targetUserId: 'user-2',
        )).thenAnswer((_) async => const Ok(true));

    final result = await UnfollowUserUseCase(repository)
        .call(currentUserId: 'user-1', targetUserId: 'user-2');

    expect((result as Ok).value, isTrue);
  });

  test('GetFollowersUseCase delegates to FollowRepository.getFollowers',
      () async {
    when(() => repository.getFollowers(
          userId: 'user-1',
          currentUserId: 'viewer-1',
        )).thenAnswer((_) async => const Ok(<FollowUser>[]));

    final result = await GetFollowersUseCase(repository)
        .call(userId: 'user-1', currentUserId: 'viewer-1');

    expect(result, isA<Ok<List<FollowUser>>>());
  });

  test('GetFollowingUseCase delegates to FollowRepository.getFollowing',
      () async {
    when(() => repository.getFollowing(
          userId: 'user-1',
          currentUserId: 'viewer-1',
        )).thenAnswer((_) async => const Ok(<FollowUser>[]));

    final result = await GetFollowingUseCase(repository)
        .call(userId: 'user-1', currentUserId: 'viewer-1');

    expect(result, isA<Ok<List<FollowUser>>>());
  });
}
