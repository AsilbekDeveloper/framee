import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/extensions/extensions.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Validates all sign-up fields client-side before calling the repository.
class SignUpUseCase {
  const SignUpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthUser?>> call({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final trimmedEmail = email.trim();
    if (fullName.trim().isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      return Future.value(const Err(EmptyFieldsFailure()));
    }
    if (!trimmedEmail.isValidEmail) {
      return Future.value(const Err(InvalidEmailFailure()));
    }
    if (password != confirmPassword) {
      return Future.value(const Err(PasswordMismatchFailure()));
    }
    // Single source of truth for the minimum — the same constant the server and
    // the password-change flow enforce, so the three never drift apart.
    if (password.length < AppConfig.minPasswordLength) {
      return Future.value(const Err(WeakPasswordFailure()));
    }
    return _repository.signUp(
      fullName: fullName.trim(),
      email: trimmedEmail,
      password: password,
    );
  }
}
