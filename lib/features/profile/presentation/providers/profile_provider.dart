import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/ui_models.dart';
import '../../../../core/utils/mock_data.dart';

class ProfileState {
  const ProfileState({
    this.user,
    this.posts = const [],
    this.isLoading = true,
    this.tabIndex = 0,
  });

  final UserModel? user;
  final List<PostModel> posts;
  final bool isLoading;
  final int tabIndex;

  ProfileState copyWith({
    UserModel? user,
    List<PostModel>? posts,
    bool? isLoading,
    int? tabIndex,
  }) =>
      ProfileState(
        user: user ?? this.user,
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        tabIndex: tabIndex ?? this.tabIndex,
      );
}

class ProfileNotifier extends FamilyNotifier<ProfileState, String?> {
  @override
  ProfileState build(String? userId) {
    _load(userId);
    return const ProfileState();
  }

  Future<void> _load(String? userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = userId == null
        ? MockData.currentUser
        : MockData.users.firstWhere(
            (u) => u.id == userId,
            orElse: () => MockData.currentUser,
          );
    state = state.copyWith(
      user: user,
      posts: MockData.posts,
      isLoading: false,
    );
  }

  Future<void> refresh() => _load(arg);

  void setTab(int index) => state = state.copyWith(tabIndex: index);

  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser);
  }

  void toggleFollow() {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(
      user: user.copyWith(
        isFollowing: !user.isFollowing,
        followersCount: user.isFollowing
            ? user.followersCount - 1
            : user.followersCount + 1,
      ),
    );
  }
}

final profileProvider =
    NotifierProviderFamily<ProfileNotifier, ProfileState, String?>(
  ProfileNotifier.new,
);
