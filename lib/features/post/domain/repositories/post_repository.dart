import '../../../../core/errors/result.dart';
import '../entities/post.dart';

/// Repository interface for the post domain.
///
/// The data layer implements this interface.
/// The domain layer only depends on this abstraction — it has no knowledge of Supabase or any backend.
abstract interface class PostRepository {
  // ── Feed ───────────────────────────────────────────────────────────────────

  /// Returns feed posts for the current user.
  /// (Future: only from followed users; currently all public posts.)
  Future<Result<List<Post>>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  });

  // ── Post CRUD ──────────────────────────────────────────────────────────────

  /// Loads a single post by ID.
  Future<Result<Post>> getPost({
    required String postId,
    required String currentUserId,
  });

  /// Creates a new post (image upload + DB insert).
  Future<Result<Post>> createPost(CreatePostParams params);

  /// Deletes a post (owner only).
  Future<Result<bool>> deletePost({
    required String postId,
    required String currentUserId,
  });

  // ── Like / Save ────────────────────────────────────────────────────────────

  /// Toggles a like. Returns the updated [likesCount] and [isLiked] from the server.
  Future<Result<({int likesCount, bool isLiked})>> toggleLike({
    required String postId,
    required String currentUserId,
  });

  /// Toggles the saved state of a post for the current user. Returns the new saved state.
  Future<Result<bool>> toggleSave({
    required String postId,
    required String currentUserId,
  });

  // ── Comments ───────────────────────────────────────────────────────────────

  /// Loads the comment list for a post, including nested replies.
  Future<Result<List<Comment>>> getComments({
    required String postId,
    required String currentUserId,
  });

  /// Adds a new comment (or reply) to a post.
  Future<Result<Comment>> addComment(AddCommentParams params);

  /// Deletes a comment (comment owner or post owner only).
  Future<Result<bool>> deleteComment({
    required String commentId,
    required String currentUserId,
  });

  /// Toggles a like on a comment. Returns the new liked state.
  Future<Result<bool>> toggleCommentLike({
    required String commentId,
    required String currentUserId,
  });

  // ── User / Saved Posts ─────────────────────────────────────────────────────

  /// Returns posts created by a specific user.
  Future<Result<List<Post>>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });

  /// Returns posts saved (bookmarked) by the current user.
  Future<Result<List<Post>>> getSavedPosts({
    required String userId,
    int limit = 30,
    int offset = 0,
  });
}
