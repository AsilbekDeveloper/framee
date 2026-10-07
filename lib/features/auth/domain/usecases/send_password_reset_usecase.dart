import '../../../../core/errors/result.dart';
import '../../../../core/extensions/extensions.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(String email) {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return Future.value(const Err(EmptyFieldsFailure()));
    }
    if (!trimmedEmail.isValidEmail) {
      return Future.value(const Err(InvalidEmailFailure()));
    }
    return _repository.sendPasswordResetEmail(trimmedEmail);
  }
}
