import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/services/post_cache_service.dart';
import '../../../post/data/providers/post_data_providers.dart';
import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/utils/post_interaction.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class HomeFeedState {
  const HomeFeedState({
    this.posts = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<Post> posts;
  final bool hasMore;
  final bool isLoadingMore;

  HomeFeedState copyWith({
    List<Post>? posts,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      HomeFeedState(
        posts: posts ?? this.posts,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class HomeNotifier extends AsyncNotifier<HomeFeedState> {
  static const _pageSize = AppConfig.feedPageSize;

  @override
  Future<HomeFeedState> build() async {
    ref.watch(currentUserIdProvider);
    final cached = await ref.read(postCacheServiceProvider).loadFeed();
    if (cached.isNotEmpty) {
      Future.microtask(_backgroundRefresh);
      return HomeFeedState(
        posts: cached,
        hasMore: cached.length >= _pageSize,
      );
    }
    return _fetchAndSave();
  }

  String? get _currentUserId => ref.read(currentUserIdProvider);

  Future<HomeFeedState> _fetchAndSave({int offset = 0}) async {
    final posts = await _fetchPosts(offset: offset);
    if (offset == 0) ref.read(postCacheServiceProvider).saveFeed(posts);
    return HomeFeedState(
      posts: posts,
      hasMore: posts.length >= _pageSize,
    );
  }

  Future<void> _backgroundRefresh() async {
    try {
      final feedState = await _fetchAndSave();
      state = AsyncData(feedState);
    } catch (_) {
      // Offline or error — keep cached data
    }
  }

  Future<List<Post>> _fetchPosts({int offset = 0}) async {
    final userId = _currentUserId;
    if (userId == null) {
      AppLogger.w('HomeNotifier: user not authenticated');
      return const [];
    }

    AppLogger.d('HomeNotifier: loading following feed — offset:$offset');
    final result = await ref.read(getFollowingFeedUseCaseProvider).call(
          currentUserId: userId,
          limit: _pageSize,
          offset: offset,
        );

    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    try {
      final feedState = await _fetchAndSave();
      state = AsyncData(feedState);
    } catch (e, st) {
      if (!state.hasValue) state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final newPosts = await _fetchPosts(offset: current.posts.length);
      final combined = [...current.posts, ...newPosts];
      state = AsyncData(HomeFeedState(
        posts: combined,
        hasMore: newPosts.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (_) {
      // On error, just stop the spinner — keep existing posts
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Replaces a single post (matched by id) in the current feed, leaving every
  /// other post — including any loaded concurrently — untouched.
  void _patchPost(String postId, Post Function(Post) update) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(
      posts: [
        for (final p in cur.posts) p.id == postId ? update(p) : p,
      ],
    ));
  }

  Post? _findPost(String postId) {
    for (final p in state.valueOrNull?.posts ?? const <Post>[]) {
      if (p.id == postId) return p;
    }
    return null;
  }

  Future<void> toggleLike(String postId) async {
    final original = _findPost(postId);
    if (original == null) return;
    final userId = _currentUserId;
    if (userId == null) return;
    await performToggleLike(
      ref: ref,
      postId: postId,
      currentUserId: userId,
      original: original,
      patchPost: (update) => _patchPost(postId, update),
    );
  }

  Future<void> toggleSave(String postId) async {
    final original = _findPost(postId);
    if (original == null) return;
    final userId = _currentUserId;
    if (userId == null) return;
    await performToggleSave(
      ref: ref,
      postId: postId,
      currentUserId: userId,
      original: original,
      patchPost: (update) => _patchPost(postId, update),
    );
  }

  Future<void> deletePost(String postId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final prev = state.valueOrNull;
    if (prev == null) return;

    state = AsyncData(prev.copyWith(
      posts: prev.posts.where((p) => p.id != postId).toList(),
    ));

    final result = await ref.read(deletePostUseCaseProvider).call(
          postId: postId,
          currentUserId: userId,
        );

    switch (result) {
      case Ok():
        break;
      case Err(:final failure):
        AppLogger.w('HomeNotifier: deletePost failed — restoring feed');
        state = AsyncData(prev);
        throw failure;
    }
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeFeedState>(
  HomeNotifier.new,
);
