import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/post/domain/entities/post.dart';

/// Post ma'lumotlarini SharedPreferences'ga JSON sifatida saqlaydi.
/// Xatolik bo'lsa ilovani to'xtatmaydi — try/catch bilan himoyalangan.
class PostCacheService {
  static const _feedKey = 'post_cache_feed';
  static const _exploreKey = 'post_cache_explore';
  static String _userKey(String uid) => 'post_cache_user_$uid';

  Future<void> saveFeed(List<Post> posts) => _save(_feedKey, posts);
  Future<List<Post>> loadFeed() => _load(_feedKey);

  Future<void> saveExplore(List<Post> posts) => _save(_exploreKey, posts);
  Future<List<Post>> loadExplore() => _load(_exploreKey);

  Future<void> saveUserPosts(String userId, List<Post> posts) =>
      _save(_userKey(userId), posts);
  Future<List<Post>> loadUserPosts(String userId) => _load(_userKey(userId));

  Future<void> _save(String key, List<Post> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        key,
        jsonEncode(posts.map((p) => p.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<List<Post>> _load(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return const [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

final postCacheServiceProvider = Provider<PostCacheService>(
  (_) => PostCacheService(),
);
