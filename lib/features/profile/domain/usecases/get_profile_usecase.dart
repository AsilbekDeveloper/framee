import '../../../../core/errors/result.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Loads a user profile by ID.
/// Passes the [currentUserId] through so the repository can resolve the [isFollowing] flag.
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);
  final ProfileRepository _repository;

  Future<Result<Profile>> call(String userId, {String? currentUserId}) =>
      _repository.getProfile(userId, currentUserId: currentUserId);
}
