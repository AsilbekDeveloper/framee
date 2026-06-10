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
          message: 'Foydalanuvchi topilmadi.',
          code: 'follow/not-found',
        );
}

final class AlreadyFollowingFailure extends FollowFailure {
  const AlreadyFollowingFailure()
      : super(
          message: 'Siz allaqachon bu foydalanuvchini follow qilgansiz.',
          code: 'follow/already-following',
        );
}

final class FollowRequestSentFailure extends FollowFailure {
  const FollowRequestSentFailure()
      : super(
          message: 'Follow so\'rovi allaqachon yuborilgan.',
          code: 'follow/request-sent',
        );
}

final class CannotFollowSelfFailure extends FollowFailure {
  const CannotFollowSelfFailure()
      : super(
          message: 'O\'zingizni follow qilib bo\'lmaydi.',
          code: 'follow/self-follow',
        );
}

final class FollowOperationFailure extends FollowFailure {
  const FollowOperationFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Follow amali muvaffaqiyatsiz tugadi.',
          code: 'follow/operation-failed',
        );
}
