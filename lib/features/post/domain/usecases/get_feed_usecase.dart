import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetFeedUseCase {
  const GetFeedUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<List<Post>>> call({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) =>
      _repository.getFeed(
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
}
