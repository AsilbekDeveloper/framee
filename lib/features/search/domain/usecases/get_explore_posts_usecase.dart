import '../../../../core/errors/result.dart';
import '../../../post/domain/entities/post.dart';
import '../repositories/search_repository.dart';

class GetExplorePostsUseCase {
  const GetExplorePostsUseCase(this._repository);
  final SearchRepository _repository;

  Future<Result<List<Post>>> call({
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) =>
      _repository.getExplorePosts(
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
}
