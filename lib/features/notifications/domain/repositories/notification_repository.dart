import '../../../../core/errors/result.dart';
import '../entities/notification.dart';

abstract interface class NotificationRepository {
  Future<Result<List<AppNotification>>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  });

  Future<Result<bool>> markRead(String notificationId);

  Future<Result<bool>> markAllRead(String userId);

  /// Supabase Realtime orqali yangi bildirishnomalar stream'i
  Stream<AppNotification> watchNewNotifications(String userId);
}
