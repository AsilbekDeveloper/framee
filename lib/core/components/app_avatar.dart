import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

enum AvatarSize { xs, sm, md, lg, xl, xxl }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = AvatarSize.md,
    this.hasStoryRing = false,
    this.onTap,
    this.customSize,
  });

  final String? imageUrl;
  final String? initials;
  final AvatarSize size;
  final bool hasStoryRing;
  final VoidCallback? onTap;
  final double? customSize;

  double get _size => customSize ??
      switch (size) {
        AvatarSize.xs => AppDimens.avatarXs,
        AvatarSize.sm => AppDimens.avatarSm,
        AvatarSize.md => AppDimens.avatarMd,
        AvatarSize.lg => AppDimens.avatarLg,
        AvatarSize.xl => AppDimens.avatarXl,
        AvatarSize.xxl => AppDimens.avatarXxl,
      };

  @override
  Widget build(BuildContext context) {
    Widget avatar = _buildAvatar(context);

    if (hasStoryRing) {
      avatar = _StoryRing(size: _size, child: avatar);
    }

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Decode the avatar at display resolution instead of full source size —
    // avatars appear in long lists (feed, notifications, followers), so this
    // saves significant memory without affecting layout.
    final cacheSize = (_size * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
        border: hasStoryRing
            ? Border.all(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                width: 2.5,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? imageUrl!.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: cacheSize,
                  memCacheHeight: cacheSize,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                    highlightColor: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) =>
                      _DefaultAvatar(size: _size),
                )
              : Image.file(
                  File(imageUrl!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  // The local path can point to a cache file that the OS has
                  // since evicted — fall back to the default avatar instead
                  // of throwing a PathNotFoundException / showing a broken
                  // image.
                  errorBuilder: (_, _, _) => _DefaultAvatar(size: _size),
                )
          : _DefaultAvatar(size: _size),
    );
  }
}

/// Shown whenever a profile has no avatar (or it fails to load) — a generic
/// silhouette rather than initials, so profiles are visually consistent
/// before the user picks a real photo.
class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: size * 0.65,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  const _StoryRing({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 6.w,
      height: size + 6.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.storyRingGradient,
      ),
      padding: EdgeInsets.all(2.5.w),
      child: child,
    );
  }
}

// ─── Avatar Upload ────────────────────────────────────────────────────────────
class AvatarUpload extends StatelessWidget {
  const AvatarUpload({
    super.key,
    this.imageUrl,
    required this.onTap,
    this.size = 96,
    this.label,
  });

  final String? imageUrl;
  final VoidCallback onTap;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: size.w,
                height: size.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null
                    ? (imageUrl!.startsWith('http')
                        ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover, fadeInDuration: Duration.zero, fadeOutDuration: Duration.zero)
                        : Image.file(
                  File(imageUrl!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.person_outline_rounded,
                    size: 32.w,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ))
                    : Icon(
                        Icons.person_outline_rounded,
                        size: 32.w,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 14.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (label != null) ...[
            SizedBox(height: 10.h),
            Text(
              label!,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
