import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/models/ui_models.dart';
import '../../../../core/utils/mock_data.dart';
import '../providers/post_detail_provider.dart';
import '../widgets/comment_tile.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postDetailProvider(postId));
    final notifier = ref.read(postDetailProvider(postId).notifier);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final post = state.post ?? MockData.posts.first;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.postDetail),
        actions: [
          AppIconButton(
            icon: Icons.share_outlined,
            onTap: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Post content
                SliverToBoxAdapter(
                  child: _PostContent(
                    post: post,
                    onLikeTap: () => notifier.toggleLike(),
                    onUserTap: () => context.push(
                      AppRoutes.userProfilePath(post.author.id),
                    ),
                  ),
                ),
                // Comments section label
                SliverToBoxAdapter(
                  child: SectionLabel(
                    '${AppStrings.comments} · ${post.commentsCount}',
                  ),
                ),
                // Comments
                SliverList.builder(
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) => CommentTile(
                    comment: state.comments[index],
                    onLikeTap: () =>
                        notifier.toggleCommentLike(state.comments[index].id),
                    onReplyTap: () => notifier.setReplyTo(state.comments[index].id),
                    onDeleteTap: null,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: AppDimens.vlg)),
              ],
            ),
          ),
          // Comment input
          _CommentInputBar(
            controller: notifier.commentController,
            onSend: () => notifier.addComment(),
          ),
        ],
      ),
    );
  }
}

// ─── Post Content ─────────────────────────────────────────────────────────────
class _PostContent extends StatelessWidget {
  const _PostContent({
    required this.post,
    required this.onLikeTap,
    required this.onUserTap,
  });

  final PostModel post;
  final VoidCallback onLikeTap;
  final VoidCallback onUserTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.vmd, AppDimens.md, AppDimens.vsm,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onUserTap,
                child: Row(
                  children: [
                    AppAvatar(
                      imageUrl: post.author.avatarUrl,
                      initials: post.author.initials,
                      size: AvatarSize.sm,
                      hasStoryRing: true,
                    ),
                    Gap(AppDimens.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.author.username,
                            style: AppTextStyles.username
                                .copyWith(color: textColor)),
                        Text(
                          '${post.createdAt.fullDate} · 🌍',
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
              const Spacer(),
              Icon(
                Icons.more_vert_rounded,
                size: AppDimens.iconMd,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ],
          ),
        ),

        // Image
        if (post.hasImage)
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
              child: Icon(
                Icons.image_outlined,
                size: 60.w,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
          ),

        // Actions
        Padding(
          padding: EdgeInsets.fromLTRB(AppDimens.sm, AppDimens.vsm, AppDimens.sm, 4.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: onLikeTap,
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 22.w,
                        color: post.isLiked
                            ? AppColors.like
                            : isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                      Gap(5.w),
                      Text(
                        post.likesCount.compact,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: post.isLiked
                              ? AppColors.like
                              : isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 22.w,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    Gap(5.w),
                    Text(
                      post.commentsCount.compact,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.share_outlined,
                  size: 22.w,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  post.isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  size: 22.w,
                  color: post.isSaved
                      ? AppColors.primary
                      : isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),

        // Likes count
        Padding(
          padding: EdgeInsets.fromLTRB(AppDimens.lg, 2.h, AppDimens.lg, 2.h),
          child: Text(
            '${post.likesCount.compact} ${AppStrings.likes}',
            style: AppTextStyles.labelSmall.copyWith(color: textColor),
          ),
        ),

        // Caption
        if (post.hasCaption)
          Padding(
            padding: EdgeInsets.fromLTRB(AppDimens.lg, 4.h, AppDimens.lg, 4.h),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${post.author.username} ',
                    style: AppTextStyles.username.copyWith(color: textColor),
                  ),
                  TextSpan(
                    text: post.caption,
                    style: AppTextStyles.bodySmall.copyWith(color: textColor),
                  ),
                ],
              ),
            ),
          ),

        Padding(
          padding: EdgeInsets.fromLTRB(AppDimens.lg, 2.h, AppDimens.lg, AppDimens.vmd),
          child: Text(
            post.createdAt.fullDate,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ),
        const AppDivider(indent: 0),
      ],
    );
  }
}

// ─── Comment Input Bar ────────────────────────────────────────────────────────
class _CommentInputBar extends StatelessWidget {
  const _CommentInputBar({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.lg,
        AppDimens.vmd,
        AppDimens.lg,
        AppDimens.vmd + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      child: Row(
        children: [
          AppAvatar(
            initials: 'A',
            size: AvatarSize.xs,
          ),
          Gap(AppDimens.md),
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.lightInput,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: TextField(
                controller: controller,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.addCommentPlaceholder,
                  hintStyle: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                ),
              ),
            ),
          ),
          Gap(AppDimens.md),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: AppColors.primaryShadow,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 18.w,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

