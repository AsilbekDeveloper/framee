import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/services/post_cache_service.dart';
import '../../../post/data/providers/post_data_providers.dart';
import '../../../post/domain/entities/post.dart';

// ── Home Notifier ─────────────────────────────────────────────────────────────

/// Feed postlarini boshqaradi.
///
/// [build()] Supabase'dan postlarni yuklaydi.
/// Optimistic like/save — server javobidan oldin UI'ni yangilaydi.
class HomeNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final cached = await ref.read(postCacheServiceProvider).loadFeed();
    if (cached.isNotEmpty) {
      // Cache bor — darhol ko'rsatamiz, background'da yangilaymiz
      Future.microtask(_backgroundRefresh);
      return cached;
    }
    // Cache yo'q — networkdan yuklaymiz
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
      // Offline yoki xato — cache ko'rsatilgan holda qolamiz
    }
  }

  Future<List<Post>> _fetchPosts({int offset = 0}) async {
    final userId = _currentUserId;
    if (userId == null) {
      AppLogger.w('HomeNotifier: foydalanuvchi kirmagan');
      return const [];
    }

    AppLogger.d('HomeNotifier: feed yuklanmoqda — offset:$offset');
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
      // Data bor bo'lsa — offline bannerga ishonib, stateni o'zgartirmaymiz
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
        // Server'dan haqiqiy count bilan yangilaymiz
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
        break; // optimistic update to'g'ri edi
      case Err(:final failure):
        // Rollback
        AppLogger.w('HomeNotifier: toggleSave rollback — ${failure.code}');
        state = AsyncData(prev);
    }
  }

  Future<void> onPostCreated() async {
    await refresh();
  }

  /// Feed'dan postni olib tashlaydi (o'chirilganda)
  void removePost(String postId) {
    state.whenData((posts) {
      state = AsyncData(posts.where((p) => p.id != postId).toList());
    });
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, List<Post>>(
  HomeNotifier.new,
);
