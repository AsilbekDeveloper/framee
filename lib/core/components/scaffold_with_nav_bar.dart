import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../router/app_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _FrameeBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _FrameeBottomNav extends StatelessWidget {
  const _FrameeBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: AppDimens.bottomNavHeight + MediaQuery.paddingOf(context).bottom,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: AppStrings.home,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            label: AppStrings.search,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          // Center Create Button
          _CreateButton(
            onTap: () => context.push(AppRoutes.createPost),
          ),
          // Notifications - goes outside shell
          _NavIconButton(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: AppStrings.notificationsLabel,
            isActive: false,
            hasNotification: true,
            onTap: () => context.push(AppRoutes.notifications),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: AppStrings.profile,
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: AppDimens.bottomNavIconSize,
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.hasNotification = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: color,
                  size: AppDimens.bottomNavIconSize,
                ),
                if (hasNotification)
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
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: AppColors.primaryShadow,
        ),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 24.w,
        ),
      ),
    );
  }
}
