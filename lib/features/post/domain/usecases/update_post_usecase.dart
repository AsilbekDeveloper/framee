import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class UpdatePostUseCase {
  const UpdatePostUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<Post>> call(UpdatePostParams params) =>
      _repository.updatePost(params);
}
