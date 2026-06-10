import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../auth/data/providers/auth_data_providers.dart';
import '../../../follow/data/providers/follow_data_providers.dart';
import '../../../follow/domain/entities/follow.dart';
import '../../data/providers/notification_data_providers.dart';
import '../../domain/entities/notification.dart';

// ── Notifications Notifier ────────────────────────────────────────────────────

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return const [];

    // Realtime kuzatuv — yangi bildirishnoma kelsa, listni yangilaymiz
    _watchRealtime(userId);

    return _fetchNotifications(userId);
  }

  String? get _userId => ref.read(currentUserIdProvider);

  Future<List<AppNotification>> _fetchNotifications(String userId) async {
    AppLogger.d('NotificationsNotifier: yuklanmoqda');
    final result = await ref
        .read(notificationRepositoryProvider)
        .getNotifications(userId: userId);

    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  void _watchRealtime(String userId) {
    var subscription = ref
        .read(notificationRepositoryProvider)
        .watchNewNotifications(userId)
        .listen(
      (newNotif) {
        state.whenData((current) {
          if (current.any((n) => n.id == newNotif.id)) return;
          state = AsyncData([newNotif, ...current]);
          AppLogger.d(
            'NotificationsNotifier: yangi bildirishnoma — ${newNotif.type}',
          );
        });
      },
      // JWT eskirganda yoki ulanish uzilganda — silent log, crash bo'lmasin
      onError: (Object e) {
        AppLogger.w('NotificationsNotifier: realtime xato — $e');
      },
    );

    // Auth token yangilanganda subscription'ni qayta ochamiz
    ref.listen(authUserStreamProvider, (prev, next) {
      final prevUser = prev?.valueOrNull;
      final nextUser = next.valueOrNull;
      // Token refresh: user bir xil lekin session yangilangan
      if (nextUser != null && prevUser?.id == nextUser.id) {
        AppLogger.d('NotificationsNotifier: token yangilandi — realtime qayta ulanmoqda');
        subscription.cancel();
        subscription = ref
            .read(notificationRepositoryProvider)
            .watchNewNotifications(userId)
            .listen(
          (newNotif) {
            state.whenData((current) {
              if (current.any((n) => n.id == newNotif.id)) return;
              state = AsyncData([newNotif, ...current]);
            });
          },
          onError: (Object e) {
            AppLogger.w('NotificationsNotifier: realtime xato (retry) — $e');
          },
        );
      }
    });

    ref.onDispose(subscription.cancel);
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchNotifications(userId));
  }

  Future<void> markRead(String notifId) async {
    state.whenData((notifications) {
      state = AsyncData(notifications
          .map((n) => n.id == notifId ? n.copyWith(isRead: true) : n)
          .toList());
    });

    await ref.read(notificationRepositoryProvider).markRead(notifId);
  }

  Future<void> markAllRead() async {
    final userId = _userId;
    if (userId == null) return;

    state.whenData((notifications) {
      state = AsyncData(
        notifications.map((n) => n.copyWith(isRead: true)).toList(),
      );
    });

    final result =
        await ref.read(notificationRepositoryProvider).markAllRead(userId);

    if (result.isErr) {
      // Rollback on failure
      final r = await AsyncValue.guard(() => _fetchNotifications(userId));
      state = r;
    }
  }

  /// Follow so'rovini qabul qilish (notification ichidan)
  Future<void> acceptFollowRequest(String actorId) async {
    final userId = _userId;
    if (userId == null) return;

    final result = await ref.read(followRepositoryProvider).acceptFollowRequest(
          currentUserId: userId,
          requesterId: actorId,
        );

    if (result.isOk) {
      // Notification'ni follow'ga o'zgartiramiz
      state.whenData((notifications) {
        state = AsyncData(notifications.map((n) {
          if (n.actor.id != actorId ||
              n.type != NotificationType.followRequest) {
            return n;
          }
          return AppNotification(
            id: n.id,
            type: NotificationType.follow,
            actor: n.actor.copyWith(followStatus: FollowStatus.following),
            createdAt: n.createdAt,
            isRead: true,
          );
        }).toList());
      });
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

final hasUnreadNotificationsProvider = Provider<bool>(
  (ref) => ref.watch(
    notificationsProvider.select(
      (async) => async.valueOrNull?.any((n) => !n.isRead) ?? false,
    ),
  ),
);
