import '../../../../core/errors/result.dart';
import '../repositories/post_repository.dart';

class ToggleCommentLikeUseCase {
  const ToggleCommentLikeUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<bool>> call({
    required String commentId,
    required String currentUserId,
  }) =>
      _repository.toggleCommentLike(
        commentId: commentId,
        currentUserId: currentUserId,
      );
}
