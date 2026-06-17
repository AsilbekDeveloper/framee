import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../failures/post_failure.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  const CreatePostUseCase(this._repository);
  final PostRepository _repository;

  Future<Result<Post>> call(CreatePostParams params) {
    // Client-side validatsiya
    final caption = params.caption?.trim() ?? '';
    final hasImage = params.imageLocalPath != null;

    if (!hasImage && caption.isEmpty) {
      return Future.value(
        const Err(PostValidationFailure(
          message: 'Post matn yoki rasm bo\'lishi kerak.',
        )),
      );
    }

    if (caption.length > AppConfig.maxCaptionLength) {
      return Future.value(
        const Err(PostValidationFailure(
          message:
              'Matn ${AppConfig.maxCaptionLength} belgidan oshmasligi kerak.',
        )),
      );
    }

    return _repository.createPost(params);
  }
}
