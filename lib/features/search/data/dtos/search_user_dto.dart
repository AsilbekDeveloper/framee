import '../../../follow/domain/entities/follow.dart';
import '../../domain/entities/search_result.dart';

/// Supabase `search_users` RPC'dan kelgan flat JSON'ni o'z ichiga oladi.
class SearchUserDto {
  const SearchUserDto({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.isPrivate = false,
    this.followersCount = 0,
    this.isFollowing = false,
    this.isRequested = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isPrivate;
  final int followersCount;
  final bool isFollowing;
  final bool isRequested;

  factory SearchUserDto.fromJson(Map<String, dynamic> json) => SearchUserDto(
        id: json['id'] as String,
        username: json['username'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        isPrivate: json['is_private'] as bool? ?? false,
        followersCount: json['followers_count'] as int? ?? 0,
        isFollowing: json['is_following'] as bool? ?? false,
        isRequested: json['is_requested'] as bool? ?? false,
      );

  SearchUser toEntity() {
    FollowStatus status = FollowStatus.none;
    if (isFollowing) {
      status = FollowStatus.following;
    } else if (isRequested) {
      status = FollowStatus.requested;
    }

    return SearchUser(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      isPrivate: isPrivate,
      followersCount: followersCount,
      followStatus: status,
    );
  }
}
