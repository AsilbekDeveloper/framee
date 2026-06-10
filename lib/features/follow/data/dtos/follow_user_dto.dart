import '../../domain/entities/follow.dart';

class FollowUserDto {
  const FollowUserDto({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.isPrivate = false,
    this.followStatus = FollowStatus.none,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isPrivate;
  final FollowStatus followStatus;

  factory FollowUserDto.fromJson(
    Map<String, dynamic> json, {
    FollowStatus followStatus = FollowStatus.none,
  }) =>
      FollowUserDto(
        id: json['id'] as String,
        username: json['username'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        isPrivate: json['is_private'] as bool? ?? false,
        followStatus: followStatus,
      );

  FollowUser toEntity() => FollowUser(
        id: id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        isVerified: isVerified,
        isPrivate: isPrivate,
        followStatus: followStatus,
      );
}
