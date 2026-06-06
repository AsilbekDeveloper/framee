import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/models/ui_models.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.onLikeTap,
    required this.onReplyTap,
    this.onDeleteTap,
    this.isReply = false,
  });

  final CommentModel comment;
  final VoidCallback onLikeTap;
  final VoidCallback onReplyTap;
  final VoidCallback? onDeleteTap;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isReply ? 62.w : AppDimens.lg,
        AppDimens.vmd,
        AppDimens.lg,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            imageUrl: comment.author.avatarUrl,
            initials: comment.author.initials,
            size: isReply ? AvatarSize.xs : AvatarSize.sm,
          ),
          Gap(AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.author.username} ',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: textColor),
                      ),
                      TextSpan(
                        text: comment.text,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: textColor, height: 1.45),
                      ),
                    ],
                  ),
                ),
                Gap(AppDimens.vxs),
                // Meta row
                Row(
                  children: [
                    Text(
                      comment.createdAt.timeAgo,
                      style: AppTextStyles.caption
                          .copyWith(color: mutedColor),
                    ),
                    Gap(AppDimens.lg),
                    GestureDetector(
                      onTap: onReplyTap,
                      child: Text(
                        AppStrings.reply,
                        style: AppTextStyles.caption.copyWith(
                          color: mutedColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (onDeleteTap != null) ...[
                      Gap(AppDimens.lg),
                      GestureDetector(
                        onTap: onDeleteTap,
                        child: Text(
                          AppStrings.delete,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Nested replies
                if (comment.replies.isNotEmpty) ...[
                  Gap(AppDimens.vsm),
                  ...comment.replies.map(
                    (reply) => CommentTile(
                      comment: reply,
                      onLikeTap: () {},
                      onReplyTap: onReplyTap,
                      isReply: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Gap(AppDimens.md),
          // Like button
          GestureDetector(
            onTap: onLikeTap,
            child: Column(
              children: [
                Icon(
                  comment.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 14.w,
                  color: comment.isLiked ? AppColors.like : mutedColor,
                ),
                if (comment.likesCount > 0) ...[
                  Gap(2.h),
                  Text(
                    comment.likesCount.compact,
                    style: AppTextStyles.overline
                        .copyWith(color: mutedColor),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
