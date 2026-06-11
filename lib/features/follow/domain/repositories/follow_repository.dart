import '../../../../core/errors/result.dart';
import '../entities/follow.dart';

abstract interface class FollowRepository {
  /// Follows [targetUserId], or sends a follow request if the account is private.
  Future<Result<FollowStatus>> followUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Unfollows the target or cancels a pending follow request.
  Future<Result<bool>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Accepts a follow request (called by the private-account owner).
  Future<Result<bool>> acceptFollowRequest({
    required String currentUserId,
    required String requesterId,
  });

  /// Declines a pending follow request.
  Future<Result<bool>> declineFollowRequest({
    required String currentUserId,
    required String requesterId,
  });

  /// Returns the follow status between two users.
  Future<Result<FollowStatus>> getFollowStatus({
    required String currentUserId,
    required String targetUserId,
  });

  /// Loads the followers of a user.
  Future<Result<List<FollowUser>>> getFollowers({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });

  /// Returns the list of users that a user is following.
  Future<Result<List<FollowUser>>> getFollowing({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });
}
