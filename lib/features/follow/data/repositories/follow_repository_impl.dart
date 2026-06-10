import '../../../../core/errors/result.dart';
import '../../domain/entities/follow.dart';
import '../../domain/repositories/follow_repository.dart';
import '../datasources/follow_remote_datasource.dart';

class FollowRepositoryImpl implements FollowRepository {
  const FollowRepositoryImpl(this._dataSource);
  final FollowRemoteDataSource _dataSource;

  @override
  Future<Result<FollowStatus>> followUser({
    required String currentUserId,
    required String targetUserId,
  }) =>
      _dataSource.followUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );

  @override
  Future<Result<bool>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) =>
      _dataSource.unfollowUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );

  @override
  Future<Result<bool>> acceptFollowRequest({
    required String currentUserId,
    required String requesterId,
  }) =>
      _dataSource.acceptFollowRequest(
        currentUserId: currentUserId,
        requesterId: requesterId,
      );

  @override
  Future<Result<bool>> declineFollowRequest({
    required String currentUserId,
    required String requesterId,
  }) =>
      _dataSource.declineFollowRequest(
        currentUserId: currentUserId,
        requesterId: requesterId,
      );

  @override
  Future<Result<FollowStatus>> getFollowStatus({
    required String currentUserId,
    required String targetUserId,
  }) =>
      _dataSource.getFollowStatus(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );

  @override
  Future<Result<List<FollowUser>>> getFollowers({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await _dataSource.getFollowers(
      userId: userId,
      currentUserId: currentUserId,
      limit: limit,
      offset: offset,
    );
    return result.map((dtos) => dtos.map((d) => d.toEntity()).toList());
  }

  @override
  Future<Result<List<FollowUser>>> getFollowing({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await _dataSource.getFollowing(
      userId: userId,
      currentUserId: currentUserId,
      limit: limit,
      offset: offset,
    );
    return result.map((dtos) => dtos.map((d) => d.toEntity()).toList());
  }
}
