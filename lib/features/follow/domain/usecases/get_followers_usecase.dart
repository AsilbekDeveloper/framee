import '../../../../core/errors/result.dart';
import '../entities/follow.dart';
import '../repositories/follow_repository.dart';

class GetFollowersUseCase {
  const GetFollowersUseCase(this._repository);
  final FollowRepository _repository;

  Future<Result<List<FollowUser>>> call({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) =>
      _repository.getFollowers(
        userId: userId,
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
}
