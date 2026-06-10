import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';

/// Profile grid ve explore grid uchun umumiy cell widget.
class PostGridCell extends StatelessWidget {
  const PostGridCell({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (post.hasImage) {
      return CachedNetworkImage(
        imageUrl: post.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, _) => _Placeholder(post: post, isDark: isDark),
        errorWidget: (_, _, _) => _Placeholder(post: post, isDark: isDark),
      );
    }

    return _Placeholder(post: post, isDark: isDark);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.post, required this.isDark});
  final Post post;
  final bool isDark;

  static const List<List<Color>> _gradients = [
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
    final colors = _gradients[post.id.hashCode.abs() % _gradients.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: post.hasCaption
          ? Text(
              post.caption!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            )
          : Icon(
              Icons.format_quote_rounded,
              size: 22,
              color: Colors.white.withValues(alpha: 0.4),
            ),
    );
  }
}
