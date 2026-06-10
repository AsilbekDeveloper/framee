import '../../domain/entities/profile.dart';

/// Supabase `profiles` jadvalidagi JSON → domain [Profile] entity'ga mapping.
/// Faqat data qatlamida ishlatiladi — domain qatlamiga chiqmaydi.
class ProfileDto {
  const ProfileDto({
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
  /// Viewer tomonidan follow qilinganmi — `follows` jadvalidan keladigan derived field
  final bool isFollowing;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory ProfileDto.fromJson(
    Map<String, dynamic> json, {
    bool isFollowing = false,
  }) =>
      ProfileDto(
        id: json['id'] as String,
        username: json['username'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        website: json['website'] as String?,
        postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
        followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
        followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
        isPrivate: json['is_private'] as bool? ?? false,
        isVerified: json['is_verified'] as bool? ?? false,
        isFollowing: isFollowing,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (bio != null) 'bio': bio,
        if (website != null) 'website': website,
        'is_private': isPrivate,
      };

  Profile toEntity() => Profile(
        id: id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        bio: bio,
        website: website,
        postsCount: postsCount,
        followersCount: followersCount,
        followingCount: followingCount,
        isPrivate: isPrivate,
        isVerified: isVerified,
        isFollowing: isFollowing,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
