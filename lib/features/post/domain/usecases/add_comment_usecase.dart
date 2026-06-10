import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../failures/post_failure.dart';
import '../repositories/post_repository.dart';

class AddCommentUseCase {
  const AddCommentUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<Comment>> call(AddCommentParams params) {
    final text = params.text.trim();

    if (text.isEmpty) {
      return Future.value(
        const Err(PostValidationFailure(message: 'Izoh bo\'sh bo\'lishi mumkin emas.')),
      );
    }

    if (text.length > 500) {
      return Future.value(
        const Err(PostValidationFailure(message: 'Izoh 500 belgidan oshmasligi kerak.')),
      );
    }

    return _repository.addComment(AddCommentParams(
      postId: params.postId,
      userId: params.userId,
      text: text,
      parentId: params.parentId,
    ));
  }
}
