import '../../../../core/errors/result.dart';
import '../repositories/post_repository.dart';

class ToggleLikeUseCase {
  const ToggleLikeUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<({int likesCount, bool isLiked})>> call({
    required String postId,
    required String currentUserId,
  }) =>
      _repository.toggleLike(postId: postId, currentUserId: currentUserId);
}
