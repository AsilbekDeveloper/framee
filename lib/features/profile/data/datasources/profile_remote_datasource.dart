import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../dtos/profile_dto.dart';

abstract interface class ProfileRemoteDataSource {
  Future<Result<ProfileDto>> getProfile(String userId, {String? currentUserId});
  Future<Result<ProfileDto>> updateProfile(UpdateProfileParams params);
  Future<Result<bool>> isUsernameAvailable(String username, {String? excludeUserId});
  Stream<ProfileDto?> watchProfile(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  static const _table = 'profiles';
  static const _avatarsBucket = 'avatars';

  @override
  Future<Result<ProfileDto>> getProfile(
    String userId, {
    String? currentUserId,
  }) async {
    try {
      AppLogger.d('ProfileDS: loading profile — $userId');
      final data = await _client
          .from(_table)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        AppLogger.w('ProfileDS: profile not found — $userId');
        return const Err(ProfileNotFoundFailure());
      }

      // Determine is_following from the follows table
      bool isFollowing = false;
      if (currentUserId != null && currentUserId != userId) {
        final followRow = await _client
            .from('follows')
            .select('status')
            .eq('follower_id', currentUserId)
            .eq('following_id', userId)
            .maybeSingle();
        isFollowing = followRow != null &&
            followRow['status'] == 'accepted';
        AppLogger.d(
          'ProfileDS: follow status — $isFollowing (status: ${followRow?['status']})',
        );
      }

      final dto = ProfileDto.fromJson(data, isFollowing: isFollowing);

      // No avatar stored, and this is the current user — fall back to auth metadata
      // (only accept http URLs, not local file paths)
      if (dto.avatarUrl == null && _client.auth.currentUser?.id == userId) {
        final metaAvatar =
            _client.auth.currentUser?.userMetadata?['avatar_url'] as String?;
        if (metaAvatar != null && metaAvatar.startsWith('http')) {
          AppLogger.d('ProfileDS: avatar resolved from auth metadata');
          // Also sync to the profiles table so future fetches are faster
          _syncAvatarToProfiles(userId: userId, avatarUrl: metaAvatar);
          return Ok(ProfileDto(
            id: dto.id,
            username: dto.username,
            displayName: dto.displayName,
            avatarUrl: metaAvatar,
            bio: dto.bio,
            website: dto.website,
            postsCount: dto.postsCount,
            followersCount: dto.followersCount,
            followingCount: dto.followingCount,
            isPrivate: dto.isPrivate,
            isVerified: dto.isVerified,
            isFollowing: isFollowing,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
          ));
        }
      }

      return Ok(dto);
    } on PostgrestException catch (e) {
      AppLogger.e('ProfileDS: getProfile DB error', error: e);
      return Err(ServerFailure(
        message: e.message,
        originalError: e,
      ));
    } catch (e, st) {
      AppLogger.e('ProfileDS: getProfile unexpected error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<ProfileDto>> updateProfile(UpdateProfileParams params) async {
    try {
      AppLogger.i('ProfileDS: saving profile — ${params.userId}');

      String? avatarUrl;

      // 1. If avatar is a local file path, upload it to Storage.
      //    A failed upload is non-fatal — profile data is still saved.
      if (params.avatarLocalPath != null &&
          !params.avatarLocalPath!.startsWith('http')) {
        final uploadResult = await _uploadAvatar(
          userId: params.userId,
          localPath: params.avatarLocalPath!,
        );
        switch (uploadResult) {
          case Ok(:final value):
            avatarUrl = value;
          case Err(:final failure):
            // Avatar upload failed — log only, continue saving profile
            AppLogger.w(
              'ProfileDS: avatar upload failed (profile will still be saved) — ${failure.code}',
            );
        }
      } else {
        avatarUrl = params.avatarLocalPath; // already an http URL or null
      }

      // 2. Upsert the profiles table (creates the row if it doesn't exist yet)
      final updateData = <String, dynamic>{
        'id': params.userId,
        if (params.username != null) 'username': params.username!.trim(),
        if (params.displayName != null)
          'display_name': params.displayName!.trim(),
        if (params.bio != null) 'bio': params.bio!.trim().isEmpty ? null : params.bio!.trim(),
        if (params.website != null)
          'website': params.website!.trim().isEmpty ? null : params.website!.trim(),
        'avatar_url': ?avatarUrl,
        if (params.isPrivate != null) 'is_private': params.isPrivate!,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final data = await _client
          .from(_table)
          .upsert(updateData)
          .select()
          .single();

      AppLogger.i('ProfileDS: profile saved');
      return Ok(ProfileDto.fromJson(data));
    } on PostgrestException catch (e) {
      AppLogger.e('ProfileDS: updateProfile DB error', error: e);
      if (e.code == '23505') {
        // unique_violation — username already taken
        return const Err(UsernameAlreadyTakenFailure());
      }
      return Err(ProfileUpdateFailure(originalError: e));
    } catch (e, st) {
      AppLogger.e('ProfileDS: updateProfile unexpected error', error: e, stackTrace: st);
      return Err(ProfileUpdateFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> isUsernameAvailable(
    String username, {
    String? excludeUserId,
  }) async {
    try {
      var query = _client.from(_table).select('id').eq('username', username);
      // Exclude the current user so they can save without changing their own username
      if (excludeUserId != null) {
        query = query.neq('id', excludeUserId);
      }
      final data = await query.maybeSingle();
      return Ok(data == null); // null = no other user has this username = available
    } on PostgrestException catch (e) {
      AppLogger.e('ProfileDS: isUsernameAvailable error', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Stream<ProfileDto?> watchProfile(String userId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) => rows.isEmpty ? null : ProfileDto.fromJson(rows.first));
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<Result<String>> _uploadAvatar({
    required String userId,
    required String localPath,
  }) async {
    try {
      final bytes = await File(localPath).readAsBytes();
      final storagePath = '$userId/avatar.jpg';

      await _client.storage.from(_avatarsBucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Append a timestamp to bust CDN cache after re-upload
      final baseUrl =
          _client.storage.from(_avatarsBucket).getPublicUrl(storagePath);
      final cacheBustedUrl =
          '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      AppLogger.i('ProfileDS: avatar uploaded to Storage');
      return Ok(cacheBustedUrl);
    } catch (e, st) {
      AppLogger.e('ProfileDS: avatar upload error', error: e, stackTrace: st);
      return Err(AvatarUploadFailure(originalError: e, stackTrace: st));
    }
  }

  /// Syncs the avatar URL from auth metadata into the profiles table in the background.
  /// Errors are silently ignored — this is a best-effort optimisation, not critical.
  void _syncAvatarToProfiles({
    required String userId,
    required String avatarUrl,
  }) {
    _client
        .from(_table)
        .update({'avatar_url': avatarUrl, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', userId)
        .then((_) => AppLogger.d('ProfileDS: avatar synced → profiles'))
        .catchError((e) => AppLogger.w('ProfileDS: avatar sync error: $e'));
  }
}
