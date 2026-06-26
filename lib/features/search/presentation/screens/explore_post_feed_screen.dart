import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/post_card.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../providers/explore_feed_provider.dart';
import '../widgets/inline_comments.dart';

/// Opened when a post is tapped in Search/Explore. Shows the tapped post first,
/// then the general feed below it; each post has a collapsible inline comment
/// preview (see [InlineComments]).
class ExplorePostFeedScreen extends ConsumerStatefulWidget {
  const ExplorePostFeedScreen({super.key, required this.initialPostId});

  final String initialPostId;

  @override
  ConsumerState<ExplorePostFeedScreen> createState() =>
      _ExplorePostFeedScreenState();
}

class _ExplorePostFeedScreenState
    extends ConsumerState<ExplorePostFeedScreen> {
  final _scrollController = ScrollController();
  bool _loadMorePending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadMorePending) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMorePending = true;
      ref
          .read(exploreFeedProvider(widget.initialPostId).notifier)
          .loadMore()
          .whenComplete(() => _loadMorePending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(exploreFeedProvider(widget.initialPostId));
    final notifier =
        ref.read(exploreFeedProvider(widget.initialPostId).notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.posts),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: notifier.refresh,
        child: feedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: EmptyState(
              icon: Icons.error_outline,
              title: AppStrings.errorOccurred,
              action: notifier.refresh,
              actionLabel: AppStrings.retry,
            ),
          ),
          data: (feed) {
            if (feed.posts.isEmpty) {
              return EmptyState(
                icon: Icons.photo_library_outlined,
                title: AppStrings.noPostsYet,
                subtitle: AppStrings.noPostsYetSub,
              );
            }
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList.builder(
                  addAutomaticKeepAlives: false,
                  itemCount: feed.posts.length,
                  itemBuilder: (context, index) {
                    final post = feed.posts[index];
                    return Column(
                      key: ValueKey(post.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostCard(
                          post: post,
                          onLikeTap: () => notifier.toggleLike(post.id),
                          onCommentTap: () => context.push(
                            AppRoutes.postDetailPath(post.id),
                          ),
                          onSaveTap: () => notifier.toggleSave(post.id),
                          onUserTap: () => context.push(
                            AppRoutes.userProfilePath(post.author.id),
                          ),
                        ),
                        // Collapsible comment preview under each post.
                        InlineComments(post: post),
                      ],
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: feed.isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : SizedBox(height: AppDimens.vlg),
                ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}
