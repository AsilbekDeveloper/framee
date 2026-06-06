import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/models/ui_models.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onSaveTap,
    required this.onMoreTap,
    required this.onUserTap,
  });

  final PostModel post;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onSaveTap;
  final VoidCallback onMoreTap;
  final VoidCallback onUserTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(
              post: post,
              onUserTap: onUserTap,
              onMoreTap: onMoreTap,
            ),
            if (post.hasImage) _PostImage(imageUrl: post.imageUrl!),
            if (!post.hasImage && post.hasCaption)
              _TextPostBody(caption: post.caption!),
            _PostActions(
              post: post,
              onLikeTap: onLikeTap,
              onCommentTap: onCommentTap,
              onShareTap: onShareTap,
              onSaveTap: onSaveTap,
            ),
            if (post.hasImage && post.hasCaption)
              _PostCaption(post: post, onUserTap: onUserTap),
            Divider(
              height: 1,
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.lightBorderSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _PostHeader extends StatelessWidget {
  const _PostHeader({
    required this.post,
    required this.onUserTap,
    required this.onMoreTap,
  });

  final PostModel post;
  final VoidCallback onUserTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.lg,
        AppDimens.vmd,
        AppDimens.md,
        AppDimens.vsm,
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
                ),
                Gap(AppDimens.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.username,
                      style: AppTextStyles.username.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      post.createdAt.timeAgo,
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
          IconButton(
            onPressed: onMoreTap,
            icon: Icon(
              Icons.more_vert_rounded,
              size: AppDimens.iconMd,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Image ────────────────────────────────────────────────────────────────────
class _PostImage extends StatelessWidget {
  const _PostImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: AppDimens.postImageAspectRatio,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor:
              isDark ? AppColors.darkElevated : const Color(0xFFE8E5FF),
          highlightColor:
              isDark ? AppColors.darkBorderSubtle : const Color(0xFFF4F3FB),
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => Container(
          color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 40.w,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ),
    );
  }
}

// ─── Text Post Body ───────────────────────────────────────────────────────────
class _TextPostBody extends StatelessWidget {
  const _TextPostBody({required this.caption});
  final String caption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.lg,
        AppDimens.vsm,
        AppDimens.lg,
        AppDimens.vlg,
      ),
      child: Text(
        caption,
        style: AppTextStyles.h4.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}

// ─── Actions ──────────────────────────────────────────────────────────────────
class _PostActions extends StatelessWidget {
  const _PostActions({
    required this.post,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onSaveTap,
  });

  final PostModel post;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onSaveTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimens.sm, AppDimens.vsm, AppDimens.sm, AppDimens.vxs),
      child: Row(
        children: [
          // Like
          _ActionButton(
            icon: post.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: post.likesCount.compact,
            color: post.isLiked ? AppColors.like : mutedColor,
            onTap: onLikeTap,
          ),
          // Comment
          _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: post.commentsCount.compact,
            color: mutedColor,
            onTap: onCommentTap,
          ),
          // Share
          _ActionButton(
            icon: Icons.share_outlined,
            color: mutedColor,
            onTap: onShareTap,
          ),
          const Spacer(),
          // Save
          _ActionButton(
            icon: post.isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            color: post.isSaved ? AppColors.primary : mutedColor,
            onTap: onSaveTap,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          children: [
            Icon(icon, size: 22.w, color: color),
            if (label != null) ...[
              Gap(5.w),
              Text(
                label!,
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Caption ──────────────────────────────────────────────────────────────────
class _PostCaption extends StatelessWidget {
  const _PostCaption({required this.post, required this.onUserTap});
  final PostModel post;
  final VoidCallback onUserTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimens.lg, 2.h, AppDimens.lg, AppDimens.vlg),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: onUserTap,
                child: Text(
                  '${post.author.username} ',
                  style: AppTextStyles.username.copyWith(color: textColor),
                ),
              ),
            ),
            TextSpan(
              text: post.caption,
              style: AppTextStyles.bodySmall.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
