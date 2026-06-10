import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty || password.isEmpty) {
      return Future.value(const Err(EmptyFieldsFailure()));
    }
    return _repository.signIn(email: email.trim(), password: password);
  }
}
