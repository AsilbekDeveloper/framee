import '../../../../core/errors/failure.dart';

/// Base class for all post-domain failures.
abstract class PostFailure extends Failure {
  const PostFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Post not found — deleted or never existed.
final class PostNotFoundFailure extends PostFailure {
  const PostNotFoundFailure()
      : super(
          message: 'Post not found or has been deleted.',
          code: 'post/not-found',
        );
}

/// Image upload failed during post creation — treated as a hard failure for image posts.
final class PostImageUploadFailure extends PostFailure {
  const PostImageUploadFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Image upload failed. Please try again.',
          code: 'post/image-upload-failed',
        );
}

/// Database error while creating a post.
final class PostCreateFailure extends PostFailure {
  const PostCreateFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Post could not be saved. Please try later.',
          code: 'post/create-failed',
        );
}

/// Error while deleting a post.
final class PostDeleteFailure extends PostFailure {
  const PostDeleteFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Could not delete the post.',
          code: 'post/delete-failed',
        );
}

/// Error while adding a comment.
final class CommentFailure extends PostFailure {
  const CommentFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Comment could not be saved. Please try later.',
          code: 'post/comment-failed',
        );
}

/// Validation error (empty text, etc.).
final class PostValidationFailure extends PostFailure {
  const PostValidationFailure({required super.message})
      : super(code: 'post/validation');
}

/// Error during a like or save interaction.
final class PostInteractionFailure extends PostFailure {
  const PostInteractionFailure({super.originalError})
      : super(
          message: 'Action failed. Please try again.',
          code: 'post/interaction-failed',
        );
}

/// Unauthorized — attempted to delete someone else's post.
final class PostUnauthorizedFailure extends PostFailure {
  const PostUnauthorizedFailure()
      : super(
          message: 'You are not authorized to perform this action.',
          code: 'post/unauthorized',
        );
}
