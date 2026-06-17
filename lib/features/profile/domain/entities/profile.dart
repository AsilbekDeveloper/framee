/// Domain entity representing a user profile from the Supabase `profiles` table.
/// Independent of UI models — used only for business logic.
class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.website,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isPrivate = false,
    this.isVerified = false,
    this.isFollowing = false,
    this.isRequested = false,
    this.isFollowingMe = false,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? website;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isPrivate;
  final bool isVerified;

  /// Whether the current viewer follows this profile (always false for own profile).
  final bool isFollowing;

  /// Whether the current viewer has a pending follow request to this (private) profile.
  final bool isRequested;

  /// Whether this profile follows the current viewer back.
  final bool isFollowingMe;

  final DateTime createdAt;
  final DateTime? updatedAt;

  String get initials => displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : username.isNotEmpty
          ? username[0].toUpperCase()
          : '?';

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  // Sentinel pattern — allows copyWith to explicitly set nullable fields to null
  static const _unset = Object();

  Profile copyWith({
    String? id,
    String? username,
    String? displayName,
    Object? avatarUrl = _unset,
    Object? bio = _unset,
    Object? website = _unset,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    bool? isPrivate,
    bool? isVerified,
    bool? isFollowing,
    bool? isRequested,
    bool? isFollowingMe,
    DateTime? createdAt,
    Object? updatedAt = _unset,
  }) =>
      Profile(
        id: id ?? this.id,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl == _unset ? this.avatarUrl : avatarUrl as String?,
        bio: bio == _unset ? this.bio : bio as String?,
        website: website == _unset ? this.website : website as String?,
        postsCount: postsCount ?? this.postsCount,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
        isPrivate: isPrivate ?? this.isPrivate,
        isVerified: isVerified ?? this.isVerified,
        isFollowing: isFollowing ?? this.isFollowing,
        isRequested: isRequested ?? this.isRequested,
        isFollowingMe: isFollowingMe ?? this.isFollowingMe,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt == _unset ? this.updatedAt : updatedAt as DateTime?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Profile(id: $id, username: $username)';
}

/// Input parameters for updating a profile — only include fields the user has changed.
class UpdateProfileParams {
  const UpdateProfileParams({
    required this.userId,
    this.username,
    this.displayName,
    this.bio,
    this.website,
    this.avatarLocalPath,
    this.isPrivate,
  });

  final String userId;
  final String? username;
  final String? displayName;
  final String? bio;
  final String? website;

  /// Local file path to upload to Storage, or an existing http URL, or null to keep unchanged.
  final String? avatarLocalPath;
  final bool? isPrivate;
}
