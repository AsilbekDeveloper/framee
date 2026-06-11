import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/share_utils.dart';

import '../../../../core/components/post_card.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/router/app_router.dart';
import '../providers/post_detail_provider.dart';
import '../widgets/comment_input_bar.dart';
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
              Text(AppStrings.errorOccurred, style: AppTextStyles.bodyMedium),
              const Gap(8),
              TextButton(
                onPressed: () => ref.invalidate(postDetailProvider(postId)),
                child: Text(AppStrings.retry),
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
        final currentUserId = ref.read(currentUserIdProvider);
        final isOwnPost = post.author.id == currentUserId;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: Text(AppStrings.postDetail),
            actions: [
              AppIconButton(
                icon: Icons.share_outlined,
                onTap: () => _sharePost(context, post),
              ),
              if (isOwnPost)
                AppIconButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: () => _confirmDeletePost(context, ref),
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
                        onShareTap: () => _copyLink(context, post.id),
                        onSaveTap: () => notifier.toggleSave(),
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
                    else if (data.comments.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimens.vxxxl,
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.noCommentsYet,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
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
                            currentUserId: currentUserId,
                            onLikeTap: () =>
                                notifier.toggleCommentLike(comment.id),
                            onReplyLikeTap: (id) =>
                                notifier.toggleCommentLike(id),
                            onReplyTap: () => notifier.setReplyTo(
                              comment.id,
                              comment.author.username,
                            ),
                            onDeleteTap: comment.author.id == currentUserId
                                ? () => _confirmDeleteComment(
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
              if (data.replyToId != null)
                ReplyBanner(
                  username: data.replyToUsername ?? '',
                  onClear: notifier.clearReply,
                ),
              CommentInputBar(
                controller: notifier.commentController,
                focusNode: notifier.commentFocusNode,
                onSend: notifier.addComment,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeletePost(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.deletePost),
        content: Text(AppStrings.deletePostConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.delete,
                style: const TextStyle(color: AppColors.error)),
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

  Future<void> _confirmDeleteComment(
    BuildContext context,
    WidgetRef ref,
    String commentId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.deleteComment),
        content: Text(AppStrings.deleteCommentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await ref
          .read(postDetailProvider(postId).notifier)
          .deleteComment(commentId);
    }
  }

  void _sharePost(BuildContext context, Post post) {
    ShareUtils.sharePost(post);
  }

  void _copyLink(BuildContext context, String postId) {
    Clipboard.setData(ClipboardData(text: ShareUtils.postUrl(postId)));
    if (context.mounted) {
      context.showSnackBar(AppStrings.linkCopied);
    }
  }
}
