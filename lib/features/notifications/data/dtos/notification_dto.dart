import '../../../follow/domain/entities/follow.dart';
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
    this.actorFollowStatus = FollowStatus.none,
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
  final FollowStatus actorFollowStatus;

  /// Supabase direct query + embedded relations format:
  /// { ..., actor: { username, display_name, avatar_url }, post: { image_url } }
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    final post = json['post'] as Map<String, dynamic>?;

    return NotificationDto(
      id: json['id'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      actorId: json['actor_id'] as String,
      actorUsername: actor?['username'] as String? ?? '',
      actorDisplayName: actor?['display_name'] as String? ?? '',
      actorAvatarUrl: actor?['avatar_url'] as String?,
      postId: json['post_id'] as String?,
      postImageUrl: post?['image_url'] as String?,
    );
  }

  AppNotification toEntity() => AppNotification(
        id: id,
        type: _parseType(type),
        actor: NotificationActor(
          id: actorId,
          username: actorUsername,
          displayName: actorDisplayName,
          avatarUrl: actorAvatarUrl,
          followStatus: actorFollowStatus,
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
