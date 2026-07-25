import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/auth/domain/failures/auth_failure.dart';
import 'package:framee/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late SendPasswordResetUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SendPasswordResetUseCase(repository);
  });

  group('SendPasswordResetUseCase', () {
    test('returns EmptyFieldsFailure for a blank email', () async {
      final result = await useCase.call('   ');

      expect((result as Err).failure, isA<EmptyFieldsFailure>());
      verifyNever(() => repository.sendPasswordResetEmail(any()));
    });

    test('trims the email before delegating', () async {
      when(() => repository.sendPasswordResetEmail('test@example.com'))
          .thenAnswer((_) async => const Ok(null));

      final result = await useCase.call('  test@example.com  ');

      expect(result, isA<Ok<void>>());
      verify(() => repository.sendPasswordResetEmail('test@example.com'))
          .called(1);
    });
  });
}
