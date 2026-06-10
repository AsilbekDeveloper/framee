import '../../../../core/errors/result.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(String email) {
    if (email.trim().isEmpty) {
      return Future.value(const Err(EmptyFieldsFailure()));
    }
    return _repository.sendPasswordResetEmail(email.trim());
  }
}
