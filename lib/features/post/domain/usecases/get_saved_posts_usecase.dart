import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetSavedPostsUseCase {
  const GetSavedPostsUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<List<Post>>> call({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) =>
      _repository.getSavedPosts(
        userId: userId,
        limit: limit,
        offset: offset,
      );
}
