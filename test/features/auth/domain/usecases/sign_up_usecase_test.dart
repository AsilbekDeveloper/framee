import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/auth/domain/entities/auth_user.dart';
import 'package:framee/features/auth/domain/failures/auth_failure.dart';
import 'package:framee/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late SignUpUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignUpUseCase(repository);
  });

  group('SignUpUseCase', () {
    test('returns EmptyFieldsFailure when full name is empty', () async {
      final result = await useCase.call(
        fullName: '   ',
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect((result as Err).failure, isA<EmptyFieldsFailure>());
    });

    test('returns InvalidEmailFailure for a malformed address', () async {
      final result = await useCase.call(
        fullName: 'Test User',
        email: 'bad-email',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect((result as Err).failure, isA<InvalidEmailFailure>());
    });

    test('returns PasswordMismatchFailure when passwords differ', () async {
      final result = await useCase.call(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'different123',
      );

      expect((result as Err).failure, isA<PasswordMismatchFailure>());
    });

    test('returns WeakPasswordFailure below the minimum length', () async {
      final result = await useCase.call(
        fullName: 'Test User',
        email: 'test@example.com',
        password: '123',
        confirmPassword: '123',
      );

      expect((result as Err).failure, isA<WeakPasswordFailure>());
    });

    test('checks password match before length, matching validation order',
        () async {
      // A too-short password that also doesn't match should surface the
      // mismatch first — this pins the validation order the UI depends on.
      final result = await useCase.call(
        fullName: 'Test User',
        email: 'test@example.com',
        password: '123',
        confirmPassword: '456',
      );

      expect((result as Err).failure, isA<PasswordMismatchFailure>());
    });

    test('delegates to the repository with trimmed fields on success',
        () async {
      final user = makeAuthUser();
      when(() => repository.signUp(
            fullName: 'Test User',
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => Ok(user));

      final result = await useCase.call(
        fullName: '  Test User  ',
        email: '  test@example.com  ',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(result, isA<Ok<AuthUser?>>());
      verify(() => repository.signUp(
            fullName: 'Test User',
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    test('returns Ok(null) when email confirmation is pending', () async {
      when(() => repository.signUp(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Ok(null));

      final result = await useCase.call(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(result, isA<Ok<AuthUser?>>());
      expect((result as Ok).value, isNull);
    });
  });
}
