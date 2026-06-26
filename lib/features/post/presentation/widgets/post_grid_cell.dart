import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors
        .postGridGradients[post.id.hashCode.abs() % AppColors.postGridGradients.length];

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
