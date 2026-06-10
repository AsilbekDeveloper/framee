import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../follow/domain/entities/follow.dart';
import '../providers/followers_provider.dart';

class FollowersScreen extends ConsumerStatefulWidget {
  const FollowersScreen({
    super.key,
    required this.userId,
    this.initialTab = 'followers',
  });

  final String userId;
  final String initialTab;

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'following' ? 1 : 0,
    );
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(followersProvider(widget.userId));
    final notifier = ref.read(followersProvider(widget.userId).notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: stateAsync.maybeWhen(
          data: (s) {
            final followersCount = s.followers.length;
            final followingCount = s.following.length;
            return TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.followersLabel),
                      Gap(6.w),
                      _CountBadge(
                        count: followersCount.toString(),
                        isActive: _tabController.index == 0,
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.followingLabel),
                      Gap(6.w),
                      _CountBadge(
                        count: followingCount.toString(),
                        isActive: _tabController.index == 1,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          orElse: () => TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppStrings.followersLabel),
              Tab(text: AppStrings.followingLabel),
            ],
          ),
        ),
        titleSpacing: 0,
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48.w, color: AppColors.error),
              Gap(AppDimens.vmd),
              AppButton(
                label: AppStrings.retry,
                onPressed: notifier.refresh,
                variant: AppButtonVariant.outline,
              ),
            ],
          ),
        ),
        data: (state) => Column(
          children: [
            // Search
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.lg,
                AppDimens.vmd,
                AppDimens.lg,
                AppDimens.vsm,
              ),
              child: AppSearchBar(
                controller: _searchController,
                hint: AppStrings.searchPlaceholder,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                onClear: () => setState(() => _searchQuery = ''),
              ),
            ),

            // Lists
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _UserList(
                    users: _filter(state.followers),
                    onUserTap: (id) =>
                        context.push(AppRoutes.userProfilePath(id)),
                    onFollowToggle: (id) =>
                        notifier.toggleFollow(id, isFollowers: true),
                  ),
                  _UserList(
                    users: _filter(state.following),
                    onUserTap: (id) =>
                        context.push(AppRoutes.userProfilePath(id)),
                    onFollowToggle: (id) =>
                        notifier.toggleFollow(id, isFollowers: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FollowUser> _filter(List<FollowUser> users) {
    if (_searchQuery.isEmpty) return users;
    return users
        .where(
          (u) =>
              u.username.toLowerCase().contains(_searchQuery) ||
              u.displayName.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }
}

// â”€â”€â”€ Count Badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.isActive});
  final String count;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryMuted
            : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        count,
        style: AppTextStyles.overlineBold.copyWith(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        ),
      ),
    );
  }
}

// â”€â”€â”€ User List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _UserList extends StatelessWidget {
  const _UserList({
    required this.users,
    required this.onUserTap,
    required this.onFollowToggle,
  });

  final List<FollowUser> users;
  final ValueChanged<String> onUserTap;
  final ValueChanged<String> onFollowToggle;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return EmptyState(
        icon: Icons.group_outlined,
        title: AppStrings.noResults,
      );
    }
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => const AppDivider(),
      itemBuilder: (context, i) => _FollowerRow(
        user: users[i],
        onTap: () => onUserTap(users[i].id),
        onFollowToggle: () => onFollowToggle(users[i].id),
      ),
    );
  }
}

// â”€â”€â”€ Follower Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FollowerRow extends StatelessWidget {
  const _FollowerRow({
    required this.user,
    required this.onTap,
    required this.onFollowToggle,
  });

  final FollowUser user;
  final VoidCallback onTap;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: user.avatarUrl,
              initials: user.initials,
              size: AvatarSize.md,
            ),
            Gap(AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: AppTextStyles.username.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        Gap(4.w),
                        Icon(
                          Icons.verified_rounded,
                          size: 14.w,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  Gap(2.h),
                  Text(
                    '@${user.username}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Gap(AppDimens.sm),
            FollowButton(
              isFollowing: user.isFollowing || user.isRequested,
              label: user.isRequested ? 'Requested' : null,
              onTap: onFollowToggle,
            ),
          ],
        ),
      ),
    );
  }
}


