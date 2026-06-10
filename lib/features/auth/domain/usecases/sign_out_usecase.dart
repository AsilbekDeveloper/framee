import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}
