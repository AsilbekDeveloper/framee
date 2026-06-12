import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/post_card.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/router/app_router.dart';
import '../providers/home_provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/loading_feed.dart';
import '../widgets/post_options_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(homeProvider);

    return Scaffold(
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: postsAsync.when(
          loading: () => const LoadingFeed(),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline,
            title: AppStrings.errorOccurred,
            subtitle: AppStrings.tryAgain,
          ),
          data: (posts) => posts.isEmpty
              ? EmptyState(
                  icon: Icons.photo_library_outlined,
                  title: AppStrings.noPostsYet,
                  subtitle: AppStrings.noPostsYetSub,
                )
              : CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) => PostCard(
                        key: ValueKey(posts[index].id),
                        post: posts[index],
                        onLikeTap: () =>
                            ref.read(homeProvider.notifier).toggleLike(
                                  posts[index].id,
                                ),
                        onCommentTap: () => context.push(
                          AppRoutes.postDetailPath(posts[index].id),
                        ),
                        onSaveTap: () =>
                            ref.read(homeProvider.notifier).toggleSave(
                                  posts[index].id,
                                ),
                        onMoreTap: () => _showPostOptions(
                          context,
                          ref: ref,
                          postId: posts[index].id,
                          isSaved: posts[index].isSaved,
                          isOwner: posts[index].author.id ==
                              ref.read(currentUserIdProvider),
                        ),
                        onUserTap: () => context.push(
                          AppRoutes.userProfilePath(posts[index].author.id),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.vlg),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showPostOptions(
    BuildContext context, {
    required WidgetRef ref,
    required String postId,
    required bool isSaved,
    required bool isOwner,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PostOptionsSheet(
        postId: postId,
        isSaved: isSaved,
        onToggleSave: () =>
            ref.read(homeProvider.notifier).toggleSave(postId),
        onDelete: isOwner ? () => _confirmDeletePost(context, ref, postId) : null,
      ),
    );
  }

  Future<void> _confirmDeletePost(
    BuildContext context,
    WidgetRef ref,
    String postId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.deletePost),
        content: Text(AppStrings.deletePostConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      try {
        await ref.read(homeProvider.notifier).deletePost(postId);
        if (context.mounted) {
          context.showSnackBar(AppStrings.postDeleted);
        }
      } catch (_) {
        if (context.mounted) {
          context.showSnackBar(AppStrings.somethingWentWrong);
        }
      }
    }
  }
}
