import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/providers/post_comments_provider.dart';

/// Collapsible, read-only comment preview shown under a post card in the
/// explore feed. Closed by default; "more" reveals 10 top-level comments at a
/// time, "less" collapses back. The full interactive thread is in PostDetail.
class InlineComments extends ConsumerStatefulWidget {
  const InlineComments({super.key, required this.post});

  final Post post;

  @override
  ConsumerState<InlineComments> createState() => _InlineCommentsState();
}

class _InlineCommentsState extends ConsumerState<InlineComments> {
  static const _batch = 10;

  /// Number of top-level comments shown; 0 means collapsed.
  int _visibleCount = 0;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    // Nothing to show for a post with no comments.
    if (post.commentsCount <= 0) return const SizedBox.shrink();

    if (_visibleCount == 0) {
      return _LinkButton(
        label: '${AppStrings.viewComments} (${post.commentsCount})',
        onTap: () => setState(() => _visibleCount = _batch),
      );
    }

    final commentsAsync = ref.watch(postCommentsProvider(post.id));

    return commentsAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.vmd),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => _FooterButtons(
        showMore: false,
        onMore: () {},
        onLess: () => setState(() => _visibleCount = 0),
        leading: Text(
          AppStrings.errorOccurred,
          style: AppTextStyles.caption.copyWith(color: AppColors.error),
        ),
      ),
      data: (all) {
        final topLevel = all.where((c) => c.parentId == null).toList();
        if (topLevel.isEmpty) {
          return _FooterButtons(
            showMore: false,
            onMore: () {},
            onLess: () => setState(() => _visibleCount = 0),
            leading: Text(
              AppStrings.noCommentsYet,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          );
        }

        final visible = topLevel.take(_visibleCount).toList();
        final hasMore = _visibleCount < topLevel.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...visible.map((c) => _InlineCommentRow(comment: c)),
            _FooterButtons(
              showMore: hasMore,
              onMore: () => setState(() => _visibleCount += _batch),
              onLess: () => setState(() => _visibleCount = 0),
            ),
          ],
        );
      },
    );
  }
}

class _InlineCommentRow extends StatelessWidget {
  const _InlineCommentRow({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.vsm, AppDimens.lg, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            imageUrl: comment.author.avatarUrl,
            initials: comment.author.initials,
            size: AvatarSize.xs,
          ),
          Gap(AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.author.username} ',
                        style: AppTextStyles.labelSmall.copyWith(color: textColor),
                      ),
                      TextSpan(
                        text: comment.text,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: textColor, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Gap(2.h),
                Text(
                  comment.createdAt.timeAgo,
                  style: AppTextStyles.caption.copyWith(color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "less" (always when expanded) plus an optional "more" for the next batch.
class _FooterButtons extends StatelessWidget {
  const _FooterButtons({
    required this.showMore,
    required this.onMore,
    required this.onLess,
    this.leading,
  });

  final bool showMore;
  final VoidCallback onMore;
  final VoidCallback onLess;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppDimens.lg, AppDimens.vsm, AppDimens.lg, AppDimens.vsm),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const Spacer(),
          ],
          if (showMore) ...[
            _LinkText(label: AppStrings.more, onTap: onMore),
            Gap(AppDimens.lg),
          ],
          _LinkText(label: AppStrings.showLess, onTap: onLess),
          if (leading == null) const Spacer(),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppDimens.lg, AppDimens.vsm, AppDimens.lg, AppDimens.vsm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _LinkText(label: label, onTap: onTap),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
