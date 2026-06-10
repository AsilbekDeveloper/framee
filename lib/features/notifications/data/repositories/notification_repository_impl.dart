import '../../../../core/errors/result.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._dataSource);
  final NotificationRemoteDataSource _dataSource;

  @override
  Future<Result<List<AppNotification>>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await _dataSource.getNotifications(
      userId: userId,
      limit: limit,
      offset: offset,
    );
    return result.map((dtos) => dtos.map((d) => d.toEntity()).toList());
  }

  @override
  Future<Result<bool>> markRead(String notificationId) =>
      _dataSource.markRead(notificationId);

  @override
  Future<Result<bool>> markAllRead(String userId) =>
      _dataSource.markAllRead(userId);

  @override
  Stream<AppNotification> watchNewNotifications(String userId) =>
      _dataSource
          .watchNewNotifications(userId)
          .map((dto) => dto.toEntity());
}
