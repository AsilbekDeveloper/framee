/// Domain entities for the post feature.
///
/// [PostAuthor]        — denormalized author snapshot stored alongside a post
/// [Post]              — core post entity
/// [Comment]           — comment entity (may contain nested replies)
/// [CreatePostParams]  — input parameters for creating a post
/// [AddCommentParams]  — input parameters for adding a comment
library;

// ─── PostAuthor ───────────────────────────────────────────────────────────────

/// Denormalized author snapshot stored with each post.
/// Kept separate from Profile so the feed can load without an extra join.
class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;

  String get initials => displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : username.isNotEmpty
          ? username[0].toUpperCase()
          : '?';

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'isVerified': isVerified,
      };

  factory PostAuthor.fromJson(Map<String, dynamic> j) => PostAuthor(
        id: j['id'] as String,
        username: j['username'] as String,
        displayName: j['displayName'] as String,
        avatarUrl: j['avatarUrl'] as String?,
        isVerified: j['isVerified'] as bool? ?? false,
      );
}

// ─── Post ─────────────────────────────────────────────────────────────────────

class Post {
  const Post({
    required this.id,
    required this.author,
    this.imageUrl,
    this.caption,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  final String id;
  final PostAuthor author;
  final String? imageUrl;
  final String? caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasCaption => caption != null && caption!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.toJson(),
        'imageUrl': imageUrl,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'isLiked': isLiked,
        'isSaved': isSaved,
      };

  factory Post.fromJson(Map<String, dynamic> j) => Post(
        id: j['id'] as String,
        author: PostAuthor.fromJson(j['author'] as Map<String, dynamic>),
        imageUrl: j['imageUrl'] as String?,
        caption: j['caption'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
        likesCount: j['likesCount'] as int? ?? 0,
        commentsCount: j['commentsCount'] as int? ?? 0,
        isLiked: j['isLiked'] as bool? ?? false,
        isSaved: j['isSaved'] as bool? ?? false,
      );

  static const _unset = Object();

  Post copyWith({
    String? id,
    PostAuthor? author,
    Object? imageUrl = _unset,
    Object? caption = _unset,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
  }) =>
      Post(
        id: id ?? this.id,
        author: author ?? this.author,
        imageUrl: imageUrl == _unset ? this.imageUrl : imageUrl as String?,
        caption: caption == _unset ? this.caption : caption as String?,
        createdAt: createdAt ?? this.createdAt,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount ?? this.commentsCount,
        isLiked: isLiked ?? this.isLiked,
        isSaved: isSaved ?? this.isSaved,
      );
}

// ─── Comment ─────────────────────────────────────────────────────────────────

class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.parentId,
    this.replies = const [],
  });

  final String id;
  final String postId;
  final PostAuthor author;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final String? parentId;
  final List<Comment> replies;

  Comment copyWith({
    String? id,
    String? postId,
    PostAuthor? author,
    String? text,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
    String? parentId,
    List<Comment>? replies,
  }) =>
      Comment(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        author: author ?? this.author,
        text: text ?? this.text,
        createdAt: createdAt ?? this.createdAt,
        likesCount: likesCount ?? this.likesCount,
        isLiked: isLiked ?? this.isLiked,
        parentId: parentId ?? this.parentId,
        replies: replies ?? this.replies,
      );
}

// ─── Params ───────────────────────────────────────────────────────────────────

class CreatePostParams {
  const CreatePostParams({
    required this.userId,
    this.imageLocalPath,
    this.caption,
  }) : assert(
          imageLocalPath != null || (caption != null && caption != ''),
          'Post must have either an image or a caption',
        );

  final String userId;

  /// Local file path, or null for text-only posts.
  final String? imageLocalPath;

  /// Up to 2 200 characters.
  final String? caption;
}

class AddCommentParams {
  const AddCommentParams({
    required this.postId,
    required this.userId,
    required this.text,
    this.parentId,
  });

  final String postId;
  final String userId;

  /// Max 500 characters.
  final String text;

  /// Parent comment ID if this is a reply; null for top-level comments.
  final String? parentId;
}

class GetFeedParams {
  const GetFeedParams({
    this.limit = 20,
    this.offset = 0,
  });

  final int limit;
  final int offset;
}
