import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/services/post_cache_service.dart';
import '../../../follow/data/providers/follow_data_providers.dart';
import '../../../follow/domain/entities/follow.dart';
import '../../../post/domain/entities/post.dart';
import '../../data/providers/search_data_providers.dart';
import '../../domain/entities/search_result.dart';

// ── Search State ──────────────────────────────────────────────────────────────

class SearchState {
  const SearchState({
    this.query = '',
    this.userResults = const [],
    this.explorePosts = const [],
    this.isSearching = false,
    this.isLoadingExplore = false,
    this.errorMessage,
  });

  final String query;
  final List<SearchUser> userResults;
  final List<Post> explorePosts;
  final bool isSearching;
  final bool isLoadingExplore;
  final String? errorMessage;

  bool get isQueryActive => query.isNotEmpty;

  SearchState copyWith({
    String? query,
    List<SearchUser>? userResults,
    List<Post>? explorePosts,
    bool? isSearching,
    bool? isLoadingExplore,
    String? errorMessage,
    bool clearError = false,
  }) =>
      SearchState(
        query: query ?? this.query,
        userResults: userResults ?? this.userResults,
        explorePosts: explorePosts ?? this.explorePosts,
        isSearching: isSearching ?? this.isSearching,
        isLoadingExplore: isLoadingExplore ?? this.isLoadingExplore,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

// ── Search Notifier ───────────────────────────────────────────────────────────

/// [Notifier<SearchState>] — barcha loading holatlari SearchState ichida.
/// AsyncNotifier ishlatilmaydi chunki isSearching/isLoadingExplore allaqachon
/// state ichida bor — ikki xil loading mexanizmi aralashib ketmasin.
class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    // Explore'ni async yuklash — state sync boshlaydi, loading flag bilan
    Future.microtask(_loadExplore);
    return const SearchState(isLoadingExplore: true);
  }

  String? get _currentUserId => ref.read(currentUserIdProvider);

  Future<void> _loadExplore() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(isLoadingExplore: false);
      return;
    }

    final cache = ref.read(postCacheServiceProvider);

    // Cache bor — darhol ko'rsatamiz
    final cached = await cache.loadExplore();
    if (cached.isNotEmpty) {
      state = state.copyWith(isLoadingExplore: false, explorePosts: cached);
      // Background yangilash
      _backgroundRefreshExplore(userId);
      return;
    }

    AppLogger.d('SearchNotifier: explore yuklanmoqda');
    final result = await ref
        .read(getExplorePostsUseCaseProvider)
        .call(currentUserId: userId, limit: 30);

    if (result case Ok(:final value)) {
      state = state.copyWith(isLoadingExplore: false, explorePosts: value);
      cache.saveExplore(value);
    } else {
      state = state.copyWith(isLoadingExplore: false);
    }
  }

  Future<void> _backgroundRefreshExplore(String userId) async {
    try {
      final result = await ref
          .read(getExplorePostsUseCaseProvider)
          .call(currentUserId: userId, limit: 30);
      if (result case Ok(:final value)) {
        state = state.copyWith(explorePosts: value);
        ref.read(postCacheServiceProvider).saveExplore(value);
      }
    } catch (_) {}
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      state = state.copyWith(query: '', userResults: const []);
      return;
    }

    final userId = _currentUserId;
    if (userId == null) return;

    state = state.copyWith(query: trimmed, isSearching: true, clearError: true);

    AppLogger.d('SearchNotifier: "$trimmed" qidirish');
    final result = await ref.read(searchUsersUseCaseProvider).call(
          query: trimmed,
          currentUserId: userId,
        );

    state = switch (result) {
      Ok(:final value) => state.copyWith(
          userResults: value,
          isSearching: false,
        ),
      Err(:final failure) => state.copyWith(
          isSearching: false,
          errorMessage: failure.message,
        ),
    };
  }

  void clearSearch() {
    state = state.copyWith(query: '', userResults: const []);
  }

  Future<void> refreshExplore() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final result = await ref
          .read(getExplorePostsUseCaseProvider)
          .call(currentUserId: userId, limit: 30);
      if (result case Ok(:final value)) {
        state = state.copyWith(explorePosts: value);
        ref.read(postCacheServiceProvider).saveExplore(value);
      }
    } catch (_) {}
  }

  /// Optimistic follow toggle
  Future<void> toggleFollow(String targetUserId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final target = state.userResults
        .cast<SearchUser?>()
        .firstWhere((u) => u?.id == targetUserId, orElse: () => null);
    if (target == null) return;

    final wasFollowing = target.isFollowing || target.isRequested;

    _updateUserStatus(
        targetUserId, wasFollowing ? FollowStatus.none : FollowStatus.following);

    if (wasFollowing) {
      final result = await ref.read(unfollowUserUseCaseProvider).call(
            currentUserId: userId,
            targetUserId: targetUserId,
          );
      if (result.isErr) _updateUserStatus(targetUserId, target.followStatus);
    } else {
      final result = await ref.read(followUserUseCaseProvider).call(
            currentUserId: userId,
            targetUserId: targetUserId,
          );
      switch (result) {
        case Ok(:final value):
          _updateUserStatus(targetUserId, value);
        case Err():
          _updateUserStatus(targetUserId, target.followStatus);
      }
    }
  }

  void _updateUserStatus(String userId, FollowStatus status) {
    state = state.copyWith(
      userResults: state.userResults
          .map((u) => u.id == userId ? u.copyWith(followStatus: status) : u)
          .toList(),
    );
  }
}

final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
