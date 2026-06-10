import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetUserPostsUseCase {
  const GetUserPostsUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<List<Post>>> call({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) =>
      _repository.getUserPosts(
        userId: userId,
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
}
