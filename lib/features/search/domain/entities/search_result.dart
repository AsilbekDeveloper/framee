import '../../../follow/domain/entities/follow.dart';

class SearchUser {
  const SearchUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.isPrivate = false,
    this.followersCount = 0,
    this.followStatus = FollowStatus.none,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isPrivate;
  final int followersCount;
  final FollowStatus followStatus;

  bool get isFollowing => followStatus == FollowStatus.following;
  bool get isRequested => followStatus == FollowStatus.requested;

  String get initials => displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : username.isNotEmpty
          ? username[0].toUpperCase()
          : '?';

  SearchUser copyWith({FollowStatus? followStatus}) => SearchUser(
        id: id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        isVerified: isVerified,
        isPrivate: isPrivate,
        followersCount: followersCount,
        followStatus: followStatus ?? this.followStatus,
      );
}
