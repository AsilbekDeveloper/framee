import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../post/domain/entities/post.dart';
import '../../../../core/constants/app_colors.dart';

/// Profil sahifasidagi rasmli postlar gridi.
/// 2 ustun, 4:5 aspect ratio — portrait uslub.
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

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 3 / 4, // portrait 4:5 uslub
      ),
      itemCount: posts.length,
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

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: post.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
          ),
          errorWidget: (_, _, _) => Container(
            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 24.w,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
    );
  }
}
