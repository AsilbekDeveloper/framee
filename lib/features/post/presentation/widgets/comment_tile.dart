import 'package:flutter/gestures.dart';
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
    required this.onUserTap,
    this.onDeleteTap,
    this.onReplyLikeTap,
    this.onReplyDeleteTap,
    this.currentUserId,
  });

  final Comment comment;
  final VoidCallback onLikeTap;

  /// Called when the user taps "Reply". Receives the username of the tapped
  /// comment/reply author so the input can show the correct @mention, while
  /// the screen keeps the reply attached to the top-level comment.
  final void Function(String username) onReplyTap;

  /// Called when a comment or reply's avatar/username is tapped — navigates
  /// to that author's profile. Receives the tapped author's user id.
  final void Function(String userId) onUserTap;
  final VoidCallback? onDeleteTap;
  final void Function(String commentId)? onReplyLikeTap;
  final void Function(String replyId)? onReplyDeleteTap;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppDimens.lg, AppDimens.vmd, AppDimens.lg, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onUserTap(comment.author.id),
            child: AppAvatar(
              imageUrl: comment.author.avatarUrl,
              initials: comment.author.initials,
              size: AvatarSize.sm,
            ),
          ),
          Gap(AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CommentBubble(
                  comment: comment,
                  textColor: textColor,
                  isDark: isDark,
                  onUserTap: () => onUserTap(comment.author.id),
                ),
                Gap(AppDimens.vxs),
                _CommentMeta(
                  comment: comment,
                  mutedColor: mutedColor,
                  onReplyTap: onReplyTap,
                  onDeleteTap: onDeleteTap,
                ),
                // Replies
                if (comment.replies.isNotEmpty)
                  _RepliesSection(
                    replies: comment.replies,
                    currentUserId: currentUserId,
                    onReplyLikeTap: onReplyLikeTap,
                    onReplyDeleteTap: onReplyDeleteTap,
                    onReplyTap: onReplyTap,
                    onUserTap: onUserTap,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
          Gap(AppDimens.md),
          _LikeButton(
            isLiked: comment.isLiked,
            mutedColor: mutedColor,
            onTap: onLikeTap,
          ),
        ],
      ),
    );
  }
}

// ── Replies section with thread line ─────────────────────────────────────────

class _RepliesSection extends StatelessWidget {
  const _RepliesSection({
    required this.replies,
    required this.currentUserId,
    required this.onReplyLikeTap,
    required this.onReplyDeleteTap,
    required this.onReplyTap,
    required this.onUserTap,
    required this.isDark,
  });

  final List<Comment> replies;
  final String? currentUserId;
  final void Function(String)? onReplyLikeTap;
  final void Function(String)? onReplyDeleteTap;
  final void Function(String username) onReplyTap;
  final void Function(String userId) onUserTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lineColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Padding(
      padding: EdgeInsets.only(top: AppDimens.vsm),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thread line
            Container(
              width: 2,
              margin: EdgeInsets.only(
                left: 12.w,
                right: AppDimens.md,
              ),
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            // Reply tiles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: replies.map((reply) {
                  return _ReplyTile(
                    reply: reply,
                    currentUserId: currentUserId,
                    onLikeTap: () => onReplyLikeTap?.call(reply.id),
                    onDeleteTap: reply.author.id == currentUserId
                        ? () => onReplyDeleteTap?.call(reply.id)
                        : null,
                    onReplyTap: onReplyTap,
                    onUserTap: onUserTap,
                    isDark: isDark,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single reply tile ─────────────────────────────────────────────────────────

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({
    required this.reply,
    required this.currentUserId,
    required this.onLikeTap,
    required this.onDeleteTap,
    required this.onReplyTap,
    required this.onUserTap,
    required this.isDark,
  });

  final Comment reply;
  final String? currentUserId;
  final VoidCallback onLikeTap;
  final VoidCallback? onDeleteTap;
  final void Function(String username) onReplyTap;
  final void Function(String userId) onUserTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.vsm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onUserTap(reply.author.id),
            child: AppAvatar(
              imageUrl: reply.author.avatarUrl,
              initials: reply.author.initials,
              size: AvatarSize.xs,
            ),
          ),
          Gap(AppDimens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CommentBubble(
                  comment: reply,
                  textColor: textColor,
                  isDark: isDark,
                  onUserTap: () => onUserTap(reply.author.id),
                ),
                Gap(AppDimens.vxs),
                _CommentMeta(
                  comment: reply,
                  mutedColor: mutedColor,
                  onReplyTap: onReplyTap,
                  onDeleteTap: onDeleteTap,
                ),
              ],
            ),
          ),
          Gap(AppDimens.sm),
          _LikeButton(
            isLiked: reply.isLiked,
            mutedColor: mutedColor,
            onTap: onLikeTap,
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _CommentBubble extends StatefulWidget {
  const _CommentBubble({
    required this.comment,
    required this.textColor,
    required this.isDark,
    required this.onUserTap,
  });

  final Comment comment;
  final Color textColor;
  final bool isDark;
  final VoidCallback onUserTap;

  @override
  State<_CommentBubble> createState() => _CommentBubbleState();
}

class _CommentBubbleState extends State<_CommentBubble> {
  late TapGestureRecognizer _usernameTap;

  @override
  void initState() {
    super.initState();
    _usernameTap = TapGestureRecognizer()..onTap = widget.onUserTap;
  }

  @override
  void didUpdateWidget(_CommentBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    _usernameTap.onTap = widget.onUserTap;
  }

  @override
  void dispose() {
    _usernameTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkElevated : AppColors.lightElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.comment.author.username} ',
              style: AppTextStyles.labelSmall.copyWith(color: widget.textColor),
              recognizer: _usernameTap,
            ),
            TextSpan(
              text: widget.comment.text,
              style: AppTextStyles.bodySmall
                  .copyWith(color: widget.textColor, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentMeta extends StatelessWidget {
  const _CommentMeta({
    required this.comment,
    required this.mutedColor,
    required this.onReplyTap,
    required this.onDeleteTap,
  });

  final Comment comment;
  final Color mutedColor;
  final void Function(String username) onReplyTap;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          comment.createdAt.timeAgo,
          style: AppTextStyles.caption.copyWith(color: mutedColor),
        ),
        if (comment.likesCount > 0) ...[
          Gap(AppDimens.lg),
          Text(
            '${comment.likesCount.compact} ${AppStrings.likes}',
            style: AppTextStyles.caption.copyWith(color: mutedColor),
          ),
        ],
        Gap(AppDimens.lg),
        GestureDetector(
          onTap: () => onReplyTap(comment.author.username),
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
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.isLiked,
    required this.mutedColor,
    required this.onTap,
  });

  final bool isLiked;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 14.w,
        color: isLiked ? AppColors.like : mutedColor,
      ),
    );
  }
}
