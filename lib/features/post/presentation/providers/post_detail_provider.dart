import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../post/data/providers/post_data_providers.dart';
import '../../../post/domain/entities/post.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class PostDetailState {
  const PostDetailState({
    this.post,
    this.comments = const [],
    this.isLoadingComments = false,
    this.replyToId,
    this.replyToUsername,
    this.errorMessage,
  });

  final Post? post;
  final List<Comment> comments;
  final bool isLoadingComments;
  final String? replyToId;
  final String? replyToUsername;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  PostDetailState copyWith({
    Post? post,
    List<Comment>? comments,
    bool? isLoadingComments,
    String? replyToId,
    String? replyToUsername,
    String? errorMessage,
    bool clearError = false,
    bool clearReply = false,
  }) =>
      PostDetailState(
        post: post ?? this.post,
        comments: comments ?? this.comments,
        isLoadingComments: isLoadingComments ?? this.isLoadingComments,
        replyToId: clearReply ? null : (replyToId ?? this.replyToId),
        replyToUsername:
            clearReply ? null : (replyToUsername ?? this.replyToUsername),
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PostDetailNotifier extends FamilyAsyncNotifier<PostDetailState, String> {
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

  String get _postId => arg;
  String? get _currentUserId => ref.read(currentUserIdProvider);

  @override
  Future<PostDetailState> build(String postId) async {
    ref.onDispose(() {
      commentController.dispose();
      commentFocusNode.dispose();
    });

    final userId = _currentUserId;
    if (userId == null) return const PostDetailState();

    AppLogger.d('PostDetailNotifier: loading — $postId');

    final results = await Future.wait([
      ref.read(getPostUseCaseProvider).call(
            postId: postId,
            currentUserId: userId,
          ),
      ref.read(getCommentsUseCaseProvider).call(
            postId: postId,
            currentUserId: userId,
          ),
    ]);

    final postResult = results[0] as Result<Post>;
    final commentsResult = results[1] as Result<List<Comment>>;

    final post = switch (postResult) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };

    final comments = switch (commentsResult) {
      Ok(:final value) => value,
      Err() => const <Comment>[],
    };

    return PostDetailState(post: post, comments: comments);
  }

  // ── Like ────────────────────────────────────────────────────────────────────

  Future<void> toggleLike() async {
    final current = state.valueOrNull;
    final post = current?.post;
    if (post == null) return;

    final userId = _currentUserId;
    if (userId == null) return;

    final optimistic = post.copyWith(
      isLiked: !post.isLiked,
      likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    state = AsyncData(current!.copyWith(post: optimistic));

    final result = await ref.read(toggleLikeUseCaseProvider).call(
          postId: post.id,
          currentUserId: userId,
        );

    switch (result) {
      case Ok(:final value):
        state = AsyncData(current.copyWith(
          post: post.copyWith(
            isLiked: value.isLiked,
            likesCount: value.likesCount,
          ),
        ));
      case Err(:final failure):
        AppLogger.w('PostDetail: toggleLike rollback — ${failure.code}');
        state = AsyncData(current.copyWith(post: post));
    }
  }

  // ── Comment Like ────────────────────────────────────────────────────────────

  Future<void> toggleCommentLike(String commentId) async {
    // Optimistic update
    state.whenData((data) {
      state = AsyncData(data.copyWith(
        comments: _mapComments(data.comments, commentId, (c) => c.copyWith(
              isLiked: !c.isLiked,
              likesCount: c.isLiked ? c.likesCount - 1 : c.likesCount + 1,
            )),
      ));
    });
    // TODO: persist comment like to the server (comment_likes table)
  }

  // ── Reply ───────────────────────────────────────────────────────────────────

  void setReplyTo(String commentId, String username) {
    state.whenData((data) {
      state = AsyncData(data.copyWith(
        replyToId: commentId,
        replyToUsername: username,
      ));
    });
    commentController.clear();
    commentFocusNode.requestFocus();
  }

  void clearReply() {
    state.whenData((data) {
      state = AsyncData(data.copyWith(clearReply: true));
    });
  }

  // ── Add Comment ─────────────────────────────────────────────────────────────

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final userId = _currentUserId;
    if (userId == null) return;

    final current = state.valueOrNull;
    if (current == null) return;

    commentController.clear();

    final params = AddCommentParams(
      postId: _postId,
      userId: userId,
      text: text,
      parentId: current.replyToId,
    );

    final result = await ref.read(addCommentUseCaseProvider).call(params);

    switch (result) {
      case Ok(:final value):
        AppLogger.d('PostDetail: comment added — parentId:${value.parentId}');
        List<Comment> updatedComments;
        if (value.parentId != null) {
          // Reply → nest inside the parent comment's replies list
          updatedComments = _nestReply(current.comments, value);
        } else {
          // Top-level comment → listning oxiriga
          updatedComments = [...current.comments, value];
        }
        final updatedPost = current.post?.copyWith(
          commentsCount: (current.post?.commentsCount ?? 0) + 1,
        );
        state = AsyncData(current.copyWith(
          comments: updatedComments,
          post: updatedPost,
          clearReply: true,
        ));
      case Err(:final failure):
        AppLogger.w('PostDetail: comment error — ${failure.code}');
        state = AsyncData(current.copyWith(errorMessage: failure.message));
    }
  }

  // ── Delete Comment ──────────────────────────────────────────────────────────

  Future<void> deleteComment(String commentId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic: remove from list immediately before server round-trip
    final updatedComments = _removeComment(current.comments, commentId);
    final removedCount = _countRemoved(current.comments, updatedComments);
    state = AsyncData(current.copyWith(
      comments: updatedComments,
      post: current.post?.copyWith(
        commentsCount: (current.post?.commentsCount ?? 1) - removedCount,
      ),
    ));

    final result = await ref.read(deleteCommentUseCaseProvider).call(
          commentId: commentId,
          currentUserId: userId,
        );

    if (result is Err) {
      // Rollback
      AppLogger.w('PostDetail: deleteComment rollback');
      state = AsyncData(current);
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> toggleSave() async {
    final current = state.valueOrNull;
    final post = current?.post;
    if (post == null) return;

    final userId = _currentUserId;
    if (userId == null) return;

    state = AsyncData(current!.copyWith(
      post: post.copyWith(isSaved: !post.isSaved),
    ));

    final result = await ref.read(toggleSaveUseCaseProvider).call(
          postId: post.id,
          currentUserId: userId,
        );

    if (result is Err) {
      state = AsyncData(current.copyWith(post: post));
    }
  }

  // ── Delete Post ─────────────────────────────────────────────────────────────

  Future<bool> deletePost() async {
    final userId = _currentUserId;
    final postId = state.valueOrNull?.post?.id;
    if (userId == null || postId == null) return false;

    final result = await ref.read(deletePostUseCaseProvider).call(
          postId: postId,
          currentUserId: userId,
        );

    return switch (result) {
      Ok() => true,
      Err(:final failure) => throw failure,
    };
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Inserts a reply into the correct parent comment's replies list (recursive, 1 level deep).
  List<Comment> _nestReply(List<Comment> comments, Comment reply) {
    return comments.map((c) {
      if (c.id == reply.parentId) {
        return c.copyWith(replies: [...c.replies, reply]);
      }
      // Also search inside nested replies (1 level deep)
      if (c.replies.isNotEmpty) {
        return c.copyWith(replies: _nestReply(c.replies, reply));
      }
      return c;
    }).toList();
  }

  /// Removes a comment or its reply by ID.
  List<Comment> _removeComment(List<Comment> comments, String commentId) {
    return comments
        .where((c) => c.id != commentId)
        .map((c) => c.replies.isEmpty
            ? c
            : c.copyWith(
                replies: c.replies
                    .where((r) => r.id != commentId)
                    .toList(),
              ))
        .toList();
  }

  int _countRemoved(List<Comment> before, List<Comment> after) {
    int count(List<Comment> list) =>
        list.fold(0, (sum, c) => sum + 1 + c.replies.length);
    return count(before) - count(after);
  }

  /// Applies [transform] to the comment matching [commentId], including replies.
  List<Comment> _mapComments(
    List<Comment> comments,
    String commentId,
    Comment Function(Comment) transform,
  ) {
    return comments.map((c) {
      if (c.id == commentId) return transform(c);
      if (c.replies.isEmpty) return c;
      return c.copyWith(
        replies: c.replies.map((r) {
          if (r.id == commentId) return transform(r);
          return r;
        }).toList(),
      );
    }).toList();
  }
}

final postDetailProvider =
    AsyncNotifierProviderFamily<PostDetailNotifier, PostDetailState, String>(
  PostDetailNotifier.new,
);
