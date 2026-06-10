import '../../../../core/errors/result.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Foydalanuvchi profilini yuklaydi.
/// [userId] null bo'lsa joriy auth foydalanuvchisi profili qaytariladi.
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);
  final ProfileRepository _repository;

  Future<Result<Profile>> call(String userId, {String? currentUserId}) =>
      _repository.getProfile(userId, currentUserId: currentUserId);
}
