import '../../../../core/errors/result.dart';
import '../repositories/post_repository.dart';

class DeletePostUseCase {
  const DeletePostUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<bool>> call({
    required String postId,
    required String currentUserId,
  }) =>
      _repository.deletePost(postId: postId, currentUserId: currentUserId);
}
