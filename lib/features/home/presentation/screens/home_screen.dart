import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../providers/home_provider.dart';
import '../widgets/post_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _HomeAppBar(),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: state.isLoading
            ? _LoadingFeed()
            : state.posts.isEmpty
                ? EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: AppStrings.noPostsYet,
                    subtitle: AppStrings.noPostsYetSub,
                  )
                : CustomScrollView(
                    slivers: [
                      SliverList.builder(
                        itemCount: state.posts.length,
                        itemBuilder: (context, index) => PostCard(
                          post: state.posts[index],
                          onLikeTap: () =>
                              ref.read(homeProvider.notifier).toggleLike(
                                    state.posts[index].id,
                                  ),
                          onCommentTap: () => context.push(
                            AppRoutes.postDetailPath(state.posts[index].id),
                          ),
                          onShareTap: () {},
                          onSaveTap: () =>
                              ref.read(homeProvider.notifier).toggleSave(
                                    state.posts[index].id,
                                  ),
                          onMoreTap: () => _showPostOptions(context, isDark),
                          onUserTap: () => context.push(
                            AppRoutes.userProfilePath(
                                state.posts[index].author.id),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: AppDimens.vlg),
                      ),
                    ],
                  ),
      ),
    );
  }

  void _showPostOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostOptionsSheet(),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
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
          // + Create post
          AppIconButton(
            icon: Icons.add_rounded,
            onTap: () => context.push(AppRoutes.createPost),
          ),
          const Spacer(),
          // Logo
          Text(AppStrings.appName, style: AppTextStyles.displayMedium),
          const Spacer(),
          // Notifications
          AppIconButton(
            icon: Icons.notifications_outlined,
            onTap: () => context.push(AppRoutes.notifications),
            badge: true,
          ),
        ],
      ),
    );
  }
}

// ─── Loading Shimmer Feed ─────────────────────────────────────────────────────
class _LoadingFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, __) => const PostCardShimmer(),
    );
  }
}

// ─── Post Options Bottom Sheet ────────────────────────────────────────────────
class _PostOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(AppDimens.vmd),
          // Handle
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.lightBorderSubtle,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Gap(AppDimens.vlg),
          Text(AppStrings.options, style: AppTextStyles.h4),
          Gap(AppDimens.vsm),
          _SheetOption(
            icon: Icons.link_rounded,
            label: AppStrings.copyLink,
            onTap: () => Navigator.pop(context),
          ),
          const AppDivider(),
          _SheetOption(
            icon: Icons.share_outlined,
            label: AppStrings.sharePost,
            onTap: () => Navigator.pop(context),
          ),
          const AppDivider(),
          _SheetOption(
            icon: Icons.bookmark_outline_rounded,
            label: AppStrings.savePost,
            onTap: () => Navigator.pop(context),
          ),
          const AppDivider(),
          _SheetOption(
            icon: Icons.flag_outlined,
            label: AppStrings.reportPost,
            onTap: () => Navigator.pop(context),
          ),
          const AppDivider(),
          _SheetOption(
            icon: Icons.delete_outline_rounded,
            label: AppStrings.deletePost,
            color: AppColors.error,
            onTap: () => Navigator.pop(context),
          ),
          Gap(AppDimens.vlg + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.xl,
          vertical: AppDimens.vxl,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppDimens.iconMd, color: textColor),
            Gap(AppDimens.lg),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}
