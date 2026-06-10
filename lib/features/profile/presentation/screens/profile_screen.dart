import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';
import '../providers/user_posts_provider.dart';
import '../widgets/profile_image_grid.dart';
import '../widgets/profile_text_list.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    // userId null bo'lsa yoki currentUser'ning o'z ID'si bo'lsa â€” o'z profili
    final isOwnProfile = userId == null || userId == currentUserId;

    final profileAsync = ref.watch(profileProvider(userId));
    final tabIndex = ref.watch(profileTabIndexProvider(userId));

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const Gap(12),
              Text(AppStrings.errorOccurred, style: AppTextStyles.bodyMedium),
              const Gap(8),
              AppButton(
                label: AppStrings.retry,
                onPressed: () =>
                    ref.read(profileProvider(userId).notifier).refresh(),
              ),
            ],
          ),
        ),
      ),
      data: (profile) => Scaffold(
        appBar: _ProfileAppBar(
          username: profile.username,
          isOwnProfile: isOwnProfile,
          onSettingsTap: () => context.push(AppRoutes.settings),
          onCreateTap: () => context.push(AppRoutes.createPost),
          onBackTap: isOwnProfile ? null : () => context.pop(),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              ref.read(profileProvider(userId).notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // Profile info
              SliverToBoxAdapter(
                child: _ProfileInfo(
                  profile: profile,
                  isOwnProfile: isOwnProfile,
                  onFollowersTap: () => context.push(
                    '${AppRoutes.followersPath(profile.id)}?tab=followers',
                  ),
                  onFollowingTap: () => context.push(
                    '${AppRoutes.followersPath(profile.id)}?tab=following',
                  ),
                  onEditTap: () => context.push(AppRoutes.editProfile),
                  onShareTap: () =>
                      context.showSnackBar(AppStrings.profileLinkCopied),
                  onFollowTap: () =>
                      ref.read(profileProvider(userId).notifier).toggleFollow(),
                ),
              ),

              // Tab bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _ProfileTabDelegate(
                  selectedIndex: tabIndex,
                  onTabChanged: (i) =>
                      ref.read(profileTabIndexProvider(userId).notifier).state =
                          i,
                ),
              ),

              // Tab content
              if (tabIndex == 0)
                _ImagePostsTab(
                  userId: profile.id,
                  onPostTap: (postId) =>
                      context.push(AppRoutes.postDetailPath(postId)),
                )
              else
                _TextPostsTab(
                  userId: profile.id,
                  onPostTap: (postId) =>
                      context.push(AppRoutes.postDetailPath(postId)),
                  onUserTap: (userId) =>
                      context.push(AppRoutes.userProfilePath(userId)),
                ),

              SliverToBoxAdapter(child: SizedBox(height: AppDimens.vhuge)),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ App Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar({
    required this.username,
    required this.isOwnProfile,
    required this.onSettingsTap,
    required this.onCreateTap,
    this.onBackTap,
  });

  final String username;
  final bool isOwnProfile;
  final VoidCallback onSettingsTap;
  final VoidCallback onCreateTap;
  final VoidCallback? onBackTap;

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: preferredSize.height + topPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding,
        left: AppDimens.xl,
        right: AppDimens.xl,
      ),
      child: Row(
        children: [
          if (isOwnProfile)
            AppIconButton(icon: Icons.add_rounded, onTap: onCreateTap)
          else
            AppIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBackTap ?? () {},
            ),
          const Spacer(),
          Text(username, style: AppTextStyles.h3),
          const Spacer(),
          AppIconButton(
            icon: Icons.settings_outlined,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Profile Info â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.profile,
    required this.isOwnProfile,
    required this.onFollowersTap,
    required this.onFollowingTap,
    required this.onEditTap,
    required this.onShareTap,
    required this.onFollowTap,
  });

  final Profile profile;
  final bool isOwnProfile;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;
  final VoidCallback onEditTap;
  final VoidCallback onShareTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.xl, AppDimens.vxl, AppDimens.xl, 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Stats
          Row(
            children: [
              AppAvatar(
                imageUrl: profile.avatarUrl,
                initials: profile.initials,
                size: AvatarSize.xl,
                hasStoryRing: true,
              ),
              Gap(AppDimens.lg),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(
                      value: profile.postsCount.compact,
                      label: AppStrings.posts,
                      onTap: null,
                    ),
                    _StatColumn(
                      value: profile.followersCount.compact,
                      label: AppStrings.followersLabel,
                      onTap: onFollowersTap,
                    ),
                    _StatColumn(
                      value: profile.followingCount.compact,
                      label: AppStrings.followingLabel,
                      onTap: onFollowingTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(AppDimens.vmd),

          // Display name
          Text(
            profile.displayName,
            style: AppTextStyles.h4.copyWith(color: textColor),
          ),

          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Gap(4.h),
            Text(
              profile.bio!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
          ],

          // Website
          if (profile.website != null && profile.website!.isNotEmpty) ...[
            Gap(5.h),
            Row(
              children: [
                Icon(Icons.link_rounded, size: 14.w, color: AppColors.primary),
                Gap(4.w),
                Text(
                  profile.website!,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],

          Gap(AppDimens.vmd),

          // Action buttons
          if (isOwnProfile)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEditTap,
                    child: Text(
                      AppStrings.editProfile,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Gap(AppDimens.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onShareTap,
                    child: Text(
                      AppStrings.shareProfile,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FollowButton(
                    isFollowing: profile.isFollowing,
                    onTap: onFollowTap,
                  ),
                ),
                Gap(AppDimens.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onShareTap,
                    child: Text(
                      AppStrings.shareProfile,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          Gap(AppDimens.vmd),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.statNumber.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          Gap(2.h),
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Tab Delegate â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ProfileTabDelegate extends SliverPersistentHeaderDelegate {
  const _ProfileTabDelegate({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  double get minExtent => 44;
  @override
  double get maxExtent => 44;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      child: Row(
        children: [
          _Tab(
            icon: Icons.grid_view_rounded,
            isActive: selectedIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _Tab(
            icon: Icons.format_list_bulleted_rounded,
            isActive: selectedIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileTabDelegate old) =>
      old.selectedIndex != selectedIndex;
}

// â”€â”€â”€ Image Posts Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ImagePostsTab extends ConsumerWidget {
  const _ImagePostsTab({required this.userId, required this.onPostTap});

  final String userId;
  final ValueChanged<String> onPostTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => SliverToBoxAdapter(child: EmptyState(icon: Icons.error_outline_rounded, title: AppStrings.errorOccurred),
      ),
      data: (posts) {
        final imagePosts = posts.where((p) => p.hasImage).toList();
        if (imagePosts.isEmpty) {
          return SliverToBoxAdapter(child: EmptyState(
              icon: Icons.photo_outlined,
              title: AppStrings.noPostsYet,
              subtitle: AppStrings.noPostsYetSub,
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.all(2),
          sliver: ProfileImageGrid(posts: imagePosts, onPostTap: onPostTap),
        );
      },
    );
  }
}

// Text Posts Tab

class _TextPostsTab extends ConsumerWidget {
  const _TextPostsTab({
    required this.userId,
    required this.onPostTap,
    required this.onUserTap,
  });

  final String userId;
  final ValueChanged<String> onPostTap;
  final ValueChanged<String> onUserTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => SliverToBoxAdapter(child: EmptyState(icon: Icons.error_outline_rounded, title: AppStrings.errorOccurred),
      ),
      data: (posts) {
        final textPosts = posts.where((p) => !p.hasImage).toList();
        if (textPosts.isEmpty) {
          return SliverToBoxAdapter(child: EmptyState(
              icon: Icons.text_fields_rounded,
              title: 'Matnli post yo\'q',
              subtitle: 'Rasm siz yozgan postlar bu yerda chiqadi',
            ),
          );
        }
        return ProfileTextList(
          posts: textPosts,
          onPostTap: onPostTap,
          onUserTap: onUserTap,
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 22.w,
            color: isActive
                ? AppColors.primary
                : isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
          ),
        ),
      ),
    );
  }
}


