import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/user_posts_provider.dart';
import 'profile_image_grid.dart';
import 'profile_text_list.dart';

class ProfileTabDelegate extends SliverPersistentHeaderDelegate {
  const ProfileTabDelegate({
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
          ProfileTab(
            icon: Icons.grid_view_rounded,
            isActive: selectedIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          ProfileTab(
            icon: Icons.format_list_bulleted_rounded,
            isActive: selectedIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(ProfileTabDelegate old) =>
      old.selectedIndex != selectedIndex;
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
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

class ProfileImagePostsTab extends ConsumerWidget {
  const ProfileImagePostsTab({
    super.key,
    required this.userId,
    required this.onPostTap,
  });

  final String userId;
  final ValueChanged<String> onPostTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, _) => SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.error_outline_rounded,
          title: AppStrings.errorOccurred,
        ),
      ),
      data: (posts) {
        final imagePosts = posts.where((p) => p.hasImage).toList();
        if (imagePosts.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyState(
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

class ProfileTextPostsTab extends ConsumerWidget {
  const ProfileTextPostsTab({
    super.key,
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
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, _) => SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.error_outline_rounded,
          title: AppStrings.errorOccurred,
        ),
      ),
      data: (posts) {
        final textPosts = posts.where((p) => !p.hasImage).toList();
        if (textPosts.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.text_fields_rounded,
              title: AppStrings.noTextPosts,
              subtitle: AppStrings.noTextPostsSub,
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
