import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../post/data/providers/post_data_providers.dart';
import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/utils/post_interaction.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ExploreFeedState {
  const ExploreFeedState({
    this.posts = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<Post> posts;
  final bool hasMore;
  final bool isLoadingMore;

  ExploreFeedState copyWith({
    List<Post>? posts,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      ExploreFeedState(
        posts: posts ?? this.posts,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Feed shown when a post is opened from Search/Explore: the tapped post first,
/// then the general feed below it. Family argument is the tapped post id.
class ExploreFeedNotifier extends FamilyAsyncNotifier<ExploreFeedState, String> {
  static const _pageSize = AppConfig.feedPageSize;

  /// Number of raw feed rows fetched so far (excludes the prepended tapped
  /// post) — used as the offset for the next page.
  int _feedOffset = 0;

  String get _initialPostId => arg;
  String? get _currentUserId => ref.read(currentUserIdProvider);

  @override
  Future<ExploreFeedState> build(String initialPostId) async {
    // ref.watch so provider rebuilds reactively on auth change
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const ExploreFeedState(hasMore: false);
    return _loadFeed(initialPostId: initialPostId, userId: userId);
  }

  Future<ExploreFeedState> _loadFeed({
    required String initialPostId,
    required String userId,
  }) async {
    final results = await Future.wait([
      ref.read(getPostUseCaseProvider).call(
            postId: initialPostId,
            currentUserId: userId,
          ),
      ref.read(getFeedUseCaseProvider).call(
            currentUserId: userId,
            limit: _pageSize,
            offset: 0,
          ),
    ]);

    final tapped = switch (results[0] as Result<Post>) {
      Ok(:final value) => value,
      Err() => null, // tapped post unavailable — still show the feed
    };
    final feed = switch (results[1] as Result<List<Post>>) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };

    _feedOffset = feed.length;
    return ExploreFeedState(
      posts: _merge(tapped, feed),
      hasMore: feed.length >= _pageSize,
    );
  }

  /// Puts the tapped post first and drops it from the feed body to avoid a
  /// duplicate if the general feed also contains it.
  List<Post> _merge(Post? tapped, List<Post> feed) {
    if (tapped == null) return feed;
    return [tapped, ...feed.where((p) => p.id != tapped.id)];
  }

  Future<void> refresh() async {
    _feedOffset = 0;
    final userId = _currentUserId;
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _loadFeed(initialPostId: _initialPostId, userId: userId),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    final userId = _currentUserId;
    if (userId == null) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await ref.read(getFeedUseCaseProvider).call(
          currentUserId: userId,
          limit: _pageSize,
          offset: _feedOffset,
        );

    switch (result) {
      case Ok(:final value):
        _feedOffset += value.length;
        final existingIds = {for (final p in current.posts) p.id};
        final fresh = value.where((p) => !existingIds.contains(p.id));
        state = AsyncData(ExploreFeedState(
          posts: [...current.posts, ...fresh],
          hasMore: value.length >= _pageSize,
          isLoadingMore: false,
        ));
      case Err():
        state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  // ── Like / Save ───────────────────────────────────────────────────────────

  void _patchPost(String postId, Post Function(Post) update) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(
      posts: [for (final p in cur.posts) p.id == postId ? update(p) : p],
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
}

final exploreFeedProvider = AsyncNotifierProviderFamily<ExploreFeedNotifier,
    ExploreFeedState, String>(
  ExploreFeedNotifier.new,
);
