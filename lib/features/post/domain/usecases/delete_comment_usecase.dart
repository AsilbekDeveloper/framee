import '../../../../core/errors/result.dart';
import '../repositories/post_repository.dart';

class DeleteCommentUseCase {
  const DeleteCommentUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<bool>> call({
    required String commentId,
    required String currentUserId,
  }) =>
      _repository.deleteComment(
        commentId: commentId,
        currentUserId: currentUserId,
      );
}
