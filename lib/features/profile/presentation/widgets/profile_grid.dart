import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/ui_models.dart';

class ProfileGrid extends StatelessWidget {
  const ProfileGrid({
    super.key,
    required this.posts,
    required this.onPostTap,
  });

  final List<PostModel> posts;
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
      itemBuilder: (context, index) => _GridCell(
        post: posts[index],
        onTap: () => onPostTap(posts[index].id),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.post, required this.onTap});

  final PostModel post;
  final VoidCallback onTap;

  static const List<List<Color>> _placeholderColors = [
    [Color(0xFFe8e5ff), Color(0xFFd4caff)],
    [Color(0xFFffecd2), Color(0xFFfcb69f)],
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFFd4fc79), Color(0xFF96e6a1)],
    [Color(0xFFf7971e), Color(0xFFffd200)],
    [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _placeholderColors[
      post.id.hashCode.abs() % _placeholderColors.length
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: post.hasImage
            ? null // CachedNetworkImage in production
            : Icon(
                Icons.format_quote_rounded,
                size: 22.w,
                color: Colors.white.withOpacity(0.4),
              ),
      ),
    );
  }
}
