import '../../../../core/errors/result.dart';
import '../entities/follow.dart';

abstract interface class FollowRepository {
  /// [targetUserId] foydalanuvchini follow qilish yoki private bo'lsa so'rov yuborish
  Future<Result<FollowStatus>> followUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Unfollow yoki so'rovni bekor qilish
  Future<Result<bool>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Follow so'rovini qabul qilish (private account egasi uchun)
  Future<Result<bool>> acceptFollowRequest({
    required String currentUserId,
    required String requesterId,
  });

  /// Follow so'rovini rad etish
  Future<Result<bool>> declineFollowRequest({
    required String currentUserId,
    required String requesterId,
  });

  /// Ikki foydalanuvchi o'rtasidagi follow holatini tekshirish
  Future<Result<FollowStatus>> getFollowStatus({
    required String currentUserId,
    required String targetUserId,
  });

  /// Foydalanuvchining follower'larini yuklash
  Future<Result<List<FollowUser>>> getFollowers({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });

  /// Foydalanuvchi kimlarni follow qilayotgani
  Future<Result<List<FollowUser>>> getFollowing({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });
}
