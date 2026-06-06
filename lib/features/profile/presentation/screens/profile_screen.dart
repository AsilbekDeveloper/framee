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
import '../../../../core/models/ui_models.dart';
import '../../../../core/router/app_router.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_grid.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});

  /// If null → own profile. If set → other user's profile.
  final String? userId;

  bool get isOwnProfile => userId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider(userId));
    final notifier = ref.read(profileProvider(userId).notifier);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = state.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: _ProfileAppBar(
        username: user.username,
        isOwnProfile: isOwnProfile,
        onSettingsTap: () => context.push(AppRoutes.settings),
        onCreateTap: () => context.push(AppRoutes.createPost),
        onBackTap: isOwnProfile ? null : () => context.pop(),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          slivers: [
            // Profile Info
            SliverToBoxAdapter(
              child: _ProfileInfo(
                user: user,
                isOwnProfile: isOwnProfile,
                onFollowersTap: () => context.push(
                  '${AppRoutes.followersPath(user.id)}?tab=followers',
                ),
                onFollowingTap: () => context.push(
                  '${AppRoutes.followersPath(user.id)}?tab=following',
                ),
                onEditTap: () => context.push(AppRoutes.editProfile),
                onShareTap: () => context.showSnackBar(AppStrings.profileLinkCopied),
                onFollowTap: () => notifier.toggleFollow(),
              ),
            ),

            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileTabDelegate(
                selectedIndex: state.tabIndex,
                onTabChanged: notifier.setTab,
              ),
            ),

            // Tab content
            if (state.tabIndex == 0)
              SliverPadding(
                padding: const EdgeInsets.all(2),
                sliver: ProfileGrid(
                  posts: state.posts,
                  onPostTap: (postId) =>
                      context.push(AppRoutes.postDetailPath(postId)),
                ),
              ),

            if (state.tabIndex == 1)
              SliverList.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) => _MiniPostRow(
                  post: state.posts[index],
                  onTap: () => context.push(
                    AppRoutes.postDetailPath(state.posts[index].id),
                  ),
                ),
              ),

            if (state.tabIndex == 2)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.label_outline_rounded,
                  title: AppStrings.noTaggedPosts,
                  subtitle: AppStrings.noTaggedPostsSub,
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: AppDimens.vhuge)),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
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

    return Container(
      height: preferredSize.height,
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
      padding: EdgeInsets.symmetric(horizontal: AppDimens.xl),
      child: Row(
        children: [
          // Left: + (own) or back (other)
          if (isOwnProfile)
            AppIconButton(icon: Icons.add_rounded, onTap: onCreateTap)
          else
            AppIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBackTap ?? () {},
            ),
          const Spacer(),
          // Center: username
          Text(username, style: AppTextStyles.h3),
          const Spacer(),
          // Right: settings
          AppIconButton(
            icon: Icons.settings_outlined,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

// ─── Profile Info ─────────────────────────────────────────────────────────────
class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.user,
    required this.isOwnProfile,
    required this.onFollowersTap,
    required this.onFollowingTap,
    required this.onEditTap,
    required this.onShareTap,
    required this.onFollowTap,
  });

  final UserModel user;
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
          // Avatar + Stats row
          Row(
            children: [
              AppAvatar(
                imageUrl: user.avatarUrl,
                initials: user.initials,
                size: AvatarSize.xl,
                hasStoryRing: true,
              ),
              Gap(AppDimens.lg),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(
                      value: user.postsCount.compact,
                      label: AppStrings.posts,
                      onTap: null,
                    ),
                    _StatColumn(
                      value: user.followersCount.compact,
                      label: AppStrings.followersLabel,
                      onTap: onFollowersTap,
                    ),
                    _StatColumn(
                      value: user.followingCount.compact,
                      label: AppStrings.followingLabel,
                      onTap: onFollowingTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(AppDimens.vmd),

          // Name
          Text(
            user.displayName,
            style: AppTextStyles.h4.copyWith(color: textColor),
          ),

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            Gap(4.h),
            Text(
              user.bio!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
          ],

          // Website
          if (user.website != null && user.website!.isNotEmpty) ...[
            Gap(5.h),
            Row(
              children: [
                Icon(Icons.link_rounded,
                    size: 14.w, color: AppColors.primary),
                Gap(4.w),
                Text(
                  user.website!,
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
                  child: SizedBox(
                    height: AppDimens.buttonHeightSm,
                    child: OutlinedButton(
                      onPressed: onEditTap,
                      child: Text(AppStrings.editProfile),
                    ),
                  ),
                ),
                Gap(AppDimens.sm),
                Expanded(
                  child: SizedBox(
                    height: AppDimens.buttonHeightSm,
                    child: OutlinedButton(
                      onPressed: onShareTap,
                      child: Text(AppStrings.shareProfile),
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
                    isFollowing: user.isFollowing,
                    onTap: onFollowTap,
                  ),
                ),
                Gap(AppDimens.sm),
                SizedBox(
                  height: AppDimens.buttonHeightSm,
                  child: OutlinedButton(
                    onPressed: onShareTap,
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppDimens.lg),
                    ),
                    child: Text(AppStrings.shareProfile),
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
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Delegate ─────────────────────────────────────────────────────────────
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
          _Tab(
            icon: Icons.label_outline_rounded,
            isActive: selectedIndex == 2,
            onTap: () => onTabChanged(2),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileTabDelegate old) =>
      old.selectedIndex != selectedIndex;
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

// ─── Mini Post Row (list view) ────────────────────────────────────────────────
class _MiniPostRow extends StatelessWidget {
  const _MiniPostRow({required this.post, required this.onTap});

  final PostModel post;
  final VoidCallback onTap;

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
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
              ),
              child: Icon(
                Icons.image_outlined,
                size: 22.w,
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            Gap(AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.hasCaption)
                    Text(
                      post.caption!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  Gap(4.h),
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded,
                          size: 14.w, color: AppColors.like),
                      Gap(3.w),
                      Text(
                        post.likesCount.compact,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
