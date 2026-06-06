// ─── User UI Model ─────────────────────────────────────────────────────────────
class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.bio,
    this.website,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.isPrivate = false,
    this.isVerified = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? website;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isPrivate;
  final bool isVerified;

  String get initials => displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : username.isNotEmpty
          ? username[0].toUpperCase()
          : '?';

  // Sentinel to distinguish "not passed" from "explicitly null"
  static const _unset = Object();

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    Object? email = _unset,
    Object? avatarUrl = _unset,
    Object? bio = _unset,
    Object? website = _unset,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    bool? isPrivate,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email == _unset ? this.email : email as String?,
      avatarUrl: avatarUrl == _unset ? this.avatarUrl : avatarUrl as String?,
      bio: bio == _unset ? this.bio : bio as String?,
      website: website == _unset ? this.website : website as String?,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isPrivate: isPrivate ?? this.isPrivate,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

// ─── Post UI Model ─────────────────────────────────────────────────────────────
enum PostType { all, textOnly, imageOnly }

class PostModel {
  const PostModel({
    required this.id,
    required this.author,
    this.imageUrl,
    this.caption,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.type = PostType.all,
  });

  final String id;
  final UserModel author;
  final String? imageUrl;
  final String? caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final PostType type;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasCaption => caption != null && caption!.isNotEmpty;

  PostModel copyWith({
    String? id,
    UserModel? author,
    String? imageUrl,
    String? caption,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    PostType? type,
  }) {
    return PostModel(
      id: id ?? this.id,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      type: type ?? this.type,
    );
  }
}

// ─── Comment UI Model ──────────────────────────────────────────────────────────
class CommentModel {
  const CommentModel({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });

  final String id;
  final UserModel author;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final List<CommentModel> replies;

  CommentModel copyWith({
    String? id,
    UserModel? author,
    String? text,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }
}

// ─── Notification UI Model ─────────────────────────────────────────────────────
enum NotificationType { like, follow, comment }

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.actor,
    this.postImageUrl,
    this.commentText,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final UserModel actor;
  final String? postImageUrl;
  final String? commentText;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    UserModel? actor,
    String? postImageUrl,
    String? commentText,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      actor: actor ?? this.actor,
      postImageUrl: postImageUrl ?? this.postImageUrl,
      commentText: commentText ?? this.commentText,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
