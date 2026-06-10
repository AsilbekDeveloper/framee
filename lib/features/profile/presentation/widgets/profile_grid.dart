import 'package:flutter/material.dart';

import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/widgets/post_grid_cell.dart';

class ProfileGrid extends StatelessWidget {
  const ProfileGrid({
    super.key,
    required this.posts,
    required this.onPostTap,
  });

  final List<Post> posts;
  final ValueChanged<String> onPostTap;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => onPostTap(posts[index].id),
        child: PostGridCell(post: posts[index]),
      ),
    );
  }
}
