/// Domain entities for the follow feature.
library;

/// Represents the follow relationship from the current user's perspective.
enum FollowStatus {
  /// No relationship exists.
  none,

  /// The current user follows this person.
  following,

  /// Private account — a follow request has been sent but not yet accepted.
  requested,
}

class FollowUser {
  const FollowUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.followStatus = FollowStatus.none,
    this.isPrivate = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final FollowStatus followStatus;
  final bool isPrivate;

  bool get isFollowing => followStatus == FollowStatus.following;
  bool get isRequested => followStatus == FollowStatus.requested;

  String get initials => displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : username.isNotEmpty
          ? username[0].toUpperCase()
          : '?';

  FollowUser copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isVerified,
    FollowStatus? followStatus,
    bool? isPrivate,
  }) =>
      FollowUser(
        id: id ?? this.id,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isVerified: isVerified ?? this.isVerified,
        followStatus: followStatus ?? this.followStatus,
        isPrivate: isPrivate ?? this.isPrivate,
      );
}
