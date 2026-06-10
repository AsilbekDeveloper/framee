/// `profiles` Supabase jadvalidagi foydalanuvchi profilini ifodalovchi domain entity.
/// UI modellardan mustaqil — faqat biznes mantiq uchun.
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

  /// Joriy foydalanuvchi bu profilni follow qilganmi (boshqa profil uchun)
  final bool isFollowing;

  final DateTime createdAt;
  final DateTime? updatedAt;

  String get initials => displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : username.isNotEmpty
          ? username[0].toUpperCase()
          : '?';

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  // Sentinel pattern — nullable field'larni copyWith'da aniq null'ga o'rnatish uchun
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

/// Profil yangilash uchun parametrlar — faqat o'zgartirilgan maydonlarni o'z ichiga oladi.
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

  /// Lokal fayl yo'li — Storage'ga yuklash uchun
  final String? avatarLocalPath;
  final bool? isPrivate;
}
