import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../post/data/dtos/post_dto.dart';
import '../../../post/domain/entities/post.dart';
import '../../domain/entities/search_result.dart';
import '../dtos/search_user_dto.dart';

abstract interface class SearchRemoteDataSource {
  /// `search_users` RPC → `SearchUser` entity listini qaytaradi
  Future<Result<List<SearchUser>>> searchUsers({
    required String query,
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// `get_feed_posts` RPC → `Post` entity listini qaytaradi (explore uchun)
  Future<Result<List<Post>>> getExplorePosts({
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  const SearchRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<Result<List<SearchUser>>> searchUsers({
    required String query,
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      AppLogger.d('SearchDS: qidirish — "$query"');
      final data = await _client.rpc('search_users', params: {
        'p_query': query.trim(),
        'p_current_id': currentUserId,
        'p_limit': limit,
        'p_offset': offset,
      }) as List<dynamic>;

      final users = data
          .cast<Map<String, dynamic>>()
          .map(SearchUserDto.fromJson)
          .map((dto) => dto.toEntity())
          .toList();

      AppLogger.d('SearchDS: ${users.length} ta natija');
      return Ok(users);
    } on PostgrestException catch (e) {
      AppLogger.e('SearchDS: searchUsers xatosi', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<List<Post>>> getExplorePosts({
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      AppLogger.d('SearchDS: explore — offset:$offset');
      final data = await _client.rpc('get_feed_posts', params: {
        'p_user_id': currentUserId,
        'p_limit': limit,
        'p_offset': offset,
      }) as List<dynamic>;

      final posts = data
          .cast<Map<String, dynamic>>()
          .map(PostDto.fromRpc)
          .map((dto) => dto.toEntity())
          .toList();

      return Ok(posts);
    } on PostgrestException catch (e) {
      AppLogger.e('SearchDS: getExplorePosts xatosi', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }
}
