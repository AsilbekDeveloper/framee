import '../../../../core/errors/result.dart';
import '../../../post/domain/entities/post.dart';
import '../entities/search_result.dart';

/// Search domenining repository interfeysi.
abstract interface class SearchRepository {
  /// Username / display_name bo'yicha foydalanuvchi qidiradi.
  Future<Result<List<SearchUser>>> searchUsers({
    required String query,
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// Explore sahifasi uchun public postlar (random/latest).
  Future<Result<List<Post>>> getExplorePosts({
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });
}
