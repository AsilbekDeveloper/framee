import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/providers/locale_provider.dart';
import '../../../../../i18n/strings.g.dart';

class SettingsLanguageTile extends ConsumerWidget {
  const SettingsLanguageTile({super.key, required this.currentLocale});
  final AppLocale currentLocale;

  String _name(AppLocale l) => switch (l) {
        AppLocale.en => AppStrings.english,
        AppLocale.uz => AppStrings.uzbek,
        AppLocale.ru => AppStrings.russian,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.xl,
        vertical: AppDimens.vmd,
      ),
      child: Row(
        children: [
          Icon(Icons.language_rounded,
              size: AppDimens.iconMd, color: AppColors.primary),
          Gap(AppDimens.lg),
          Expanded(
            child: Text(
              AppStrings.language,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          PopupMenuButton<AppLocale>(
            initialValue: currentLocale,
            onSelected: (locale) =>
                ref.read(localeProvider.notifier).setLocale(locale),
            itemBuilder: (_) => AppLocale.values
                .map(
                  (l) => PopupMenuItem(
                    value: l,
                    child: Text(
                      _name(l),
                      style: TextStyle(
                        fontWeight: l == currentLocale
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: l == currentLocale ? AppColors.primary : null,
                      ),
                    ),
                  ),
                )
                .toList(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _name(currentLocale),
                  style: AppTextStyles.bodySmall.copyWith(color: mutedColor),
                ),
                Gap(AppDimens.xs),
                Icon(Icons.arrow_drop_down_rounded,
                    size: AppDimens.iconSm, color: mutedColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
