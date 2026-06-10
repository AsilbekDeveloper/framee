import '../../../../core/errors/result.dart';
import '../../../post/domain/entities/post.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._dataSource);
  final SearchRemoteDataSource _dataSource;

  @override
  Future<Result<List<SearchUser>>> searchUsers({
    required String query,
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) =>
      _dataSource.searchUsers(
        query: query,
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );

  @override
  Future<Result<List<Post>>> getExplorePosts({
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) =>
      _dataSource.getExplorePosts(
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
}
