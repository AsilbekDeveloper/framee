import '../../../../core/errors/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';
import '../dtos/comment_dto.dart';

class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl(this._dataSource);
  final PostRemoteDataSource _dataSource;

  @override
  Future<Result<List<Post>>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _dataSource.getFeed(
      currentUserId: currentUserId,
      limit: limit,
      offset: offset,
    );
    return result.map((dtos) => dtos.map((d) => d.toEntity()).toList());
  }

  @override
  Future<Result<Post>> getPost({
    required String postId,
    required String currentUserId,
  }) async {
    final result = await _dataSource.getPost(
      postId: postId,
      currentUserId: currentUserId,
    );
    return result.map((dto) => dto.toEntity());
  }

  @override
  Future<Result<Post>> createPost(CreatePostParams params) async {
    final result = await _dataSource.createPost(params);
    return result.map((dto) => dto.toEntity());
  }

  @override
  Future<Result<bool>> deletePost({
    required String postId,
    required String currentUserId,
  }) =>
      _dataSource.deletePost(postId: postId, currentUserId: currentUserId);

  @override
  Future<Result<({int likesCount, bool isLiked})>> toggleLike({
    required String postId,
    required String currentUserId,
  }) =>
      _dataSource.toggleLike(postId: postId, currentUserId: currentUserId);

  @override
  Future<Result<bool>> toggleSave({
    required String postId,
    required String currentUserId,
  }) =>
      _dataSource.toggleSave(postId: postId, currentUserId: currentUserId);

  @override
  Future<Result<List<Comment>>> getComments({
    required String postId,
    required String currentUserId,
  }) async {
    final result = await _dataSource.getComments(
      postId: postId,
      currentUserId: currentUserId,
    );
    return result.map((dtos) => _buildCommentTree(dtos));
  }

  @override
  Future<Result<Comment>> addComment(AddCommentParams params) async {
    final result = await _dataSource.addComment(params);
    return result.map((dto) => dto.toEntity());
  }

  @override
  Future<Result<bool>> deleteComment({
    required String commentId,
    required String currentUserId,
  }) =>
      _dataSource.deleteComment(
        commentId: commentId,
        currentUserId: currentUserId,
      );

  @override
  Future<Result<List<Post>>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await _dataSource.getUserPosts(
      userId: userId,
      currentUserId: currentUserId,
      limit: limit,
      offset: offset,
    );
    return result.map((dtos) => dtos.map((d) => d.toEntity()).toList());
  }

  @override
  Future<Result<List<Post>>> getSavedPosts({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await _dataSource.getSavedPosts(
      userId: userId,
      limit: limit,
      offset: offset,
    );
    return result.map((dtos) => dtos.map((d) => d.toEntity()).toList());
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Flat list → nested tree (top-level comments + replies)
  List<Comment> _buildCommentTree(List<CommentDto> dtos) {
    // parentId yo'q → top-level; bor → reply
    final topLevel = dtos.where((d) => d.parentId == null).toList();
    final replies = dtos.where((d) => d.parentId != null).toList();

    return topLevel.map((parent) {
      final childReplies = replies
          .where((r) => r.parentId == parent.id)
          .map((r) => r.toEntity())
          .toList();
      return parent.toEntity(replies: childReplies);
    }).toList();
  }
}
