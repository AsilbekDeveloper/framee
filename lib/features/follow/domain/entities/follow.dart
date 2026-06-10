/// Follow domeniga tegishli entity'lar.
library;

enum FollowStatus {
  /// Hech qanday munosabat yo'q
  none,

  /// Joriy foydalanuvchi bu odamni follow qilgan
  following,

  /// Private account — follow so'rovi yuborilgan, hali qabul qilinmagan
  requested,

  /// Bu odam joriy foydalanuvchini follow qilgan (lekin aksi emas)
  followsYou,
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
