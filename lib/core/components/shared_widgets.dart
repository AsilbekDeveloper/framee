import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

// ─── Shimmer Box ──────────────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkElevated : const Color(0xFFE8E6F5),
      highlightColor:
          isDark ? AppColors.darkBorderSubtle : const Color(0xFFF4F3FB),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppDimens.radiusSm),
        ),
      ),
    );
  }
}

// ─── Post Card Shimmer ────────────────────────────────────────────────────────
class PostCardShimmer extends StatelessWidget {
  const PostCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppDimens.lg),
            child: Row(
              children: [
                ShimmerBox(
                  width: AppDimens.avatarMd,
                  height: AppDimens.avatarMd,
                  borderRadius: AppDimens.radiusFull,
                ),
                Gap(AppDimens.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120.w, height: 14.h),
                    Gap(AppDimens.vxs),
                    ShimmerBox(width: 60.w, height: 11.h),
                  ],
                ),
              ],
            ),
          ),
          // Image
          ShimmerBox(
            width: double.infinity,
            height: 260.h,
            borderRadius: 0,
          ),
          // Actions
          Padding(
            padding: EdgeInsets.all(AppDimens.lg),
            child: Row(
              children: [
                ShimmerBox(width: 60.w, height: 22.h),
                Gap(AppDimens.lg),
                ShimmerBox(width: 60.w, height: 22.h),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ],
      ),
    );
  }
}

// ─── User Row Shimmer ─────────────────────────────────────────────────────────
class UserRowShimmer extends StatelessWidget {
  const UserRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.md,
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: AppDimens.avatarMd,
            height: AppDimens.avatarMd,
            borderRadius: AppDimens.radiusFull,
          ),
          Gap(AppDimens.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 130.w, height: 15.h),
              Gap(AppDimens.vxs),
              ShimmerBox(width: 90.w, height: 12.h),
            ],
          ),
          const Spacer(),
          ShimmerBox(
            width: 80.w,
            height: 34.h,
            borderRadius: AppDimens.radiusFull,
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                icon,
                size: 32.w,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            ),
            Gap(AppDimens.vxl),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              Gap(AppDimens.vsm),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && actionLabel != null) ...[
              Gap(AppDimens.vxxl),
              ElevatedButton(
                onPressed: action,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.lg, AppDimens.vmd, AppDimens.lg, AppDimens.vxs,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.sectionLabel.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}

// ─── App Divider ──────────────────────────────────────────────────────────────
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.indent = 16});
  final double indent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: indent.w,
      endIndent: indent.w,
      color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
    );
  }
}

// ─── Framee App Bar ───────────────────────────────────────────────────────────
class FrameeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrameeAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.bottom,
    this.showLogoTitle = false,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final bool showLogoTitle;

  @override
  Size get preferredSize => Size.fromHeight(
        AppDimens.appBarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: false,
      title: showLogoTitle
          ? _FrameeLogo()
          : (title != null ? Text(title!) : null),
      actions: actions,
      bottom: bottom,
    );
  }
}

class _FrameeLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Framee',
      style: AppTextStyles.displayMedium,
    );
  }
}

// ─── Icon Action Button (no container) ───────────────────────────────────────
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = false,
    this.size,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconSize = size ?? AppDimens.iconMd;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            if (badge)
              Positioned(
                top: -2,
                right: -3,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
