import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/failure.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/profile/domain/entities/profile.dart';
import 'package:framee/features/profile/domain/failures/profile_failure.dart';
import 'package:framee/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProfileRepository repository;
  late UpdateProfileUseCase useCase;

  setUpAll(registerFallbackValues);

  setUp(() {
    repository = MockProfileRepository();
    useCase = UpdateProfileUseCase(repository);
  });

  group('UpdateProfileUseCase', () {
    test('rejects an empty username', () async {
      final result = await useCase.call(const UpdateProfileParams(
        userId: 'user-1',
        username: '',
        displayName: 'Test User',
      ));

      expect((result as Err).failure, isA<ValidationFailure>());
      verifyNever(() => repository.isUsernameAvailable(
            any(),
            excludeUserId: any(named: 'excludeUserId'),
          ));
    });

    test('rejects an empty display name', () async {
      final result = await useCase.call(const UpdateProfileParams(
        userId: 'user-1',
        username: 'testuser',
        displayName: '',
      ));

      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('rejects a username with invalid characters', () async {
      final result = await useCase.call(const UpdateProfileParams(
        userId: 'user-1',
        username: 'invalid username!',
        displayName: 'Test User',
      ));

      expect((result as Err).failure, isA<InvalidUsernameFailure>());
    });

    test('rejects a username shorter than 3 characters', () async {
      final result = await useCase.call(const UpdateProfileParams(
        userId: 'user-1',
        username: 'ab',
        displayName: 'Test User',
      ));

      expect((result as Err).failure, isA<InvalidUsernameFailure>());
    });

    test('rejects a taken username', () async {
      when(() => repository.isUsernameAvailable(
            'testuser',
            excludeUserId: 'user-1',
          )).thenAnswer((_) async => const Ok(false));

      final result = await useCase.call(const UpdateProfileParams(
        userId: 'user-1',
        username: 'testuser',
        displayName: 'Test User',
      ));

      expect((result as Err).failure, isA<UsernameAlreadyTakenFailure>());
      verifyNever(() => repository.updateProfile(any()));
    });

    test('excludes the current user when checking availability, so '
        're-saving the same username succeeds', () async {
      when(() => repository.isUsernameAvailable(
            'testuser',
            excludeUserId: 'user-1',
          )).thenAnswer((_) async => const Ok(true));
      when(() => repository.updateProfile(any()))
          .thenAnswer((_) async => Ok(makeProfile()));

      final result = await useCase.call(const UpdateProfileParams(
        userId: 'user-1',
        username: 'testuser',
        displayName: 'Test User',
      ));

      expect(result, isA<Ok<Profile>>());
    });

    test('proceeds to save when the availability check errors — the '
        'server has the final say', () async {
      when(() => repository.isUsernameAvailable(
            any(),
            excludeUserId: any(named: 'excludeUserId'),
          )).thenAnswer((_) async => const Err(ProfileNotFoundFailure()));
      when(() => repository.updateProfile(any()))
          .thenAnswer((_) async => Ok(makeProfile()));

      final result = await useCase.call(const UpdateProfileParams(
        userId: 'user-1',
        username: 'testuser',
        displayName: 'Test User',
      ));

      expect(result, isA<Ok<Profile>>());
      verify(() => repository.updateProfile(any())).called(1);
    });
  });
}
