import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/settings_tiles.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.privacy),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: AppDimens.vxl)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
              child: SettingsCard(
                children: [
                  _PrivacySection(
                    icon: Icons.visibility_outlined,
                    title: AppStrings.pvAccountVisibility,
                    body: AppStrings.pvAccountVisibilityBody,
                    isDark: isDark,
                  ),
                  const AppDivider(),
                  _PrivacySection(
                    icon: Icons.block_outlined,
                    title: AppStrings.pvBlockedUsers,
                    body: AppStrings.pvBlockedUsersBody,
                    isDark: isDark,
                  ),
                  const AppDivider(),
                  _PrivacySection(
                    icon: Icons.comment_outlined,
                    title: AppStrings.pvComments,
                    body: AppStrings.pvCommentsBody,
                    isDark: isDark,
                  ),
                  const AppDivider(),
                  _PrivacySection(
                    icon: Icons.location_off_outlined,
                    title: AppStrings.pvLocationData,
                    body: AppStrings.pvLocationDataBody,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppDimens.vmassive)),
        ],
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.body,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.vmd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppDimens.iconMd,
            color: AppColors.primary,
          ),
          SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: AppDimens.vxs),
                Text(
                  body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
