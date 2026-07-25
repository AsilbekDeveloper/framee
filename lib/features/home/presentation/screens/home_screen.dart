import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/post_card.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../post/domain/entities/post.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
      ref.read(homeProvider.notifier).loadMore().whenComplete(() {
        _loadMorePending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(homeProvider);

    return Scaffold(
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: feedAsync.when(
          loading: () => const LoadingFeed(),
          // Wrapped in a scrollable so pull-to-refresh works, and an explicit
          // Retry button so the user is never stranded on a failed load.
          error: (e, _) => _ScrollableFill(
            child: EmptyState(
              icon: Icons.error_outline,
              title: AppStrings.errorOccurred,
              action: () => ref.read(homeProvider.notifier).refresh(),
              actionLabel: AppStrings.retry,
            ),
          ),
          data: (feed) => feed.posts.isEmpty
              ? _ScrollableFill(
                  child: EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: AppStrings.noPostsYet,
                    subtitle: AppStrings.noPostsYetSub,
                  ),
                )
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverList.builder(
                      addAutomaticKeepAlives: false,
                      itemCount: feed.posts.length,
                      itemBuilder: (context, index) {
                        final post = feed.posts[index];
                        final notifier = ref.read(homeProvider.notifier);
                        final currentUserId = ref.read(currentUserIdProvider);
                        return _HomeFeedItem(
                          key: ValueKey(post.id),
                          post: post,
                          onLikeTap: () => notifier.toggleLike(post.id),
                          onCommentTap: () => context.push(
                            AppRoutes.postDetailPath(post.id),
                          ),
                          onSaveTap: () => notifier.toggleSave(post.id),
                          onMoreTap: () => _showPostOptions(
                            context,
                            post: post,
                            isOwner: post.author.id == currentUserId,
                          ),
                          onUserTap: () => context.push(
                            AppRoutes.userProfilePath(post.author.id),
                          ),
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
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                            )
                          : SizedBox(height: AppDimens.vlg),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showPostOptions(
    BuildContext context, {
    required Post post,
    required bool isOwner,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PostOptionsSheet(
        post: post,
        isSaved: post.isSaved,
        onToggleSave: () =>
            ref.read(homeProvider.notifier).toggleSave(post.id),
        onDelete: isOwner ? () => _confirmDeletePost(post.id) : null,
      ),
    );
  }

  Future<void> _confirmDeletePost(String postId) async {
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
    if (confirm == true && mounted) {
      try {
        await ref.read(homeProvider.notifier).deletePost(postId);
        if (mounted) {
          context.showSnackBar(AppStrings.postDeleted);
        }
      } catch (_) {
        if (mounted) {
          context.showSnackBar(AppStrings.somethingWentWrong);
        }
      }
    }
  }
}

class _HomeFeedItem extends StatelessWidget {
  const _HomeFeedItem({
    super.key,
    required this.post,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onSaveTap,
    required this.onMoreTap,
    required this.onUserTap,
  });

  final Post post;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onSaveTap;
  final VoidCallback onMoreTap;
  final VoidCallback onUserTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: PostCard(
        post: post,
        onLikeTap: onLikeTap,
        onCommentTap: onCommentTap,
        onSaveTap: onSaveTap,
        onMoreTap: onMoreTap,
        onUserTap: onUserTap,
      ),
    );
  }
}

/// Wraps a non-scrollable child (e.g. an empty/error state) so that it fills the
/// viewport and remains over-scrollable — required for [RefreshIndicator]'s
/// pull-to-refresh to work when the feed is empty or has failed to load.
class _ScrollableFill extends StatelessWidget {
  const _ScrollableFill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
