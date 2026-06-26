import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../post/domain/entities/post.dart';
import '../../../../core/constants/app_colors.dart';

/// Profil sahifasidagi rasmli postlar gridi.
/// 2 ustun masonry — har bir rasm faqat eniga moslanadi (ustun kengligi),
/// bo'yi rasmning asl nisbatiga qarab o'zgaradi. Rasm kesilmaydi.
class ProfileImageGrid extends StatelessWidget {
  const ProfileImageGrid({
    super.key,
    required this.posts,
    required this.onPostTap,
  });

  final List<Post> posts;
  final ValueChanged<String> onPostTap;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () => onPostTap(post.id),
          child: _ImageCell(post: post),
        );
      },
    );
  }
}

class _ImageCell extends StatelessWidget {
  const _ImageCell({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 2-column grid with 2px spacing → each cell ≈ half screen width
    final cellWidth = ((MediaQuery.sizeOf(context).width - 2) / 2).round();
    // Decode at physical-pixel resolution so the image stays sharp on
    // high-density screens (logical width × devicePixelRatio).
    final decodeWidth =
        (cellWidth * MediaQuery.devicePixelRatioOf(context)).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: post.imageUrl!,
            // Eni to'liq, bo'yi rasm nisbatiga mos — ratio o'zgarmaydi.
            width: cellWidth.toDouble(),
            fit: BoxFit.fitWidth,
            memCacheWidth: decodeWidth,
            // Rasm yuklanmaguncha — kvadrat o'rinbosar (joy egallab turadi).
            placeholder: (_, _) => AspectRatio(
              aspectRatio: 1,
              child: Container(
                color:
                    isDark ? AppColors.darkElevated : AppColors.lightElevated,
              ),
            ),
            errorWidget: (_, _, _) => AspectRatio(
              aspectRatio: 1,
              child: Container(
                color:
                    isDark ? AppColors.darkElevated : AppColors.lightElevated,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 24.w,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ),
          ),
          // Caption bo'lsa — pastida overlay
          if (post.hasCaption)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
                child: Text(
                  post.caption!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
