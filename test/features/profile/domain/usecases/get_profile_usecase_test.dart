import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/profile/domain/failures/profile_failure.dart';
import 'package:framee/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProfileRepository repository;
  late GetProfileUseCase useCase;

  setUp(() {
    repository = MockProfileRepository();
    useCase = GetProfileUseCase(repository);
  });

  test('delegates to ProfileRepository.getProfile with the viewer id',
      () async {
    final profile = makeProfile();
    when(() => repository.getProfile('user-1', currentUserId: 'viewer-1'))
        .thenAnswer((_) async => Ok(profile));

    final result =
        await useCase.call('user-1', currentUserId: 'viewer-1');

    expect((result as Ok).value, profile);
  });

  test('propagates a not-found failure', () async {
    when(() => repository.getProfile(
          any(),
          currentUserId: any(named: 'currentUserId'),
        )).thenAnswer((_) async => const Err(ProfileNotFoundFailure()));

    final result = await useCase.call('missing-user');

    expect((result as Err).failure, isA<ProfileNotFoundFailure>());
  });
}
