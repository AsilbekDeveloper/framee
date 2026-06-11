import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/components/shared_widgets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/router/app_router.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);
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
          AppIconButton(
            icon: Icons.add_rounded,
            onTap: () => context.push(AppRoutes.createPost),
          ),
          const Spacer(),
          Text(AppStrings.appName, style: AppTextStyles.displayMedium),
          const Spacer(),
          AppIconButton(
            icon: Icons.notifications_outlined,
            onTap: () => context.go(AppRoutes.notifications),
            badge: hasUnread,
          ),
        ],
      ),
    );
  }
}
