import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../follow/data/providers/follow_data_providers.dart';
import '../../../follow/domain/entities/follow.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class FollowersState {
  const FollowersState({
    this.followers = const [],
    this.following = const [],
    this.isLoadingFollowers = false,
    this.isLoadingFollowing = false,
  });

  final List<FollowUser> followers;
  final List<FollowUser> following;
  final bool isLoadingFollowers;
  final bool isLoadingFollowing;

  FollowersState copyWith({
    List<FollowUser>? followers,
    List<FollowUser>? following,
    bool? isLoadingFollowers,
    bool? isLoadingFollowing,
  }) =>
      FollowersState(
        followers: followers ?? this.followers,
        following: following ?? this.following,
        isLoadingFollowers: isLoadingFollowers ?? this.isLoadingFollowers,
        isLoadingFollowing: isLoadingFollowing ?? this.isLoadingFollowing,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// [String] = targetUserId
class FollowersNotifier extends FamilyAsyncNotifier<FollowersState, String> {
  @override
  Future<FollowersState> build(String userId) async {
    AppLogger.d('FollowersNotifier: $userId followers/following yuklanmoqda');
    final currentUserId = _currentUserId ?? userId;

    final results = await Future.wait([
      ref.read(getFollowersUseCaseProvider).call(
            userId: userId,
            currentUserId: currentUserId,
          ),
      ref.read(getFollowingUseCaseProvider).call(
            userId: userId,
            currentUserId: currentUserId,
          ),
    ]);

    final followers = switch (results[0]) {
      Ok(:final value) => value,
      Err() => const <FollowUser>[],
    };
    final following = switch (results[1]) {
      Ok(:final value) => value,
      Err() => const <FollowUser>[],
    };

    return FollowersState(followers: followers, following: following);
  }

  String? get _currentUserId =>
      ref.read(currentUserIdProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  /// Optimistic follow toggle
  Future<void> toggleFollow(String targetUserId, {required bool isFollowers}) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final list = isFollowers ? currentState.followers : currentState.following;
    final user = list.cast<FollowUser?>().firstWhere(
          (u) => u?.id == targetUserId,
          orElse: () => null,
        );
    if (user == null) return;

    final wasFollowing = user.isFollowing || user.isRequested;
    final newStatus =
        wasFollowing ? FollowStatus.none : FollowStatus.following;

    _updateStatus(targetUserId, newStatus, isFollowers: isFollowers);

    if (wasFollowing) {
      final result = await ref.read(unfollowUserUseCaseProvider).call(
            currentUserId: currentUserId,
            targetUserId: targetUserId,
          );
      if (result.isErr) {
        _updateStatus(targetUserId, user.followStatus, isFollowers: isFollowers);
      }
    } else {
      final result = await ref.read(followUserUseCaseProvider).call(
            currentUserId: currentUserId,
            targetUserId: targetUserId,
          );
      switch (result) {
        case Ok(:final value):
          _updateStatus(targetUserId, value, isFollowers: isFollowers);
        case Err():
          _updateStatus(targetUserId, user.followStatus, isFollowers: isFollowers);
      }
    }
  }

  void _updateStatus(
    String userId,
    FollowStatus status, {
    required bool isFollowers,
  }) {
    state.whenData((s) {
      if (isFollowers) {
        state = AsyncData(s.copyWith(
          followers: s.followers
              .map((u) => u.id == userId ? u.copyWith(followStatus: status) : u)
              .toList(),
        ));
      } else {
        state = AsyncData(s.copyWith(
          following: s.following
              .map((u) => u.id == userId ? u.copyWith(followStatus: status) : u)
              .toList(),
        ));
      }
    });
  }
}

final followersProvider =
    AsyncNotifierProviderFamily<FollowersNotifier, FollowersState, String>(
  FollowersNotifier.new,
);
