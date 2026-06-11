import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../../core/components/app_avatar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../profile/domain/entities/profile.dart';

class SettingsProfilePreviewTile extends StatelessWidget {
  const SettingsProfilePreviewTile({
    super.key,
    required this.profile,
    required this.onEditTap,
  });

  final Profile profile;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: profile.avatarUrl,
            initials: profile.initials,
            size: AvatarSize.lg,
          ),
          Gap(AppDimens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: AppTextStyles.h4.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Gap(2.h),
                Text(
                  '@${profile.username}',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onEditTap,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, AppDimens.buttonHeightSm),
              padding: EdgeInsets.symmetric(horizontal: AppDimens.lg),
            ),
            child: Text(AppStrings.edit),
          ),
        ],
      ),
    );
  }
}
