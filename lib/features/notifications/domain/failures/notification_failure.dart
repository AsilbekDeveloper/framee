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
          message: 'Bildirishnomalar yuklanmadi.',
          code: 'notification/load-failed',
        );
}

final class NotificationMarkReadFailure extends NotificationFailure {
  const NotificationMarkReadFailure({super.originalError})
      : super(
          message: 'Bildirishnoma o\'qilgan deb belgilanmadi.',
          code: 'notification/mark-read-failed',
        );
}
