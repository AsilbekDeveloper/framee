import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { large, medium, small }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      AppButtonSize.large => AppDimens.buttonHeightLg,
      AppButtonSize.medium => AppDimens.buttonHeightMd,
      AppButtonSize.small => AppDimens.buttonHeightSm,
    };

    final textStyle = switch (size) {
      AppButtonSize.large => AppTextStyles.buttonLarge,
      AppButtonSize.medium => AppTextStyles.buttonMedium,
      AppButtonSize.small => AppTextStyles.buttonSmall,
    };

    return switch (variant) {
      AppButtonVariant.primary => _PrimaryButton(
          label: label,
          onPressed: onPressed,
          height: height,
          textStyle: textStyle,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
        ),
      AppButtonVariant.secondary => _SecondaryButton(
          label: label,
          onPressed: onPressed,
          height: height,
          textStyle: textStyle,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          leadingIcon: leadingIcon,
        ),
      AppButtonVariant.outline => _OutlineButton(
          label: label,
          onPressed: onPressed,
          height: height,
          textStyle: textStyle,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
        ),
      AppButtonVariant.ghost => _GhostButton(
          label: label,
          onPressed: onPressed,
          height: height,
          textStyle: textStyle,
        ),
      AppButtonVariant.danger => _DangerButton(
          label: label,
          onPressed: onPressed,
          height: height,
          textStyle: textStyle,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
        ),
    };
  }
}

// ─── Primary ──────────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.height,
    required this.textStyle,
    required this.isLoading,
    required this.isFullWidth,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final TextStyle textStyle;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [Color(0xFFBDB8D4), Color(0xFFADA8C8)],
                ),
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          boxShadow: onPressed != null ? AppColors.primaryShadow : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize:
                      isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      leadingIcon!,
                      SizedBox(width: 8.w),
                    ],
                    Text(label, style: textStyle.copyWith(color: Colors.white)),
                    if (trailingIcon != null) ...[
                      SizedBox(width: 8.w),
                      trailingIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Secondary ────────────────────────────────────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    required this.height,
    required this.textStyle,
    required this.isLoading,
    required this.isFullWidth,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final TextStyle textStyle;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isDark ? AppColors.darkElevated : AppColors.lightElevated,
          foregroundColor:
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          side: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
            width: 1.5,
          ),
          shape: const StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    SizedBox(width: 8.w),
                  ],
                  Text(label, style: textStyle),
                ],
              ),
      ),
    );
  }
}

// ─── Outline (Primary colored) ────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.onPressed,
    required this.height,
    required this.textStyle,
    required this.isLoading,
    required this.isFullWidth,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final TextStyle textStyle;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: const StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : Text(label, style: textStyle.copyWith(color: AppColors.primary)),
      ),
    );
  }
}

// ─── Ghost ────────────────────────────────────────────────────────────────────
class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.onPressed,
    required this.height,
    required this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          shape: const StadiumBorder(),
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}

// ─── Danger ───────────────────────────────────────────────────────────────────
class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onPressed,
    required this.height,
    required this.textStyle,
    required this.isLoading,
    required this.isFullWidth,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final TextStyle textStyle;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: const StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: Text(
          label,
          style: textStyle.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}


