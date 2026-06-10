import '../../domain/entities/notification.dart';

class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.actorId,
    required this.actorUsername,
    required this.actorDisplayName,
    this.actorAvatarUrl,
    this.postId,
    this.postImageUrl,
  });

  final String id;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String actorId;
  final String actorUsername;
  final String actorDisplayName;
  final String? actorAvatarUrl;
  final String? postId;
  final String? postImageUrl;

  factory NotificationDto.fromRpc(Map<String, dynamic> json) => NotificationDto(
        id: json['id'] as String,
        type: json['type'] as String,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        actorId: json['actor_id'] as String,
        actorUsername: json['actor_username'] as String? ?? '',
        actorDisplayName: json['actor_display_name'] as String? ?? '',
        actorAvatarUrl: json['actor_avatar_url'] as String?,
        postId: json['post_id'] as String?,
        postImageUrl: json['post_image_url'] as String?,
      );

  AppNotification toEntity() => AppNotification(
        id: id,
        type: _parseType(type),
        actor: NotificationActor(
          id: actorId,
          username: actorUsername,
          displayName: actorDisplayName,
          avatarUrl: actorAvatarUrl,
        ),
        createdAt: createdAt,
        postId: postId,
        postImageUrl: postImageUrl,
        isRead: isRead,
      );

  static NotificationType _parseType(String type) => switch (type) {
        'like' => NotificationType.like,
        'comment' => NotificationType.comment,
        'follow' => NotificationType.follow,
        'follow_request' => NotificationType.followRequest,
        'mention' => NotificationType.mention,
        _ => NotificationType.like,
      };
}
