import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/components/shared_widgets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';

class PostOptionsSheet extends StatelessWidget {
  const PostOptionsSheet({
    super.key,
    required this.postId,
    required this.isSaved,
    required this.onToggleSave,
  });

  final String postId;
  final bool isSaved;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(AppDimens.vmd),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.lightBorderSubtle,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Gap(AppDimens.vlg),
          Text(AppStrings.options, style: AppTextStyles.h4),
          Gap(AppDimens.vsm),
          SheetOption(
            icon: Icons.link_rounded,
            label: AppStrings.copyLink,
            onTap: () => context.pop(),
          ),
          const AppDivider(),
          SheetOption(
            icon: Icons.share_outlined,
            label: AppStrings.sharePost,
            onTap: () => context.pop(),
          ),
          const AppDivider(),
          SheetOption(
            icon: isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            label: isSaved ? AppStrings.postSaved : AppStrings.savePost,
            onTap: () {
              onToggleSave();
              context.pop();
            },
          ),
          const AppDivider(),
          SheetOption(
            icon: Icons.flag_outlined,
            label: AppStrings.reportPost,
            onTap: () => context.pop(),
          ),
          const AppDivider(),
          SheetOption(
            icon: Icons.delete_outline_rounded,
            label: AppStrings.deletePost,
            color: AppColors.error,
            onTap: () => context.pop(),
          ),
          Gap(AppDimens.vlg + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

class SheetOption extends StatelessWidget {
  const SheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.xl,
          vertical: AppDimens.vxl,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppDimens.iconMd, color: textColor),
            Gap(AppDimens.lg),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}
