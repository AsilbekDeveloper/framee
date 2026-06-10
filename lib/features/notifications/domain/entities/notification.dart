import '../../../follow/domain/entities/follow.dart';

enum NotificationType { like, comment, follow, followRequest, mention }

class NotificationActor {
  const NotificationActor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.followStatus = FollowStatus.none,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final FollowStatus followStatus;

  String get initials => displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : username.isNotEmpty
          ? username[0].toUpperCase()
          : '?';

  NotificationActor copyWith({FollowStatus? followStatus}) => NotificationActor(
        id: id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        followStatus: followStatus ?? this.followStatus,
      );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.actor,
    required this.createdAt,
    this.postId,
    this.postImageUrl,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final NotificationActor actor;
  final DateTime createdAt;
  final String? postId;
  final String? postImageUrl;
  final bool isRead;

  AppNotification copyWith({
    bool? isRead,
    NotificationActor? actor,
  }) =>
      AppNotification(
        id: id,
        type: type,
        actor: actor ?? this.actor,
        createdAt: createdAt,
        postId: postId,
        postImageUrl: postImageUrl,
        isRead: isRead ?? this.isRead,
      );
}
