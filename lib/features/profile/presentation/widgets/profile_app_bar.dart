import 'package:flutter/material.dart';

import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({
    super.key,
    required this.username,
    required this.isOwnProfile,
    this.onSettingsTap,
    required this.onCreateTap,
    this.onBackTap,
  });

  final String username;
  final bool isOwnProfile;
  final VoidCallback? onSettingsTap;
  final VoidCallback onCreateTap;
  final VoidCallback? onBackTap;

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: preferredSize.height + topPadding,
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
      padding: EdgeInsets.only(
        top: topPadding,
        left: AppDimens.xl,
        right: AppDimens.xl,
      ),
      child: Row(
        children: [
          if (isOwnProfile)
            AppIconButton(icon: Icons.add_rounded, onTap: onCreateTap)
          else
            AppIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBackTap ?? () {},
            ),
          const Spacer(),
          Text(username, style: AppTextStyles.h3),
          const Spacer(),
          // Settings navigates to the viewer's own account settings — showing
          // it on someone else's profile would open your settings while
          // looking like it belongs to them.
          if (isOwnProfile)
            AppIconButton(
              icon: Icons.settings_outlined,
              onTap: onSettingsTap!,
            )
          else
            // Matches AppIconButton's rendered width exactly (icon + its 8.w
            // padding on each side) so the title stays visually centered.
            SizedBox(width: AppDimens.iconMd + 16),
        ],
      ),
    );
  }
}
