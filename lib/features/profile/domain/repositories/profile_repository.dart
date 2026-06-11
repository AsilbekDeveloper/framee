import '../../../../core/errors/result.dart';
import '../entities/profile.dart';

/// Profile domain repository — interface only.
/// The implementation lives in the data layer.
abstract interface class ProfileRepository {
  /// Loads a profile by [userId].
  /// [currentUserId] is the viewer — used to determine the [isFollowing] flag.
  Future<Result<Profile>> getProfile(String userId, {String? currentUserId});

  /// Updates profile data.
  /// If [avatarLocalPath] is a local file path, it is uploaded to Storage first.
  Future<Result<Profile>> updateProfile(UpdateProfileParams params);

  /// Returns `true` if the username is not yet taken.
  /// Pass [excludeUserId] to ignore the current user's own row (so re-saving the same
  /// username does not report a conflict).
  Future<Result<bool>> isUsernameAvailable(String username, {String? excludeUserId});

  /// Real-time stream of profile changes (Supabase Realtime).
  Stream<Profile?> watchProfile(String userId);
}
