import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/follow/domain/failures/follow_failure.dart';
import 'package:framee/features/follow/domain/usecases/follow_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFollowRepository repository;
  late FollowUserUseCase useCase;

  setUp(() {
    repository = MockFollowRepository();
    useCase = FollowUserUseCase(repository);
  });

  test('rejects following yourself', () async {
    final result =
        await useCase.call(currentUserId: 'user-1', targetUserId: 'user-1');

    expect((result as Err).failure, isA<CannotFollowSelfFailure>());
    verifyNever(() => repository.followUser(
          currentUserId: any(named: 'currentUserId'),
          targetUserId: any(named: 'targetUserId'),
        ));
  });

  test('delegates to the repository for a different user', () async {
    when(() => repository.followUser(
          currentUserId: 'user-1',
          targetUserId: 'user-2',
        )).thenAnswer((_) async => const Ok(FollowStatus.following));

    final result =
        await useCase.call(currentUserId: 'user-1', targetUserId: 'user-2');

    expect((result as Ok).value, FollowStatus.following);
  });

  test('returns "requested" for a private account', () async {
    when(() => repository.followUser(
          currentUserId: any(named: 'currentUserId'),
          targetUserId: any(named: 'targetUserId'),
        )).thenAnswer((_) async => const Ok(FollowStatus.requested));

    final result =
        await useCase.call(currentUserId: 'user-1', targetUserId: 'user-2');

    expect((result as Ok).value, FollowStatus.requested);
  });
}
