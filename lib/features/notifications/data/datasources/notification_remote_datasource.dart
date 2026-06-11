import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/failures/notification_failure.dart';
import '../dtos/notification_dto.dart';

// Notification query — includes actor and post data
const _kNotifSelect =
    'id, type, is_read, created_at, actor_id, post_id, '
    'actor:profiles!actor_id(username, display_name, avatar_url), '
    'post:posts!post_id(image_url)';

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
      AppLogger.d('NotificationDS: loading — $userId');
      final data = await _client
          .from('notifications')
          .select(_kNotifSelect)
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      final dtos = (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(NotificationDto.fromJson)
          .toList();

      AppLogger.d('NotificationDS: ${dtos.length} notifications loaded');
      return Ok(dtos);
    } on PostgrestException catch (e) {
      AppLogger.e('NotificationDS: getNotifications error', error: e);
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
          .update({'is_read': true}).eq('id', notificationId);
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
      AppLogger.i('NotificationDS: all marked as read');
      return const Ok(true);
    } on PostgrestException catch (e) {
      return Err(NotificationMarkReadFailure(originalError: e));
    } catch (e) {
      return Err(NotificationMarkReadFailure(originalError: e));
    }
  }

  @override
  Stream<NotificationDto> watchNewNotifications(String userId) {
    final controller = StreamController<NotificationDto>.broadcast();

    final channel = _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            final id = payload.newRecord['id'] as String?;
            if (id == null) return;
            try {
              // Fetch the new notification with its actor details
              final row = await _client
                  .from('notifications')
                  .select(_kNotifSelect)
                  .eq('id', id)
                  .single();
              controller.add(NotificationDto.fromJson(row));
            } catch (e) {
              AppLogger.w('NotificationDS: could not load realtime notification — $e');
            }
          },
        )
        .subscribe((status, [error]) {
          AppLogger.d('NotificationDS: realtime status — $status');
          if (error != null) {
            AppLogger.w('NotificationDS: realtime error — $error');
          }
        });

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }
}
