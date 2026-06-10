import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/post_card.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../post/domain/entities/post.dart';
import '../../domain/entities/search_result.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.discover)),
      body: Column(
        children: [
          // ── Search Bar ───────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.lg,
              AppDimens.vmd,
              AppDimens.lg,
              AppDimens.vsm,
            ),
            child: AppSearchBar(
              controller: _controller,
              focusNode: _focusNode,
              hint: AppStrings.searchUsersPlaceholder,
              onChanged: (val) => notifier.search(val),
              onClear: () {
                _controller.clear();
                notifier.clearSearch();
              },
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────────
          Expanded(
            child: _buildContent(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
  ) {
    // Active search
    if (state.isQueryActive) {
      if (state.isSearching) {
        return const _SearchLoading(key: ValueKey('loading'));
      }
      if (state.userResults.isEmpty) {
        return const EmptyState(
          key: ValueKey('empty'),
          icon: Icons.search_off_rounded,
          title: AppStrings.noResults,
          subtitle: AppStrings.noResultsSub,
        );
      }
      return _SearchResults(
        key: const ValueKey('results'),
        results: state.userResults,
        onUserTap: (id) => context.push(AppRoutes.userProfilePath(id)),
        onFollowTap: (id) => notifier.toggleFollow(id),
      );
    }

    // Explore grid
    if (state.isLoadingExplore) {
      return const _ExploreShimmer(key: ValueKey('exploreShimmer'));
    }
    return _ExploreGrid(
      key: const ValueKey('explore'),
      posts: state.explorePosts,
      onPostTap: (id) => context.push(AppRoutes.postDetailPath(id)),
      onUserTap: (id) => context.push(AppRoutes.userProfilePath(id)),
      onRefresh: () => notifier.refreshExplore(),
    );
  }
}

// ─── Explore Tab View ─────────────────────────────────────────────────────────

class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid({
    super.key,
    required this.posts,
    required this.onPostTap,
    required this.onUserTap,
    required this.onRefresh,
  });

  final List<Post> posts;
  final ValueChanged<String> onPostTap;
  final ValueChanged<String> onUserTap;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePosts = posts.where((p) => p.hasImage).toList();
    final textPosts = posts.where((p) => !p.hasImage).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // ── Tab bar ───────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.lightBorderSubtle,
                ),
              ),
            ),
            child: TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  icon: Icon(Icons.grid_view_rounded, size: 22.w),
                ),
                Tab(
                  icon: Icon(Icons.format_list_bulleted_rounded, size: 22.w),
                ),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),

          // ── Tab content ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              children: [
                // Tab 0 — Photos grid
                _PhotosTab(
                  posts: imagePosts,
                  onPostTap: onPostTap,
                  onRefresh: onRefresh,
                  isDark: isDark,
                ),
                // Tab 1 — Text posts feed
                _TextTab(
                  posts: textPosts,
                  onPostTap: onPostTap,
                  onUserTap: onUserTap,
                  onRefresh: onRefresh,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photos tab ────────────────────────────────────────────────────────────────

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({
    required this.posts,
    required this.onPostTap,
    required this.onRefresh,
    required this.isDark,
  });

  final List<Post> posts;
  final ValueChanged<String> onPostTap;
  final RefreshCallback onRefresh;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Icon(
                  Icons.photo_outlined,
                  size: 56.w,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: posts.length,
        itemBuilder: (context, i) {
          final post = posts[i];
          return GestureDetector(
            onTap: () => onPostTap(post.id),
            child: _ExploreCell(post: post),
          );
        },
      ),
    );
  }
}

// ── Text posts tab ────────────────────────────────────────────────────────────

class _TextTab extends StatelessWidget {
  const _TextTab({
    required this.posts,
    required this.onPostTap,
    required this.onUserTap,
    required this.onRefresh,
    required this.isDark,
  });

  final List<Post> posts;
  final ValueChanged<String> onPostTap;
  final ValueChanged<String> onUserTap;
  final RefreshCallback onRefresh;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Icon(
                  Icons.text_fields_rounded,
                  size: 56.w,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, i) {
          final post = posts[i];
          return PostCard(
            key: ValueKey(post.id),
            post: post,
            onLikeTap: () => onPostTap(post.id),
            onCommentTap: () => onPostTap(post.id),
            onUserTap: () => onUserTap(post.author.id),
            onMoreTap: null,
            onShareTap: null,
            onSaveTap: null,
          );
        },
      ),
    );
  }
}

// Faqat image postlar uchun — grid thumbnail
class _ExploreCell extends StatelessWidget {
  const _ExploreCell({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CachedNetworkImage(
      imageUrl: post.imageUrl!,
      fit: BoxFit.cover,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, _) => Container(
        color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
      ),
      errorWidget: (_, _, _) => Container(
        color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 20.w,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}

// ─── Explore Shimmer ──────────────────────────────────────────────────────────

class _ExploreShimmer extends StatelessWidget {
  const _ExploreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Tab bar skeleton
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppColors.darkBorderSubtle
                    : AppColors.lightBorderSubtle,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: ShimmerBox(width: 24.w, height: 24.w),
                ),
              ),
              Expanded(
                child: Center(
                  child: ShimmerBox(width: 24.w, height: 24.w),
                ),
              ),
            ],
          ),
        ),
        // Grid skeleton
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: 12,
            itemBuilder: (_, _) => LayoutBuilder(
              builder: (_, constraints) => ShimmerBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Search Results ───────────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    super.key,
    required this.results,
    required this.onUserTap,
    required this.onFollowTap,
  });

  final List<SearchUser> results;
  final ValueChanged<String> onUserTap;
  final ValueChanged<String> onFollowTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SectionLabel(
            '${AppStrings.people} · ${results.length}',
          ),
        ),
        SliverList.separated(
          itemCount: results.length,
          separatorBuilder: (_, _) => const AppDivider(),
          itemBuilder: (context, i) => _UserRow(
            user: results[i],
            onTap: () => onUserTap(results[i].id),
            onFollowTap: () => onFollowTap(results[i].id),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppDimens.vlg)),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.onTap,
    required this.onFollowTap,
  });

  final SearchUser user;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: user.avatarUrl,
              initials: user.initials,
              size: AvatarSize.md,
            ),
            Gap(AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: AppTextStyles.username.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        Gap(4.w),
                        Icon(
                          Icons.verified_rounded,
                          size: 14.w,
                          color: AppColors.primary,
                        ),
                      ],
                      if (user.isPrivate) ...[
                        Gap(4.w),
                        Icon(
                          Icons.lock_rounded,
                          size: 12.w,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ],
                    ],
                  ),
                  Gap(2.h),
                  Text(
                    '@${user.username} · ${user.followersCount.compact} ${AppStrings.followers}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Gap(AppDimens.sm),
            FollowButton(
              isFollowing: user.isFollowing || user.isRequested,
              label: user.isRequested ? 'Requested' : null,
              onTap: onFollowTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Loading ───────────────────────────────────────────────────────────

class _SearchLoading extends StatelessWidget {
  const _SearchLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, _) => const UserRowShimmer(),
    );
  }
}
