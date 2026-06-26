import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../auth/data/providers/auth_data_providers.dart';
import '../../../follow/data/providers/follow_data_providers.dart';
import '../../../follow/domain/entities/follow.dart';
import '../../data/providers/notification_data_providers.dart';
import '../../domain/entities/notification.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class NotifFeedState {
  const NotifFeedState({
    this.notifications = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<AppNotification> notifications;
  final bool hasMore;
  final bool isLoadingMore;

  NotifFeedState copyWith({
    List<AppNotification>? notifications,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      NotifFeedState(
        notifications: notifications ?? this.notifications,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class NotificationsNotifier extends AsyncNotifier<NotifFeedState> {
  static const _pageSize = AppConfig.notificationsPageSize;

  @override
  Future<NotifFeedState> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const NotifFeedState();

    _watchRealtime(userId);

    final notifications = await _fetchNotifications(userId);
    return NotifFeedState(
      notifications: notifications,
      hasMore: notifications.length >= _pageSize,
    );
  }

  String? get _userId => ref.read(currentUserIdProvider);

  Future<List<AppNotification>> _fetchNotifications(
    String userId, {
    int offset = 0,
  }) async {
    AppLogger.d('NotificationsNotifier: loading offset:$offset');
    final result = await ref
        .read(notificationRepositoryProvider)
        .getNotifications(userId: userId, limit: _pageSize, offset: offset);

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
        state.whenData((feed) {
          if (feed.notifications.any((n) => n.id == newNotif.id)) return;
          state = AsyncData(
              feed.copyWith(notifications: [newNotif, ...feed.notifications]));
          AppLogger.d(
              'NotificationsNotifier: new notification — ${newNotif.type}');
        });
      },
      onError: (Object e) {
        AppLogger.w('NotificationsNotifier: realtime error — $e');
      },
    );

    ref.listen(authUserStreamProvider, (prev, next) {
      final prevUser = prev?.valueOrNull;
      final nextUser = next.valueOrNull;
      if (nextUser != null && prevUser?.id == nextUser.id) {
        AppLogger.d(
            'NotificationsNotifier: token refreshed — reconnecting realtime');
        subscription.cancel();
        subscription = ref
            .read(notificationRepositoryProvider)
            .watchNewNotifications(userId)
            .listen(
          (newNotif) {
            state.whenData((feed) {
              if (feed.notifications.any((n) => n.id == newNotif.id)) return;
              state = AsyncData(feed.copyWith(
                  notifications: [newNotif, ...feed.notifications]));
            });
          },
          onError: (Object e) {
            AppLogger.w(
                'NotificationsNotifier: realtime error (retry) — $e');
          },
        );
      }
    });

    // Wrap in a closure so dispose cancels whatever `subscription` currently
    // points to — after a token-refresh reconnect it is reassigned, and a bare
    // `subscription.cancel` tear-off would leak the reconnected subscription.
    ref.onDispose(() => subscription.cancel());
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;
    state = const AsyncLoading();
    try {
      final notifications = await _fetchNotifications(userId);
      state = AsyncData(NotifFeedState(
        notifications: notifications,
        hasMore: notifications.length >= _pageSize,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    final feed = state.valueOrNull;
    if (feed == null || !feed.hasMore || feed.isLoadingMore) return;

    final userId = _userId;
    if (userId == null) return;

    state = AsyncData(feed.copyWith(isLoadingMore: true));

    try {
      final newNotifs = await _fetchNotifications(
        userId,
        offset: feed.notifications.length,
      );
      state = AsyncData(NotifFeedState(
        notifications: [...feed.notifications, ...newNotifs],
        hasMore: newNotifs.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(feed.copyWith(isLoadingMore: false));
    }
  }

  Future<void> markRead(String notifId) async {
    state.whenData((feed) {
      state = AsyncData(feed.copyWith(
        notifications: feed.notifications
            .map((n) => n.id == notifId ? n.copyWith(isRead: true) : n)
            .toList(),
      ));
    });
    await ref.read(notificationRepositoryProvider).markRead(notifId);
  }

  Future<void> markAllRead() async {
    final userId = _userId;
    if (userId == null) return;

    state.whenData((feed) {
      state = AsyncData(feed.copyWith(
        notifications:
            feed.notifications.map((n) => n.copyWith(isRead: true)).toList(),
      ));
    });

    final result =
        await ref.read(notificationRepositoryProvider).markAllRead(userId);

    if (result.isErr) {
      final userId2 = _userId;
      if (userId2 == null) return;
      try {
        final notifications = await _fetchNotifications(userId2);
        state = AsyncData(NotifFeedState(
          notifications: notifications,
          hasMore: notifications.length >= _pageSize,
        ));
      } catch (_) {}
    }
  }

  Future<void> toggleFollow(String actorId, bool isActive) async {
    final userId = _userId;
    if (userId == null) return;

    if (isActive) {
      // Following or a pending request → undo it.
      final result = await ref.read(unfollowUserUseCaseProvider).call(
            currentUserId: userId,
            targetUserId: actorId,
          );
      // Only reflect the change if the server confirmed it.
      if (result.isOk) _patchActorStatus(actorId, FollowStatus.none);
    } else {
      final result = await ref.read(followUserUseCaseProvider).call(
            currentUserId: userId,
            targetUserId: actorId,
          );
      // A private account returns `requested`, a public one `following` —
      // never assume `following`, or a request would look like a real follow.
      if (result case Ok(:final value)) {
        _patchActorStatus(actorId, value);
      }
    }
  }

  Future<void> acceptFollowRequest(String actorId) async {
    final userId = _userId;
    if (userId == null) return;

    final result = await ref.read(followRepositoryProvider).acceptFollowRequest(
          currentUserId: userId,
          requesterId: actorId,
        );

    if (result.isOk) {
      state.whenData((feed) {
        state = AsyncData(feed.copyWith(
          notifications: feed.notifications.map((n) {
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
          }).toList(),
        ));
      });
    }
  }

  void _patchActorStatus(String actorId, FollowStatus status) {
    state.whenData((feed) {
      state = AsyncData(feed.copyWith(
        notifications: feed.notifications.map((n) {
          if (n.actor.id != actorId) return n;
          return n.copyWith(actor: n.actor.copyWith(followStatus: status));
        }).toList(),
      ));
    });
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, NotifFeedState>(
  NotificationsNotifier.new,
);

final hasUnreadNotificationsProvider = Provider<bool>(
  (ref) => ref.watch(
    notificationsProvider.select(
      (async) =>
          async.valueOrNull?.notifications.any((n) => !n.isRead) ?? false,
    ),
  ),
);
