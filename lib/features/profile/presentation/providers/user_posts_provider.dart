import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/services/post_cache_service.dart';
import '../../../post/data/providers/post_data_providers.dart';
import '../../../post/domain/entities/post.dart';

/// Biror foydalanuvchining postlarini yuklovchi provider.
/// [String] = targetUserId
class UserPostsNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String userId) async {
    final cached =
        await ref.read(postCacheServiceProvider).loadUserPosts(userId);
    if (cached.isNotEmpty) {
      AppLogger.d('UserPostsNotifier: $userId cache\'dan yuklandi');
      Future.microtask(() => _backgroundRefresh(userId));
      return cached;
    }
    AppLogger.d('UserPostsNotifier: $userId postlari yuklanmoqda');
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
}

final userPostsProvider =
    AsyncNotifierProviderFamily<UserPostsNotifier, List<Post>, String>(
  UserPostsNotifier.new,
);
