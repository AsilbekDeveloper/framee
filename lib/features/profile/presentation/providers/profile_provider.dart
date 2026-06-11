import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../follow/data/providers/follow_data_providers.dart';
import '../../../follow/domain/entities/follow.dart';
import '../../data/providers/profile_data_providers.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';

// ── Use case provider (private) ───────────────────────────────────────────────

final _getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.read(profileRepositoryProvider)),
);

// ── Profile Notifier ──────────────────────────────────────────────────────────

class ProfileNotifier extends FamilyAsyncNotifier<Profile, String?> {
  @override
  Future<Profile> build(String? userId) async {
    final targetId = userId ?? _currentUserId;
    if (targetId == null) throw StateError('User is not authenticated.');
    AppLogger.d('ProfileNotifier: loading profile — $targetId');
    return _fetchProfile(targetId);
  }

  String? get _currentUserId =>
      ref.read(currentUserIdProvider);

  Future<Profile> _fetchProfile(String userId) async {
    final result = await ref.read(_getProfileUseCaseProvider).call(
          userId,
          currentUserId: _currentUserId,
        );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    final targetId = arg ?? _currentUserId;
    if (targetId == null) {
      state = AsyncError(
        StateError('User is not authenticated.'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProfile(targetId));
  }

  // Double-tap guard — prevents re-entry while an async follow/unfollow is in flight
  bool _isTogglingFollow = false;

  /// Triggers a real Supabase follow or unfollow with optimistic UI.
  Future<void> toggleFollow() async {
    if (_isTogglingFollow) return; // double-tap guard
    _isTogglingFollow = true;

    final currentUserId = _currentUserId;
    final targetUserId = arg;
    if (currentUserId == null || targetUserId == null) {
      _isTogglingFollow = false;
      return;
    }

    final profile = state.valueOrNull;
    if (profile == null) {
      _isTogglingFollow = false;
      return;
    }

    final wasFollowing = profile.isFollowing;

    // Optimistic update
    state = AsyncData(
      profile.copyWith(
        isFollowing: !wasFollowing,
        followersCount: wasFollowing
            ? profile.followersCount - 1
            : profile.followersCount + 1,
      ),
    );

    try {
      if (wasFollowing) {
        final result = await ref.read(unfollowUserUseCaseProvider).call(
              currentUserId: currentUserId,
              targetUserId: targetUserId,
            );
        if (result.isErr) {
          // Rollback
          state = AsyncData(profile);
          AppLogger.w('ProfileNotifier: unfollow error — rolling back');
        }
      } else {
        final result = await ref.read(followUserUseCaseProvider).call(
              currentUserId: currentUserId,
              targetUserId: targetUserId,
            );
        switch (result) {
          case Ok(:final value):
            // Private account → requested; public → following
            if (value == FollowStatus.requested) {
              state = AsyncData(profile.copyWith(isFollowing: false));
            }
          case Err(:final failure):
            state = AsyncData(profile);
            AppLogger.w(
              'ProfileNotifier: follow error — ${failure.code}: ${failure.message}',
            );
        }
      }
    } finally {
      _isTogglingFollow = false;
    }
  }

  void updateProfile(Profile updated) {
    AppLogger.d('ProfileNotifier: profile updated — ${updated.username}');
    state = AsyncData(updated);
  }
}

final profileProvider =
    AsyncNotifierProviderFamily<ProfileNotifier, Profile, String?>(
  ProfileNotifier.new,
);

final profileTabIndexProvider =
    StateProviderFamily<int, String?>((ref, _) => 0);
