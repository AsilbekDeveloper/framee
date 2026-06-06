import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/ui_models.dart';
import '../../../../core/utils/mock_data.dart';

class PostDetailState {
  const PostDetailState({
    this.post,
    this.comments = const [],
    this.isLoading = true,
    this.replyToId,
  });

  final PostModel? post;
  final List<CommentModel> comments;
  final bool isLoading;
  final String? replyToId;

  PostDetailState copyWith({
    PostModel? post,
    List<CommentModel>? comments,
    bool? isLoading,
    String? replyToId,
  }) =>
      PostDetailState(
        post: post ?? this.post,
        comments: comments ?? this.comments,
        isLoading: isLoading ?? this.isLoading,
        replyToId: replyToId ?? this.replyToId,
      );
}

class PostDetailNotifier extends FamilyNotifier<PostDetailState, String> {
  final commentController = TextEditingController();

  @override
  PostDetailState build(String postId) {
    _load(postId);
    return const PostDetailState();
  }

  Future<void> _load(String postId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final post = MockData.posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => MockData.posts.first,
    );
    state = state.copyWith(
      post: post,
      comments: MockData.comments,
      isLoading: false,
    );
  }

  void toggleLike() {
    final post = state.post;
    if (post == null) return;
    state = state.copyWith(
      post: post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      ),
    );
  }

  void toggleCommentLike(String commentId) {
    state = state.copyWith(
      comments: state.comments.map((c) {
        if (c.id != commentId) return c;
        return c.copyWith(
          isLiked: !c.isLiked,
          likesCount: c.isLiked ? c.likesCount - 1 : c.likesCount + 1,
        );
      }).toList(),
    );
  }

  void setReplyTo(String commentId) {
    state = state.copyWith(replyToId: commentId);
    commentController.text = '';
  }

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    commentController.clear();
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: MockData.currentUser,
      text: text,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(comments: [...state.comments, newComment]);
  }
}

final postDetailProvider =
    NotifierProviderFamily<PostDetailNotifier, PostDetailState, String>(
  PostDetailNotifier.new,
);
