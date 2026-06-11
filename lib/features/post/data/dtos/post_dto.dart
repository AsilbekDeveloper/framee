import '../../domain/entities/post.dart';

/// Maps JSON from the `get_feed_posts` RPC and the `posts` table to a [Post] entity.
///
/// The RPC returns a flat structure:
/// { id, user_id, image_url, caption, likes_count, comments_count, created_at,
///   author_id, author_username, author_display_name, author_avatar_url,
///   author_is_verified, is_liked, is_saved }
class PostDto {
  const PostDto({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    this.authorIsVerified = false,
    this.imageUrl,
    this.caption,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  final String id;
  final String authorId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final bool authorIsVerified;
  final String? imageUrl;
  final String? caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;

  /// Constructs a [PostDto] from the flat JSON returned by the RPC.
  factory PostDto.fromRpc(Map<String, dynamic> json) => PostDto(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        authorUsername: json['author_username'] as String? ?? '',
        authorDisplayName: json['author_display_name'] as String? ?? '',
        authorAvatarUrl: json['author_avatar_url'] as String?,
        authorIsVerified: json['author_is_verified'] as bool? ?? false,
        imageUrl: json['image_url'] as String?,
        caption: json['caption'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        likesCount: json['likes_count'] as int? ?? 0,
        commentsCount: json['comments_count'] as int? ?? 0,
        isLiked: json['is_liked'] as bool? ?? false,
        isSaved: json['is_saved'] as bool? ?? false,
      );

  /// Constructs a [PostDto] from nested JSON returned by a join query on the posts table.
  factory PostDto.fromJoin(Map<String, dynamic> json) {
    final author = json['profiles'] as Map<String, dynamic>? ?? {};
    return PostDto(
      id: json['id'] as String,
      authorId: json['user_id'] as String,
      authorUsername: author['username'] as String? ?? '',
      authorDisplayName: author['display_name'] as String? ?? '',
      authorAvatarUrl: author['avatar_url'] as String?,
      authorIsVerified: author['is_verified'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
    );
  }

  Post toEntity() => Post(
        id: id,
        author: PostAuthor(
          id: authorId,
          username: authorUsername,
          displayName: authorDisplayName,
          avatarUrl: authorAvatarUrl,
          isVerified: authorIsVerified,
        ),
        imageUrl: imageUrl,
        caption: caption,
        createdAt: createdAt,
        likesCount: likesCount,
        commentsCount: commentsCount,
        isLiked: isLiked,
        isSaved: isSaved,
      );
}
