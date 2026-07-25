import '../../../../core/errors/result.dart';
import '../../../../core/extensions/extensions.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Validates credentials client-side, then delegates to the repository.
class SignInUseCase {
  const SignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      return Future.value(const Err(EmptyFieldsFailure()));
    }
    // Catch a malformed address here so the user sees an instant, specific
    // message instead of waiting for the server to reject it as bad credentials.
    if (!trimmedEmail.isValidEmail) {
      return Future.value(const Err(InvalidEmailFailure()));
    }
    return _repository.signIn(email: trimmedEmail, password: password);
  }
}
