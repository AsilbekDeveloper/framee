import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/follow.dart';
import '../../domain/failures/follow_failure.dart';
import '../dtos/follow_user_dto.dart';

abstract interface class FollowRemoteDataSource {
  Future<Result<FollowStatus>> followUser({
    required String currentUserId,
    required String targetUserId,
  });

  Future<Result<bool>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  Future<Result<bool>> acceptFollowRequest({
    required String currentUserId,
    required String requesterId,
  });

  Future<Result<bool>> declineFollowRequest({
    required String currentUserId,
    required String requesterId,
  });

  Future<Result<FollowStatus>> getFollowStatus({
    required String currentUserId,
    required String targetUserId,
  });

  Future<Result<List<FollowUserDto>>> getFollowers({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });

  Future<Result<List<FollowUserDto>>> getFollowing({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });
}

class FollowRemoteDataSourceImpl implements FollowRemoteDataSource {
  const FollowRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  static const _followsTable = 'follows';
  static const _profilesTable = 'profiles';

  @override
  Future<Result<FollowStatus>> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Check whether the target account is private
      final targetProfile = await _client
          .from(_profilesTable)
          .select('is_private')
          .eq('id', targetUserId)
          .maybeSingle();

      if (targetProfile == null) return const Err(FollowNotFoundFailure());

      final isPrivate = targetProfile['is_private'] as bool? ?? false;
      final status = isPrivate ? 'requested' : 'accepted';

      // Upsert into follows — onConflict must be explicit for composite PKs.
      // Without it some Supabase SDK versions treat a 200 response as an error.
      await _client.from(_followsTable).upsert(
        {
          'follower_id': currentUserId,
          'following_id': targetUserId,
          'status': status,
        },
        onConflict: 'follower_id,following_id',
      );

      final result =
          isPrivate ? FollowStatus.requested : FollowStatus.following;
      AppLogger.i('FollowDS: follow — $status ($targetUserId)');
      return Ok(result);
    } on PostgrestException catch (e) {
      AppLogger.e('FollowDS: followUser error (Postgrest)', error: e);
      return Err(FollowOperationFailure(originalError: e));
    } catch (e, st) {
      AppLogger.e('FollowDS: followUser unexpected error', error: e, stackTrace: st);
      return Err(FollowOperationFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      await _client
          .from(_followsTable)
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);

      AppLogger.i('FollowDS: unfollow — $targetUserId');
      return const Ok(true);
    } on PostgrestException catch (e) {
      AppLogger.e('FollowDS: unfollowUser error (Postgrest)', error: e);
      return Err(FollowOperationFailure(originalError: e));
    } catch (e, st) {
      AppLogger.e('FollowDS: unfollowUser unexpected error', error: e, stackTrace: st);
      return Err(FollowOperationFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> acceptFollowRequest({
    required String currentUserId,
    required String requesterId,
  }) async {
    try {
      await _client
          .from(_followsTable)
          .update({'status': 'accepted'})
          .eq('follower_id', requesterId)
          .eq('following_id', currentUserId)
          .eq('status', 'requested');

      AppLogger.i('FollowDS: follow request accepted — $requesterId');
      return const Ok(true);
    } on PostgrestException catch (e) {
      return Err(FollowOperationFailure(originalError: e));
    } catch (e, st) {
      return Err(FollowOperationFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> declineFollowRequest({
    required String currentUserId,
    required String requesterId,
  }) async {
    try {
      await _client
          .from(_followsTable)
          .delete()
          .eq('follower_id', requesterId)
          .eq('following_id', currentUserId)
          .eq('status', 'requested');

      return const Ok(true);
    } on PostgrestException catch (e) {
      return Err(FollowOperationFailure(originalError: e));
    } catch (e, st) {
      return Err(FollowOperationFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<FollowStatus>> getFollowStatus({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final data = await _client
          .from(_followsTable)
          .select('status')
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId)
          .maybeSingle();

      if (data == null) return const Ok(FollowStatus.none);

      final status = data['status'] as String?;
      return Ok(status == 'accepted'
          ? FollowStatus.following
          : FollowStatus.requested);
    } on PostgrestException catch (e) {
      return Err(FollowOperationFailure(originalError: e));
    } catch (e, st) {
      return Err(FollowOperationFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<List<FollowUserDto>>> getFollowers({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      // Fetch users who follow userId
      final data = await _client
          .from(_followsTable)
          .select('follower_id, profiles!follower_id(id, username, display_name, avatar_url, is_verified, is_private)')
          .eq('following_id', userId)
          .eq('status', 'accepted')
          .range(offset, offset + limit - 1);

      // Resolve the current user's follow status for each fetched user
      final followerIds = (data as List)
          .map((e) => (e['profiles'] as Map)['id'] as String)
          .toList();

      final myFollowStatuses = await _getFollowStatusBatch(
        currentUserId: currentUserId,
        targetIds: followerIds,
      );

      final dtos = data.map((row) {
        final profile = row['profiles'] as Map<String, dynamic>;
        final uid = profile['id'] as String;
        return FollowUserDto.fromJson(
          profile,
          followStatus: myFollowStatuses[uid] ?? FollowStatus.none,
        );
      }).toList();

      return Ok(dtos);
    } on PostgrestException catch (e) {
      AppLogger.e('FollowDS: getFollowers error', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<List<FollowUserDto>>> getFollowing({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final data = await _client
          .from(_followsTable)
          .select('following_id, profiles!following_id(id, username, display_name, avatar_url, is_verified, is_private)')
          .eq('follower_id', userId)
          .eq('status', 'accepted')
          .range(offset, offset + limit - 1);

      final followingIds = (data as List)
          .map((e) => (e['profiles'] as Map)['id'] as String)
          .toList();

      final myFollowStatuses = await _getFollowStatusBatch(
        currentUserId: currentUserId,
        targetIds: followingIds,
      );

      final dtos = data.map((row) {
        final profile = row['profiles'] as Map<String, dynamic>;
        final uid = profile['id'] as String;
        return FollowUserDto.fromJson(
          profile,
          followStatus: myFollowStatuses[uid] ?? FollowStatus.none,
        );
      }).toList();

      return Ok(dtos);
    } on PostgrestException catch (e) {
      AppLogger.e('FollowDS: getFollowing error', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Fetches the follow status for multiple users in a single query.
  Future<Map<String, FollowStatus>> _getFollowStatusBatch({
    required String currentUserId,
    required List<String> targetIds,
  }) async {
    if (targetIds.isEmpty) return {};
    try {
      final data = await _client
          .from(_followsTable)
          .select('following_id, status')
          .eq('follower_id', currentUserId)
          .inFilter('following_id', targetIds);

      return {
        for (final row in data as List)
          row['following_id'] as String: (row['status'] as String) == 'accepted'
              ? FollowStatus.following
              : FollowStatus.requested,
      };
    } catch (_) {
      return {};
    }
  }
}
