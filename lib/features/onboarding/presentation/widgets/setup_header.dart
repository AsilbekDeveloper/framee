import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';

class SetupHeader extends StatelessWidget {
  const SetupHeader({super.key, required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.screenPadding,
        AppDimens.vxl,
        AppDimens.screenPadding,
        0,
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.setUpProfile, style: AppTextStyles.h2),
          Gap(4.h),
          Text(
            AppStrings.setUpProfileSub,
            style: AppTextStyles.bodySmall.copyWith(
              color:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          Gap(AppDimens.vlg),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: LinearProgressIndicator(
              value: step / 3,
              backgroundColor:
                  isDark ? AppColors.darkElevated : AppColors.lightElevated,
              color: AppColors.primary,
              minHeight: 3.h,
            ),
          ),
        ],
      ),
    );
  }
}
