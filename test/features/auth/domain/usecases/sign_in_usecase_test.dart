import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/auth/domain/entities/auth_user.dart';
import 'package:framee/features/auth/domain/failures/auth_failure.dart';
import 'package:framee/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late SignInUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInUseCase(repository);
  });

  group('SignInUseCase', () {
    test('returns EmptyFieldsFailure when email is empty', () async {
      final result =
          await useCase.call(email: '', password: 'password123');

      expect(result, isA<Err<AuthUser>>());
      expect((result as Err).failure, isA<EmptyFieldsFailure>());
      verifyNever(() => repository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('returns EmptyFieldsFailure when password is empty', () async {
      final result =
          await useCase.call(email: 'test@example.com', password: '');

      expect((result as Err).failure, isA<EmptyFieldsFailure>());
    });

    test('returns InvalidEmailFailure for a malformed address', () async {
      final result =
          await useCase.call(email: 'not-an-email', password: 'password123');

      expect((result as Err).failure, isA<InvalidEmailFailure>());
      verifyNever(() => repository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('trims the email before validating and delegating', () async {
      final user = makeAuthUser(email: 'test@example.com');
      when(() => repository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => Ok(user));

      final result = await useCase.call(
        email: '  test@example.com  ',
        password: 'password123',
      );

      expect(result, isA<Ok<AuthUser>>());
      verify(() => repository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    test('propagates a failure from the repository', () async {
      when(() => repository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Err(InvalidCredentialsFailure()));

      final result = await useCase.call(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      expect((result as Err).failure, isA<InvalidCredentialsFailure>());
    });
  });
}
