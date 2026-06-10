import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostUseCase {
  const GetPostUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<Post>> call({
    required String postId,
    required String currentUserId,
  }) =>
      _repository.getPost(postId: postId, currentUserId: currentUserId);
}
