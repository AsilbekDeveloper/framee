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

    // Subscribe to realtime — prepend new notifications as they arrive
    _watchRealtime(userId);

    return _fetchNotifications(userId);
  }

  String? get _userId => ref.read(currentUserIdProvider);

  Future<List<AppNotification>> _fetchNotifications(String userId) async {
    AppLogger.d('NotificationsNotifier: loading');
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
            'NotificationsNotifier: new notification — ${newNotif.type}',
          );
        });
      },
      // JWT expiry or connection drop — log silently to avoid crashing
      onError: (Object e) {
        AppLogger.w('NotificationsNotifier: realtime error — $e');
      },
    );

    // Re-subscribe when the auth token is refreshed
    ref.listen(authUserStreamProvider, (prev, next) {
      final prevUser = prev?.valueOrNull;
      final nextUser = next.valueOrNull;
      // Token refresh: same user but session updated
      if (nextUser != null && prevUser?.id == nextUser.id) {
        AppLogger.d('NotificationsNotifier: token refreshed — reconnecting realtime');
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
            AppLogger.w('NotificationsNotifier: realtime error (retry) — $e');
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

  /// Accepts a follow request triggered from within a notification.
  Future<void> acceptFollowRequest(String actorId) async {
    final userId = _userId;
    if (userId == null) return;

    final result = await ref.read(followRepositoryProvider).acceptFollowRequest(
          currentUserId: userId,
          requesterId: actorId,
        );

    if (result.isOk) {
      // Update the notification type from followRequest to follow
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
