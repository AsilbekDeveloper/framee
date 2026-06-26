import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
    this.isFollowBack = false,
    this.isLoading = false,
    this.label,
  });

  final bool isFollowing;
  final VoidCallback onTap;
  final bool isFollowBack;
  final bool isLoading;

  /// Optional override label (e.g. 'Requested')
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: isFollowing
              ? (isDark ? AppColors.darkElevated : AppColors.lightElevated)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: isFollowing
              ? Border.all(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.lightBorderSubtle,
                  width: 1.5,
                )
              : null,
          boxShadow: isFollowing ? null : AppColors.primaryShadow,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isFollowing
                        ? (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)
                        : Colors.white,
                  ),
                )
              : Text(
                  label ??
                      (isFollowing
                          ? AppStrings.following
                          : isFollowBack
                              ? AppStrings.followBack
                              : AppStrings.follow),
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: isFollowing
                        ? (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)
                        : Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
