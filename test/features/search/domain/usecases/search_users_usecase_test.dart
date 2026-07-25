import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/search/domain/entities/search_result.dart';
import 'package:framee/features/search/domain/failures/search_failure.dart';
import 'package:framee/features/search/domain/usecases/search_users_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSearchRepository repository;
  late SearchUsersUseCase useCase;

  setUp(() {
    repository = MockSearchRepository();
    useCase = SearchUsersUseCase(repository);
  });

  test('rejects an empty query without hitting the repository', () async {
    final result =
        await useCase.call(query: '   ', currentUserId: 'user-1');

    expect((result as Err).failure, isA<EmptyQueryFailure>());
    verifyNever(() => repository.searchUsers(
          query: any(named: 'query'),
          currentUserId: any(named: 'currentUserId'),
        ));
  });

  test('trims the query before delegating', () async {
    const user = SearchUser(
      id: 'user-2',
      username: 'jane',
      displayName: 'Jane',
      followStatus: FollowStatus.none,
    );
    when(() => repository.searchUsers(
          query: 'jane',
          currentUserId: 'user-1',
        )).thenAnswer((_) async => const Ok([user]));

    final result =
        await useCase.call(query: '  jane  ', currentUserId: 'user-1');

    expect((result as Ok).value, [user]);
    verify(() => repository.searchUsers(
          query: 'jane',
          currentUserId: 'user-1',
        )).called(1);
  });
}
