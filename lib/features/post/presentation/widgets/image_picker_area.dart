import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';

class ImagePickerArea extends StatelessWidget {
  const ImagePickerArea({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: AppDimens.postImageAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40.w,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
              Gap(AppDimens.vmd),
              Text(
                AppStrings.addPhoto,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
              Gap(AppDimens.vxs),
              Text(
                AppStrings.photoFormats,
                style: AppTextStyles.caption.copyWith(
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

class SelectedImage extends StatelessWidget {
  const SelectedImage({
    super.key,
    required this.path,
    required this.onRemove,
    required this.onCrop,
  });

  final String path;
  final VoidCallback onRemove;
  final VoidCallback onCrop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Image.file(
            File(path),
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        Positioned(
          top: 8.h,
          left: 8.w,
          child: _ImageActionButton(icon: Icons.crop_rounded, onTap: onCrop),
        ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child:
              _ImageActionButton(icon: Icons.close_rounded, onTap: onRemove),
        ),
      ],
    );
  }
}

class _ImageActionButton extends StatelessWidget {
  const _ImageActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18.w),
      ),
    );
  }
}
