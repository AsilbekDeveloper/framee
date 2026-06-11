import '../../../../core/errors/failure.dart';

abstract class NotificationFailure extends Failure {
  const NotificationFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

final class NotificationLoadFailure extends NotificationFailure {
  const NotificationLoadFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Failed to load notifications.',
          code: 'notification/load-failed',
        );
}

final class NotificationMarkReadFailure extends NotificationFailure {
  const NotificationMarkReadFailure({super.originalError})
      : super(
          message: 'Failed to mark notification as read.',
          code: 'notification/mark-read-failed',
        );
}
