import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class EditRemoteImagePreview extends StatelessWidget {
  const EditRemoteImagePreview({
    super.key,
    required this.url,
    required this.onReplace,
    required this.onRemove,
    required this.isDark,
  });

  final String url;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: AppDimens.postImageAspectRatio,
          child: GestureDetector(
            onTap: onReplace,
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: EditImageActionButton(icon: Icons.close, onTap: onRemove),
        ),
      ],
    );
  }
}

class EditLocalImagePreview extends StatelessWidget {
  const EditLocalImagePreview({
    super.key,
    required this.path,
    required this.onReplace,
    required this.onRemove,
    required this.isDark,
  });

  final String path;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: AppDimens.postImageAspectRatio,
          child: GestureDetector(
            onTap: onReplace,
            child: Image.file(
              File(path),
              key: ValueKey(path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: EditImageActionButton(icon: Icons.close, onTap: onRemove),
        ),
      ],
    );
  }
}

class EditImagePlaceholder extends StatelessWidget {
  const EditImagePlaceholder({
    super.key,
    required this.onTap,
    required this.isDark,
  });

  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: AppDimens.postImageAspectRatio,
        child: ColoredBox(
          color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48.w,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              Gap(AppDimens.vsm),
              Text(
                AppStrings.addPhoto,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditImageActionButton extends StatelessWidget {
  const EditImageActionButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class EditBottomToolbar extends StatelessWidget {
  const EditBottomToolbar({
    super.key,
    required this.onGalleryTap,
    required this.isDark,
  });

  final VoidCallback onGalleryTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final color = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: dividerColor),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding,
              vertical: AppDimens.vsm,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onGalleryTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 22.w, color: color),
                      Gap(6.w),
                      Text(
                        AppStrings.addPhoto,
                        style: AppTextStyles.caption.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
