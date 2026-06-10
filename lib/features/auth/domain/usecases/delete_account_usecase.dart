import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.deleteAccount();
}
