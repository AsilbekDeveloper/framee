import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
            appBar:
                AppBar(leading: BackButton(onPressed: () => context.pop())),
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
                    else
                      SliverList.builder(
                        itemCount: data.comments.length,
                        itemBuilder: (context, index) {
                          final comment = data.comments[index];
                          return CommentTile(
                            comment: comment,
                            onLikeTap: () =>
                                notifier.toggleCommentLike(comment.id),
                            onReplyTap: () =>
                                notifier.setReplyTo(comment.id),
                            onDeleteTap: comment.author.id == currentUserId
                                ? () =>
                                    _deleteComment(context, ref, comment.id)
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
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (data.replyToId != null)
                ReplyBanner(onClear: notifier.clearReply),
              CommentInputBar(
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
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.delete,
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
    // TODO: deleteComment use case
  }
}
