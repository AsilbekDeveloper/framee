import '../../../../core/errors/result.dart';
import '../repositories/follow_repository.dart';

class UnfollowUserUseCase {
  const UnfollowUserUseCase(this._repository);
  final FollowRepository _repository;

  Future<Result<bool>> call({
    required String currentUserId,
    required String targetUserId,
  }) =>
      _repository.unfollowUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
}
