import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/failure_message.dart';
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

/// Synchronous [Notifier] — all loading flags live inside [SearchState].
/// [AsyncNotifier] is intentionally avoided to prevent two loading mechanisms
/// (isSearching vs AsyncLoading) from conflicting.
class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    final userId = ref.watch(currentUserIdProvider);
    ref.onDispose(() => _debounce?.cancel());
    if (userId == null) return const SearchState();
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

    // Show cache immediately, then refresh in the background
    final cached = await cache.loadExplore();
    if (cached.isNotEmpty) {
      state = state.copyWith(isLoadingExplore: false, explorePosts: cached);
      // Background refresh to keep the Explore feed up to date
      _backgroundRefreshExplore(userId);
      return;
    }

    AppLogger.d('SearchNotifier: loading explore posts');
    final result = await ref
        .read(getExplorePostsUseCaseProvider)
        .call(currentUserId: userId, limit: AppConfig.explorePageSize);

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
          .call(currentUserId: userId, limit: AppConfig.explorePageSize);
      if (result case Ok(:final value)) {
        state = state.copyWith(explorePosts: value);
        ref.read(postCacheServiceProvider).saveExplore(value);
      }
    } catch (_) {}
  }

  /// Called on every keystroke. Updates the query text immediately so the UI
  /// stays responsive, but debounces the network request to avoid firing one
  /// query per character.
  void search(String query) {
    final trimmed = query.trim();
    _debounce?.cancel();

    if (trimmed.isEmpty) {
      state = state.copyWith(query: '', userResults: const [], isSearching: false);
      return;
    }

    state = state.copyWith(query: trimmed, isSearching: true, clearError: true);
    _debounce = Timer(
      const Duration(milliseconds: AppConfig.searchDebounceMsec),
      () => _performSearch(trimmed),
    );
  }

  Future<void> _performSearch(String query) async {
    final userId = _currentUserId;
    if (userId == null) return;

    AppLogger.d('SearchNotifier: searching "$query"');
    final result = await ref.read(searchUsersUseCaseProvider).call(
          query: query,
          currentUserId: userId,
        );

    // Ignore stale responses — the user may have typed something new while
    // this request was in flight.
    if (state.query != query) return;

    state = switch (result) {
      Ok(:final value) => state.copyWith(
          userResults: value,
          isSearching: false,
          clearError: true,
        ),
      Err(:final failure) => state.copyWith(
          isSearching: false,
          userResults: const [],
          errorMessage: localizedFailure(failure),
        ),
    };
  }

  /// Re-runs the current query immediately (used by the error-state Retry button).
  void retrySearch() {
    final query = state.query;
    if (query.isEmpty) return;
    _debounce?.cancel();
    state = state.copyWith(isSearching: true, clearError: true);
    _performSearch(query);
  }

  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(
      query: '',
      userResults: const [],
      isSearching: false,
      clearError: true,
    );
  }

  Future<void> refreshExplore() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final result = await ref
          .read(getExplorePostsUseCaseProvider)
          .call(currentUserId: userId, limit: AppConfig.explorePageSize);
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
