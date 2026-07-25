// Covers the auth use cases that add no logic of their own beyond
// delegating to the repository — one confirmation test each is enough to
// pin the wiring without duplicating the repository's own behavior.
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:framee/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:framee/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  test('SignOutUseCase delegates to AuthRepository.signOut', () async {
    when(() => repository.signOut()).thenAnswer((_) async => const Ok(null));

    final result = await SignOutUseCase(repository).call();

    expect(result, isA<Ok<void>>());
    verify(() => repository.signOut()).called(1);
  });

  test('SignInWithGoogleUseCase delegates to AuthRepository.signInWithGoogle',
      () async {
    when(() => repository.signInWithGoogle())
        .thenAnswer((_) async => const Ok(null));

    final result = await SignInWithGoogleUseCase(repository).call();

    expect(result, isA<Ok<void>>());
    verify(() => repository.signInWithGoogle()).called(1);
  });

  test('DeleteAccountUseCase delegates to AuthRepository.deleteAccount',
      () async {
    when(() => repository.deleteAccount())
        .thenAnswer((_) async => const Ok(null));

    final result = await DeleteAccountUseCase(repository).call();

    expect(result, isA<Ok<void>>());
    verify(() => repository.deleteAccount()).called(1);
  });
}
