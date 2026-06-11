import '../../../../core/errors/result.dart';
import '../../../post/domain/entities/post.dart';
import '../entities/search_result.dart';

/// Repository interface for the search domain.
abstract interface class SearchRepository {
  /// Searches for users by username or display name.
  Future<Result<List<SearchUser>>> searchUsers({
    required String query,
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// Returns public posts for the Explore screen (random / latest).
  Future<Result<List<Post>>> getExplorePosts({
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });
}
