import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/ui_models.dart';
import '../../../../core/utils/mock_data.dart';

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = true,
  });

  final List<NotificationModel> notifications;
  final bool isLoading;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
  }) =>
      NotificationsState(
        notifications: notifications ?? this.notifications,
        isLoading: isLoading ?? this.isLoading,
      );
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    _load();
    return const NotificationsState();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      notifications: MockData.notifications,
      isLoading: false,
    );
  }

  void markRead(String notifId) {
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id != notifId) return n;
        return n.copyWith(isRead: true);
      }).toList(),
    );
  }

  void markAllRead() {
    state = state.copyWith(
      notifications:
          state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  void toggleFollow(String notifId) {
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id != notifId) return n;
        return n.copyWith(
          actor: n.actor.copyWith(isFollowing: !n.actor.isFollowing),
        );
      }).toList(),
    );
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
