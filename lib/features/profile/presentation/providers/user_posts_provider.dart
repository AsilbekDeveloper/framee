import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/services/post_cache_service.dart';
import '../../../post/data/providers/post_data_providers.dart';
import '../../../post/domain/entities/post.dart';

/// Loads posts for a specific user.
/// The family argument [String] is the target user ID.
class UserPostsNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String userId) async {
    final cached =
        await ref.read(postCacheServiceProvider).loadUserPosts(userId);
    if (cached.isNotEmpty) {
      AppLogger.d('UserPostsNotifier: $userId loaded from cache');
      Future.microtask(() => _backgroundRefresh(userId));
      return cached;
    }
    AppLogger.d('UserPostsNotifier: loading posts for $userId');
    return _fetchAndSave(userId);
  }

  String? get _currentUserId => ref.read(currentUserIdProvider);

  Future<List<Post>> _fetchAndSave(String userId) async {
    final posts = await _fetch(userId);
    ref.read(postCacheServiceProvider).saveUserPosts(userId, posts);
    return posts;
  }

  Future<List<Post>> _fetch(String userId) async {
    final currentUserId = _currentUserId ?? userId;
    final result = await ref.read(getUserPostsUseCaseProvider).call(
          userId: userId,
          currentUserId: currentUserId,
        );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> _backgroundRefresh(String userId) async {
    try {
      final posts = await _fetchAndSave(userId);
      state = AsyncData(posts);
    } catch (_) {}
  }

  Future<void> refresh() async {
    try {
      final posts = await _fetchAndSave(arg);
      state = AsyncData(posts);
    } catch (e, st) {
      if (!state.hasValue) state = AsyncError(e, st);
    }
  }

  void _patchPost(String postId, Post Function(Post) update) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData([for (final p in cur) p.id == postId ? update(p) : p]);
  }

  Future<void> toggleLike(Post post) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;
    if (state.valueOrNull == null) return;

    final original = post;

    _patchPost(post.id, (p) => p.copyWith(
      isLiked: !p.isLiked,
      likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
    ));

    final result = await ref.read(toggleLikeUseCaseProvider).call(
          postId: post.id,
          currentUserId: currentUserId,
        );

    switch (result) {
      case Ok(:final value):
        _patchPost(post.id, (p) => p.copyWith(
          isLiked: value.isLiked,
          likesCount: value.likesCount,
        ));
      case Err():
        _patchPost(post.id, (p) => p.copyWith(
          isLiked: original.isLiked,
          likesCount: original.likesCount,
        ));
    }
  }

  Future<void> toggleSave(Post post) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;
    if (state.valueOrNull == null) return;

    final original = post;

    _patchPost(post.id, (p) => p.copyWith(isSaved: !p.isSaved));

    final result = await ref.read(toggleSaveUseCaseProvider).call(
          postId: post.id,
          currentUserId: currentUserId,
        );

    if (result is Err) {
      _patchPost(post.id, (p) => p.copyWith(isSaved: original.isSaved));
    }
  }
}

final userPostsProvider =
    AsyncNotifierProviderFamily<UserPostsNotifier, List<Post>, String>(
  UserPostsNotifier.new,
);
