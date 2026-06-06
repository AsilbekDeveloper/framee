import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/ui_models.dart';
import '../../../../core/utils/mock_data.dart';

class HomeState {
  const HomeState({
    this.posts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<PostModel> posts;
  final bool isLoading;
  final String? errorMessage;

  HomeState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? errorMessage,
  }) =>
      HomeState(
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    _loadPosts();
    return const HomeState(isLoading: true);
  }

  Future<void> _loadPosts() async {
    // Replace with: supabase.from('posts').select('*, profiles(*)').order(...)
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(posts: MockData.posts, isLoading: false);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadPosts();
  }

  void toggleLike(String postId) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(
          isLiked: !p.isLiked,
          likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
        );
      }).toList(),
    );
  }

  void toggleSave(String postId) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(isSaved: !p.isSaved);
      }).toList(),
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
