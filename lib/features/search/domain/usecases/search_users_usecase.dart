import '../../../../core/errors/result.dart';
import '../entities/search_result.dart';
import '../failures/search_failure.dart';
import '../repositories/search_repository.dart';

class SearchUsersUseCase {
  const SearchUsersUseCase(this._repository);
  final SearchRepository _repository;

  Future<Result<List<SearchUser>>> call({
    required String query,
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Future.value(const Err(EmptyQueryFailure()));
    }
    return _repository.searchUsers(
      query: trimmed,
      currentUserId: currentUserId,
      limit: limit,
      offset: offset,
    );
  }
}
