import '../../../../core/errors/result.dart';
import '../entities/follow.dart';
import '../repositories/follow_repository.dart';

class GetFollowStatusUseCase {
  const GetFollowStatusUseCase(this._repository);
  final FollowRepository _repository;

  Future<Result<FollowStatus>> call({
    required String currentUserId,
    required String targetUserId,
  }) =>
      _repository.getFollowStatus(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
}
