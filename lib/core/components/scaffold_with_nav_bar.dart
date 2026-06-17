import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../router/app_router.dart';
import '../services/fcm_service.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import 'no_internet_banner.dart';

/// Shell scaffold with 4 branches: Home(0), Search(1), Notifications(2), Profile(3).
/// The create button pushes a modal route instead of switching branches.
class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  late final StreamSubscription<String> _fcmSub;

  @override
  void initState() {
    super.initState();
    _fcmSub = FcmService.instance.navigationStream.listen((route) {
      if (mounted) context.push(route);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cold start: app terminated holatdan notification tap qilingan bo'lsa
    final pending = FcmService.instance.consumePendingRoute();
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.push(pending);
      });
    }
  }

  @override
  void dispose() {
    _fcmSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);

    return Scaffold(
      body: NoInternetBanner(child: widget.navigationShell),
      bottomNavigationBar: _FrameeBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTabTap: _onTabTap,
        onCreateTap: () => context.push(AppRoutes.createPost),
        showNotificationBadge:
            hasUnread && widget.navigationShell.currentIndex != 2,
      ),
    );
  }

  void _onTabTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _FrameeBottomNav extends StatelessWidget {
  const _FrameeBottomNav({
    required this.currentIndex,
    required this.onTabTap,
    required this.onCreateTap,
    required this.showNotificationBadge,
  });

  final int currentIndex;
  final ValueChanged<int> onTabTap;
  final VoidCallback onCreateTap;
  final bool showNotificationBadge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: AppDimens.bottomNavHeight + bottomPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: AppStrings.home,
            isActive: currentIndex == 0,
            onTap: () {
              HapticFeedback.lightImpact();
              onTabTap(0);
            },
          ),
          _NavItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            label: AppStrings.search,
            isActive: currentIndex == 1,
            onTap: () {
              HapticFeedback.lightImpact();
              onTabTap(1);
            },
          ),
          _CreateButton(
            onTap: () {
              HapticFeedback.mediumImpact();
              onCreateTap();
            },
          ),
          _NavItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: AppStrings.notificationsLabel,
            isActive: currentIndex == 2,
            badge: showNotificationBadge,
            onTap: () {
              HapticFeedback.lightImpact();
              onTabTap(2);
            },
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: AppStrings.profile,
            isActive: currentIndex == 3,
            onTap: () {
              HapticFeedback.lightImpact();
              onTabTap(3);
            },
          ),
        ],
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fixed-size SizedBox ensures the badge Positioned does not affect Column height
            SizedBox(
              width: AppDimens.bottomNavIconSize,
              height: AppDimens.bottomNavIconSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      key: ValueKey(isActive),
                      color: color,
                      size: AppDimens.bottomNavIconSize,
                    ),
                  ),
                  if (badge)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.error,
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
            ),
            SizedBox(height: 3.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
                height: 1.2,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create Button ─────────────────────────────────────────────────────────────

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Label area height matches _NavItem: SizedBox(3.h) + Text(10.sp, height:1.2).
    // Using this offset shifts the box center to the same Y as nav item icons.
    final labelAreaH = 3.h + 10.sp * 1.2;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (_, constraints) {
            // Alignment.y = -1 → top, 0 → center, 1 → bottom.
            // Shifting up by labelAreaH/2 aligns box center with nav icon centers.
            final alignY = -labelAreaH / constraints.maxHeight;
            return Align(
              alignment: Alignment(0, alignY),
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: AppColors.primaryShadow,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
