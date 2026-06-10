import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetCommentsUseCase {
  const GetCommentsUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<List<Comment>>> call({
    required String postId,
    required String currentUserId,
  }) =>
      _repository.getComments(postId: postId, currentUserId: currentUserId);
}
