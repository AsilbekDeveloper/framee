import '../../../../core/errors/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);
  final ProfileRemoteDataSource _dataSource;

  @override
  Future<Result<Profile>> getProfile(String userId, {String? currentUserId}) async {
    final result = await _dataSource.getProfile(userId, currentUserId: currentUserId);
    return result.map((dto) => dto.toEntity());
  }

  @override
  Future<Result<Profile>> updateProfile(UpdateProfileParams params) async {
    final result = await _dataSource.updateProfile(params);
    return result.map((dto) => dto.toEntity());
  }

  @override
  Future<Result<bool>> isUsernameAvailable(
    String username, {
    String? excludeUserId,
  }) =>
      _dataSource.isUsernameAvailable(username, excludeUserId: excludeUserId);

  @override
  Stream<Profile?> watchProfile(String userId) =>
      _dataSource.watchProfile(userId).map((dto) => dto?.toEntity());

  @override
  Future<void> saveFcmToken(String userId, String token) =>
      _dataSource.saveFcmToken(userId, token);

  @override
  Future<void> clearFcmToken(String userId) =>
      _dataSource.clearFcmToken(userId);
}
