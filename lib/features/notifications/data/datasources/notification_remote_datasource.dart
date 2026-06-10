import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/failures/notification_failure.dart';
import '../dtos/notification_dto.dart';

abstract interface class NotificationRemoteDataSource {
  Future<Result<List<NotificationDto>>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  });

  Future<Result<bool>> markRead(String notificationId);
  Future<Result<bool>> markAllRead(String userId);
  Stream<NotificationDto> watchNewNotifications(String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<Result<List<NotificationDto>>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      AppLogger.d('NotificationDS: yuklanmoqda — $userId');
      final data = await _client.rpc('get_notifications', params: {
        'p_user_id': userId,
        'p_limit': limit,
        'p_offset': offset,
      }) as List<dynamic>;

      final dtos = data
          .cast<Map<String, dynamic>>()
          .map(NotificationDto.fromRpc)
          .toList();

      AppLogger.d('NotificationDS: ${dtos.length} ta bildirishnoma');
      return Ok(dtos);
    } on PostgrestException catch (e) {
      AppLogger.e('NotificationDS: getNotifications xatosi', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NotificationLoadFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> markRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      return const Ok(true);
    } on PostgrestException catch (e) {
      return Err(NotificationMarkReadFailure(originalError: e));
    } catch (e) {
      return Err(NotificationMarkReadFailure(originalError: e));
    }
  }

  @override
  Future<Result<bool>> markAllRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      AppLogger.i('NotificationDS: barchasi o\'qilgan belgilandi');
      return const Ok(true);
    } on PostgrestException catch (e) {
      return Err(NotificationMarkReadFailure(originalError: e));
    } catch (e) {
      return Err(NotificationMarkReadFailure(originalError: e));
    }
  }

  @override
  Stream<NotificationDto> watchNewNotifications(String userId) {
    // Supabase Realtime: notifications jadvaldagi INSERT'larni kuzatamiz
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .map((rows) => rows.isEmpty ? null : NotificationDto.fromRpc(rows.first))
        .where((dto) => dto != null)
        .cast<NotificationDto>();
  }
}
