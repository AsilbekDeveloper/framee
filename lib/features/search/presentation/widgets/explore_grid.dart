import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/components/post_card.dart';
import '../../../../../core/components/shared_widgets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../post/domain/entities/post.dart';

class ExploreGrid extends StatelessWidget {
  const ExploreGrid({
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
                Tab(icon: Icon(Icons.grid_view_rounded, size: 22.w)),
                Tab(
                    icon: Icon(Icons.format_list_bulleted_rounded, size: 22.w)),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ExplorePhotosTab(
                  posts: imagePosts,
                  onPostTap: onPostTap,
                  onRefresh: onRefresh,
                  isDark: isDark,
                ),
                ExploreTextTab(
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

class ExplorePhotosTab extends StatelessWidget {
  const ExplorePhotosTab({
    super.key,
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
                  color:
                      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => onPostTap(posts[i].id),
          child: ExploreCell(post: posts[i]),
        ),
      ),
    );
  }
}

class ExploreTextTab extends StatelessWidget {
  const ExploreTextTab({
    super.key,
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
                  color:
                      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
            onSaveTap: null,
          );
        },
      ),
    );
  }
}

class ExploreCell extends StatelessWidget {
  const ExploreCell({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Decode at the grid-cell resolution (3 columns) rather than full size —
    // keeps the image cache small when many thumbnails are on screen.
    final cellWidth = MediaQuery.sizeOf(context).width / 3;
    final cacheWidth =
        (cellWidth * MediaQuery.devicePixelRatioOf(context)).round();

    return CachedNetworkImage(
      imageUrl: post.imageUrl!,
      fit: BoxFit.cover,
      memCacheWidth: cacheWidth,
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

class ExploreShimmer extends StatelessWidget {
  const ExploreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
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
                child: Center(child: ShimmerBox(width: 24.w, height: 24.w)),
              ),
              Expanded(
                child: Center(child: ShimmerBox(width: 24.w, height: 24.w)),
              ),
            ],
          ),
        ),
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

