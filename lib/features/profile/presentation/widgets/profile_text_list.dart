import 'package:flutter/material.dart';

import '../../../../core/components/post_card.dart';
import '../../../post/domain/entities/post.dart';

/// Sliver list of text-only posts shown on the profile page.
/// Each post is rendered with the universal [PostCard] widget.
class ProfileTextList extends StatelessWidget {
  const ProfileTextList({
    super.key,
    required this.posts,
    required this.onPostTap,
    required this.onUserTap,
  });

  final List<Post> posts;
  final ValueChanged<String> onPostTap;
  final ValueChanged<String> onUserTap;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverList.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
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
    );
  }
}
