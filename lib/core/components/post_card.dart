import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../extensions/extensions.dart';
import '../utils/share_utils.dart';
import 'app_avatar.dart';
import '../../features/post/domain/entities/post.dart';

/// Universal post card used across home feed, post detail, profile list, and search.
/// All callbacks are optional: when null the corresponding element is hidden or non-interactive.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLikeTap,
    this.onCommentTap,
    this.onSaveTap,
    this.onMoreTap,
    this.onUserTap,
  });

  final Post post;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onUserTap;

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
            if (post.hasImage)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
                child: _PostImage(imageUrl: post.imageUrl!),
              ),
            if (!post.hasImage && post.hasCaption)
              _TextPostBody(caption: post.caption!),
            _PostActions(
              post: post,
              onLikeTap: onLikeTap,
              onCommentTap: onCommentTap,
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

  final Post post;
  final VoidCallback? onUserTap;
  final VoidCallback? onMoreTap;

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
                    Row(
                      children: [
                        Text(
                          post.author.username,
                          style: AppTextStyles.username.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (post.author.isVerified) ...[
                          Gap(3.w),
                          Icon(
                            Icons.verified_rounded,
                            size: 13.w,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
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
          if (onMoreTap != null)
            IconButton(
              onPressed: onMoreTap,
              icon: Icon(
                Icons.more_vert_rounded,
                size: AppDimens.iconMd,
                color:
                    isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      memCacheWidth: 800,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Image(
          image: imageProvider,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
      placeholder: (context, url) => AspectRatio(
        aspectRatio: AppDimens.postImageAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Shimmer.fromColors(
            baseColor: isDark ? AppColors.darkElevated : const Color(0xFFE8E5FF),
            highlightColor:
                isDark ? AppColors.darkBorderSubtle : const Color(0xFFF4F3FF),
            child: Container(color: Colors.white),
          ),
        ),
      ),
      errorWidget: (context, url, error) => AspectRatio(
        aspectRatio: AppDimens.postImageAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Container(
            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 40.w,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
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
    required this.onSaveTap,
  });

  final Post post;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onSaveTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppDimens.sm, AppDimens.vsm, AppDimens.sm, AppDimens.vxs),
      child: Row(
        children: [
          _ActionButton(
            icon: post.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: post.likesCount.compact,
            color: post.isLiked ? AppColors.like : mutedColor,
            onTap: onLikeTap,
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: post.commentsCount.compact,
            color: mutedColor,
            onTap: onCommentTap,
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            color: mutedColor,
            onTap: () => _showShareSheet(context, post),
          ),
          const Spacer(),
          if (onSaveTap != null)
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

void _showShareSheet(BuildContext context, Post post) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor =
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  final mutedColor =
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

  showModalBottomSheet(
    context: context,
    backgroundColor: bgColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.radiusXl),
      ),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.vlg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: AppDimens.vlg),
              decoration: BoxDecoration(
                color: mutedColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _ShareOption(
              icon: Icons.share_outlined,
              label: AppStrings.sharePost,
              textColor: textColor,
              onTap: () {
                Navigator.pop(context);
                ShareUtils.sharePost(post);
              },
            ),
            _ShareOption(
              icon: Icons.link_rounded,
              label: AppStrings.copyLink,
              textColor: textColor,
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                  ClipboardData(text: ShareUtils.postUrl(post.id)),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.linkCopied),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.screenPadding,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.w, color: textColor),
            Gap(AppDimens.lg),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
          ],
        ),
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
  final VoidCallback? onTap;
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
class _PostCaption extends StatefulWidget {
  const _PostCaption({required this.post, required this.onUserTap});
  final Post post;
  final VoidCallback? onUserTap;

  @override
  State<_PostCaption> createState() => _PostCaptionState();
}

class _PostCaptionState extends State<_PostCaption> {
  static const _maxLines = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final usernameStyle = AppTextStyles.username.copyWith(color: textColor);
    final captionStyle = AppTextStyles.bodySmall.copyWith(color: textColor);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppDimens.lg, 6.h, AppDimens.lg, AppDimens.vlg),
      child: LayoutBuilder(builder: (_, constraints) {
        // Measure username + caption together to detect overflow
        final overflows = _doesOverflow(
          constraints.maxWidth,
          usernameStyle,
          captionStyle,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              maxLines: _expanded ? null : _maxLines,
              overflow:
                  _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: widget.onUserTap,
                      child: Text(
                        '${widget.post.author.username} ',
                        style: usernameStyle,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: widget.post.caption,
                    style: captionStyle,
                  ),
                ],
              ),
            ),
            if (overflows && !_expanded) ...[
              Gap(2.h),
              GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: Text(
                  AppStrings.more,
                  style: captionStyle.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  bool _doesOverflow(
    double maxWidth,
    TextStyle usernameStyle,
    TextStyle captionStyle,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${widget.post.author.username} ',
            style: usernameStyle,
          ),
          TextSpan(
            text: widget.post.caption,
            style: captionStyle,
          ),
        ],
      ),
      maxLines: _maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp.didExceedMaxLines;
  }
}
