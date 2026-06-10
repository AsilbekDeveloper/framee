import '../../../../core/errors/result.dart';
import '../entities/follow.dart';
import '../failures/follow_failure.dart';
import '../repositories/follow_repository.dart';

class FollowUserUseCase {
  const FollowUserUseCase(this._repository);
  final FollowRepository _repository;

  Future<Result<FollowStatus>> call({
    required String currentUserId,
    required String targetUserId,
  }) {
    if (currentUserId == targetUserId) {
      return Future.value(const Err(CannotFollowSelfFailure()));
    }
    return _repository.followUser(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );
  }
}
