import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.termsOfService),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.screenPadding,
          vertical: AppDimens.vxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.termsLastUpdated,
              style: AppTextStyles.caption.copyWith(color: mutedColor),
            ),
            SizedBox(height: AppDimens.vxl),
            _Section(
              title: AppStrings.termsSection1Title,
              body: AppStrings.termsSection1Body,
              bodyColor: bodyColor,
            ),
            _Section(
              title: AppStrings.termsSection2Title,
              body: AppStrings.termsSection2Body,
              bodyColor: bodyColor,
            ),
            _Section(
              title: AppStrings.termsSection3Title,
              body: AppStrings.termsSection3Body,
              bodyColor: bodyColor,
            ),
            _Section(
              title: AppStrings.termsSection4Title,
              body: AppStrings.termsSection4Body,
              bodyColor: bodyColor,
            ),
            _Section(
              title: AppStrings.termsSection5Title,
              body: AppStrings.termsSection5Body,
              bodyColor: bodyColor,
            ),
            _Section(
              title: AppStrings.termsSection6Title,
              body: AppStrings.termsSection6Body,
              bodyColor: bodyColor,
            ),
            _Section(
              title: AppStrings.termsSection7Title,
              body: AppStrings.termsSection7Body,
              bodyColor: bodyColor,
            ),
            SizedBox(height: AppDimens.vmd),
            Text(
              AppStrings.termsContact,
              style: AppTextStyles.caption.copyWith(color: mutedColor),
            ),
            SizedBox(height: AppDimens.vmassive),
          ],
        ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.body,
    required this.bodyColor,
  });

  final String title;
  final String body;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.vxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(color: bodyColor),
          ),
          SizedBox(height: AppDimens.vsm),
          Text(
            body,
            style: AppTextStyles.bodySmall
                .copyWith(color: bodyColor, height: 1.6),
          ),
        ],
      ),
    );
  }
}
