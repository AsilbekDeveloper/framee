import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/auth/domain/failures/auth_failure.dart';
import 'package:framee/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late UpdatePasswordUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = UpdatePasswordUseCase(repository);
  });

  group('UpdatePasswordUseCase', () {
    test('returns WeakPasswordFailure below the minimum length', () async {
      final result = await useCase.call('12345');

      expect((result as Err).failure, isA<WeakPasswordFailure>());
      verifyNever(() => repository.updatePassword(any()));
    });

    test('delegates to the repository at the minimum length', () async {
      when(() => repository.updatePassword('123456'))
          .thenAnswer((_) async => const Ok(null));

      final result = await useCase.call('123456');

      expect(result, isA<Ok<void>>());
      verify(() => repository.updatePassword('123456')).called(1);
    });

    test('propagates a failure from the repository', () async {
      when(() => repository.updatePassword(any())).thenAnswer(
          (_) async => const Err(UnknownAuthFailure(message: 'boom')));

      final result = await useCase.call('longenoughpassword');

      expect((result as Err).failure, isA<UnknownAuthFailure>());
    });
  });
}
