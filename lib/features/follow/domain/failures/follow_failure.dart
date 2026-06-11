import '../../../../core/errors/failure.dart';

abstract class FollowFailure extends Failure {
  const FollowFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

final class FollowNotFoundFailure extends FollowFailure {
  const FollowNotFoundFailure()
      : super(
          message: 'User not found.',
          code: 'follow/not-found',
        );
}

final class AlreadyFollowingFailure extends FollowFailure {
  const AlreadyFollowingFailure()
      : super(
          message: 'You are already following this user.',
          code: 'follow/already-following',
        );
}

final class FollowRequestSentFailure extends FollowFailure {
  const FollowRequestSentFailure()
      : super(
          message: 'A follow request has already been sent.',
          code: 'follow/request-sent',
        );
}

final class CannotFollowSelfFailure extends FollowFailure {
  const CannotFollowSelfFailure()
      : super(
          message: 'You cannot follow yourself.',
          code: 'follow/self-follow',
        );
}

final class FollowOperationFailure extends FollowFailure {
  const FollowOperationFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Follow operation failed.',
          code: 'follow/operation-failed',
        );
}
