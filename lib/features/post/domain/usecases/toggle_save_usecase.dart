import '../../../../core/errors/result.dart';
import '../repositories/post_repository.dart';

class ToggleSaveUseCase {
  const ToggleSaveUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<bool>> call({
    required String postId,
    required String currentUserId,
  }) =>
      _repository.toggleSave(postId: postId, currentUserId: currentUserId);
}
