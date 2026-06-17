import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/post_card.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../post/domain/entities/post.dart';
import '../providers/user_posts_provider.dart';

/// Shows all posts of a user as a vertical feed, scrolled to [initialPostId].
/// Opened when user taps a post in the profile grid.
class ProfilePostsFeedScreen extends ConsumerStatefulWidget {
  const ProfilePostsFeedScreen({
    super.key,
    required this.userId,
    required this.initialPostId,
  });

  final String userId;
  final String initialPostId;

  @override
  ConsumerState<ProfilePostsFeedScreen> createState() =>
      _ProfilePostsFeedScreenState();
}

class _ProfilePostsFeedScreenState
    extends ConsumerState<ProfilePostsFeedScreen> {
  final _scrollController = ScrollController();
  bool _didScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToInitial(List<Post> posts) {
    if (_didScroll) return;
    final index = posts.indexWhere((p) => p.id == widget.initialPostId);
    if (index <= 0) {
      _didScroll = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      // Estimate card height: image (4:3) + header + actions
      final cardHeight =
          MediaQuery.of(context).size.width * (3 / 4) + 120.0;
      final targetOffset = index * cardHeight;
      _scrollController.jumpTo(
        targetOffset.clamp(
            0.0, _scrollController.position.maxScrollExtent),
      );
      _didScroll = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(userPostsProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.posts),
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(AppStrings.errorOccurred, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              AppButton(
                label: AppStrings.retry,
                onPressed: () => ref
                    .read(userPostsProvider(widget.userId).notifier)
                    .refresh(),
              ),
            ],
          ),
        ),
        data: (allPosts) {
          // Show only image posts — same set as the profile image grid
          final imagePosts = allPosts.where((p) => p.hasImage).toList();

          if (imagePosts.isEmpty) {
            return EmptyState(
              icon: Icons.photo_library_outlined,
              title: AppStrings.noPostsYet,
              subtitle: AppStrings.noPostsYetSub,
            );
          }

          _scrollToInitial(imagePosts);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverList.builder(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                itemCount: imagePosts.length,
                itemBuilder: (context, index) {
                  final post = imagePosts[index];
                  return PostCard(
                    key: ValueKey(post.id),
                    post: post,
                    onLikeTap: () => ref
                        .read(userPostsProvider(widget.userId).notifier)
                        .toggleLike(post),
                    onCommentTap: () =>
                        context.push(AppRoutes.postDetailPath(post.id)),
                    onSaveTap: () => ref
                        .read(userPostsProvider(widget.userId).notifier)
                        .toggleSave(post),
                    onMoreTap: null,
                    onUserTap: null,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppDimens.vlg),
              ),
            ],
          );
        },
      ),
    );
  }

}
