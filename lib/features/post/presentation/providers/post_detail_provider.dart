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
    this.errorMessage,
  });

  final Post? post;
  final List<Comment> comments;
  final bool isLoadingComments;
  final String? replyToId;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  PostDetailState copyWith({
    Post? post,
    List<Comment>? comments,
    bool? isLoadingComments,
    String? replyToId,
    String? errorMessage,
    bool clearError = false,
    bool clearReply = false,
  }) =>
      PostDetailState(
        post: post ?? this.post,
        comments: comments ?? this.comments,
        isLoadingComments: isLoadingComments ?? this.isLoadingComments,
        replyToId: clearReply ? null : (replyToId ?? this.replyToId),
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PostDetailNotifier extends FamilyAsyncNotifier<PostDetailState, String> {
  final commentController = TextEditingController();

  String get _postId => arg;
  String? get _currentUserId =>
      ref.read(currentUserIdProvider);

  @override
  Future<PostDetailState> build(String postId) async {
    ref.onDispose(commentController.dispose);

    final userId = _currentUserId;
    if (userId == null) {
      return const PostDetailState();
    }

    AppLogger.d('PostDetailNotifier: yuklanmoqda — $postId');

    // Post va comments'ni parallel yuklaymiz
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
      Err() => const <Comment>[], // izohlar yuklanmasa ham post ko'rinsin
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

    // Optimistic update
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
        // Server'dan haqiqiy count
        state = AsyncData(current.copyWith(
          post: post.copyWith(
            isLiked: value.isLiked,
            likesCount: value.likesCount,
          ),
        ));
      case Err(:final failure):
        // Rollback
        AppLogger.w('PostDetail: toggleLike rollback — ${failure.code}');
        state = AsyncData(current.copyWith(post: post));
    }
  }

  // ── Comment Like ────────────────────────────────────────────────────────────

  void toggleCommentLike(String commentId) {
    state.whenData((data) {
      state = AsyncData(data.copyWith(
        comments: data.comments.map((c) {
          if (c.id != commentId) return c;
          return c.copyWith(
            isLiked: !c.isLiked,
            likesCount: c.isLiked ? c.likesCount - 1 : c.likesCount + 1,
          );
        }).toList(),
      ));
    });
    // TODO: server'ga comment like yuborish
  }

  // ── Reply ───────────────────────────────────────────────────────────────────

  void setReplyTo(String commentId) {
    state.whenData((data) {
      state = AsyncData(data.copyWith(replyToId: commentId));
    });
    commentController.text = '';
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
        AppLogger.d('PostDetail: izoh qo\'shildi');
        // Yangi izohni listga qo'shamiz
        final updatedComments = [...current.comments, value];
        // Post commentsCount'ni ham yangilaymiz
        final updatedPost = current.post?.copyWith(
          commentsCount: (current.post?.commentsCount ?? 0) + 1,
        );
        state = AsyncData(current.copyWith(
          comments: updatedComments,
          post: updatedPost,
          clearReply: true,
        ));
      case Err(:final failure):
        AppLogger.w('PostDetail: izoh xatosi — ${failure.code}');
        state = AsyncData(current.copyWith(errorMessage: failure.message));
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> toggleSave() async {
    final current = state.valueOrNull;
    final post = current?.post;
    if (post == null) return;

    final userId = _currentUserId;
    if (userId == null) return;

    // Optimistic update
    state = AsyncData(current!.copyWith(
      post: post.copyWith(isSaved: !post.isSaved),
    ));

    final result = await ref.read(toggleSaveUseCaseProvider).call(
          postId: post.id,
          currentUserId: userId,
        );

    if (result is Err) {
      // Rollback
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
}

final postDetailProvider =
    AsyncNotifierProviderFamily<PostDetailNotifier, PostDetailState, String>(
  PostDetailNotifier.new,
);
