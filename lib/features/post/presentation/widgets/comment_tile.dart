import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/post.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.onLikeTap,
    required this.onReplyTap,
    this.onDeleteTap,
    this.currentUserId,
    this.isReply = false,
  });

  final Comment comment;
  final VoidCallback onLikeTap;
  /// Called with the author's username so the banner can show "@username"
  final void Function() onReplyTap;
  final VoidCallback? onDeleteTap;
  final String? currentUserId;
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
                // Comment bubble
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkElevated
                        : AppColors.lightElevated,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: RichText(
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
                ),
                Gap(AppDimens.vxs),
                // Meta row
                Row(
                  children: [
                    Text(
                      comment.createdAt.timeAgo,
                      style:
                          AppTextStyles.caption.copyWith(color: mutedColor),
                    ),
                    Gap(AppDimens.lg),
                    if (comment.likesCount > 0) ...[
                      Text(
                        '${comment.likesCount.compact} ${AppStrings.likes}',
                        style: AppTextStyles.caption
                            .copyWith(color: mutedColor),
                      ),
                      Gap(AppDimens.lg),
                    ],
                    if (!isReply)
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
                      currentUserId: currentUserId,
                      onLikeTap: () {},
                      onReplyTap: onReplyTap,
                      onDeleteTap: reply.author.id == currentUserId
                          ? onDeleteTap
                          : null,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
