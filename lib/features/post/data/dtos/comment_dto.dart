import '../../domain/entities/post.dart';

/// Maps JSON from the Supabase `comments` table to a [Comment] entity.
///
/// Query: comments + profiles join + comment_likes join (for is_liked)
class CommentDto {
  const CommentDto({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorUsername,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.parentId,
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final String? parentId;

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    final author = json['profiles'] as Map<String, dynamic>? ?? {};
    return CommentDto(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['user_id'] as String,
      authorUsername: author['username'] as String? ?? '',
      authorDisplayName: author['display_name'] as String? ?? '',
      authorAvatarUrl: author['avatar_url'] as String?,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      parentId: json['parent_id'] as String?,
    );
  }

  Comment toEntity({List<Comment> replies = const []}) => Comment(
        id: id,
        postId: postId,
        author: PostAuthor(
          id: authorId,
          username: authorUsername,
          displayName: authorDisplayName,
          avatarUrl: authorAvatarUrl,
        ),
        text: text,
        createdAt: createdAt,
        likesCount: likesCount,
        isLiked: isLiked,
        parentId: parentId,
        replies: replies,
      );
}
