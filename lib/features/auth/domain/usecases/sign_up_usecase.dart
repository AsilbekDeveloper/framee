import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthUser?>> call({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty) {
      return Future.value(const Err(EmptyFieldsFailure()));
    }
    if (password != confirmPassword) {
      return Future.value(const Err(PasswordMismatchFailure()));
    }
    if (password.length < 6) {
      return Future.value(const Err(WeakPasswordFailure()));
    }
    return _repository.signUp(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
    );
  }
}
