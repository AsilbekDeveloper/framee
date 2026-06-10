import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import 'app_button.dart';

/// Umumiy xatolik holati widget'i.
///
/// Xatolik sodir bo'lganda va qayta urinish tugmasi kerak bo'lganda
/// barcha screen'larda shu widget'ni ishlatish tavsiya etiladi.
///
/// ```dart
/// error: (e, _) => AppErrorWidget(onRetry: () => ref.invalidate(myProvider)),
/// ```
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.title,
    this.subtitle,
    this.onRetry,
    this.icon,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 48,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            Gap(AppDimens.vmd),
            Text(
              title ?? AppStrings.errorOccurred,
              style: AppTextStyles.h4.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              Gap(AppDimens.vxs),
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
            if (onRetry != null) ...[
              Gap(AppDimens.vxl),
              AppButton(
                label: AppStrings.tryAgain,
                onPressed: onRetry,
                variant: AppButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
