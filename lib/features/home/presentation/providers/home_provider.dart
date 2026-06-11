import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/services/post_cache_service.dart';
import '../../../post/data/providers/post_data_providers.dart';
import '../../../post/domain/entities/post.dart';

// ── Home Notifier ─────────────────────────────────────────────────────────────

/// Manages the home feed posts.
///
/// [build()] loads posts from Supabase.
/// Like and save operations use optimistic updates — the UI updates before the server responds.
class HomeNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final cached = await ref.read(postCacheServiceProvider).loadFeed();
    if (cached.isNotEmpty) {
      // Cache hit — show immediately and refresh in the background
      Future.microtask(_backgroundRefresh);
      return cached;
    }
    // No cache — fetch from network
    return _fetchAndSave();
  }

  String? get _currentUserId =>
      ref.read(currentUserIdProvider);

  Future<List<Post>> _fetchAndSave() async {
    final posts = await _fetchPosts();
    ref.read(postCacheServiceProvider).saveFeed(posts);
    return posts;
  }

  Future<void> _backgroundRefresh() async {
    try {
      final posts = await _fetchPosts();
      state = AsyncData(posts);
      ref.read(postCacheServiceProvider).saveFeed(posts);
    } catch (_) {
      // Offline or error — keep showing cached data
    }
  }

  Future<List<Post>> _fetchPosts({int offset = 0}) async {
    final userId = _currentUserId;
    if (userId == null) {
      AppLogger.w('HomeNotifier: user not authenticated');
      return const [];
    }

    AppLogger.d('HomeNotifier: loading feed — offset:$offset');
    final result = await ref.read(getFeedUseCaseProvider).call(
          currentUserId: userId,
          limit: 20,
          offset: offset,
        );

    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    try {
      final posts = await _fetchPosts();
      state = AsyncData(posts);
      ref.read(postCacheServiceProvider).saveFeed(posts);
    } catch (e, st) {
      // If we already have data, rely on the offline banner and keep the current state
      if (!state.hasValue) state = AsyncError(e, st);
    }
  }

  /// Optimistic like toggle — server xatosi bo'lsa rollback qiladi
  Future<void> toggleLike(String postId) async {
    final prev = state.valueOrNull;
    if (prev == null) return;

    // Optimistic update
    state = AsyncData(prev
        .map((p) => p.id != postId
            ? p
            : p.copyWith(
                isLiked: !p.isLiked,
                likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
              ))
        .toList());

    final userId = _currentUserId;
    if (userId == null) return;

    final result = await ref.read(toggleLikeUseCaseProvider).call(
          postId: postId,
          currentUserId: userId,
        );

    switch (result) {
      case Ok(:final value):
        // Sync with the actual count returned by the server
        state = AsyncData(state.valueOrNull!
            .map((p) => p.id != postId
                ? p
                : p.copyWith(
                    isLiked: value.isLiked,
                    likesCount: value.likesCount,
                  ))
            .toList());
      case Err(:final failure):
        // Rollback
        AppLogger.w('HomeNotifier: toggleLike rollback — ${failure.code}');
        state = AsyncData(prev);
    }
  }

  /// Optimistic save toggle
  Future<void> toggleSave(String postId) async {
    final prev = state.valueOrNull;
    if (prev == null) return;

    // Optimistic update
    state = AsyncData(prev
        .map((p) => p.id != postId ? p : p.copyWith(isSaved: !p.isSaved))
        .toList());

    final userId = _currentUserId;
    if (userId == null) return;

    final result = await ref.read(toggleSaveUseCaseProvider).call(
          postId: postId,
          currentUserId: userId,
        );

    switch (result) {
      case Ok():
        break; // optimistic update was correct
      case Err(:final failure):
        // Rollback
        AppLogger.w('HomeNotifier: toggleSave rollback — ${failure.code}');
        state = AsyncData(prev);
    }
  }

  Future<void> onPostCreated() async {
    await refresh();
  }

  /// Removes a post from the feed after it has been deleted.
  void removePost(String postId) {
    state.whenData((posts) {
      state = AsyncData(posts.where((p) => p.id != postId).toList());
    });
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, List<Post>>(
  HomeNotifier.new,
);
