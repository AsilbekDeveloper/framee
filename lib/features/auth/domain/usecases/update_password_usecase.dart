import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/result.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  const UpdatePasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(String newPassword) {
    if (newPassword.length < AppConfig.minPasswordLength) {
      return Future.value(const Err(WeakPasswordFailure()));
    }
    return _repository.updatePassword(newPassword);
  }
}
