import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/post_card.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../providers/post_detail_provider.dart';
import '../widgets/comment_tile.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return postAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const Gap(12),
              Text(AppStrings.errorOccurred,
                  style: AppTextStyles.bodyMedium),
              const Gap(8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(postDetailProvider(postId)),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        final post = data.post;
        if (post == null) {
          return Scaffold(
            appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
            body: const Center(child: Text('Post topilmadi')),
          );
        }

        final notifier = ref.read(postDetailProvider(postId).notifier);
        final currentUserId =
            ref.read(currentUserIdProvider);
        final isOwnPost = post.author.id == currentUserId;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: const Text(AppStrings.postDetail),
            actions: [
              AppIconButton(
                icon: Icons.share_outlined,
                onTap: () => context.showSnackBar(AppStrings.linkCopied),
              ),
              if (isOwnPost)
                AppIconButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: () => _confirmDelete(context, ref),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: PostCard(
                        post: post,
                        onLikeTap: () => notifier.toggleLike(),
                        onCommentTap: null,
                        onShareTap: () =>
                            context.showSnackBar(AppStrings.linkCopied),
                        onSaveTap: null,
                        onMoreTap: null,
                        onUserTap: () => context.push(
                          AppRoutes.userProfilePath(post.author.id),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SectionLabel(
                        '${AppStrings.comments} · ${post.commentsCount}',
                      ),
                    ),
                    if (data.isLoadingComments)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: data.comments.length,
                        itemBuilder: (context, index) {
                          final comment = data.comments[index];
                          return CommentTile(
                            comment: comment,
                            onLikeTap: () =>
                                notifier.toggleCommentLike(comment.id),
                            onReplyTap: () => notifier.setReplyTo(comment.id),
                            onDeleteTap: comment.author.id == currentUserId
                                ? () => _deleteComment(
                                      context, ref, comment.id)
                                : null,
                          );
                        },
                      ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.vlg),
                    ),
                  ],
                ),
              ),
              // Error message
              if (data.hasError)
                Container(
                  color: AppColors.error.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.errorMessage!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Reply banner
              if (data.replyToId != null)
                _ReplyBanner(onClear: notifier.clearReply),
              // Comment input
              _CommentInputBar(
                controller: notifier.commentController,
                onSend: notifier.addComment,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Postni o\'chirish'),
        content: const Text('Bu post butunlay o\'chiriladi. Davom etasizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.delete,
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      try {
        await ref.read(postDetailProvider(postId).notifier).deletePost();
        if (context.mounted) {
          context.showSnackBar(AppStrings.postDeleted);
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          context.showSnackBar(AppStrings.somethingWentWrong);
        }
      }
    }
  }

  Future<void> _deleteComment(
      BuildContext context, WidgetRef ref, String commentId) async {
    // TODO: deleteComment use case — qo'shiladi
  }
}

// ─── Reply Banner ─────────────────────────────────────────────────────────────
class _ReplyBanner extends StatelessWidget {
  const _ReplyBanner({required this.onClear});
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.vsm,
      ),
      color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
      child: Row(
        children: [
          Text(
            'Javob yozilmoqda...',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close_rounded,
                size: 16.w,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted),
          ),
        ],
      ),
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
  final AsyncCallback onSend;

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
          const AppAvatar(initials: 'A', size: AvatarSize.xs),
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
              child: Icon(Icons.send_rounded, size: 18.w, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
