import 'package:flutter/material.dart';
import '../constants/app_dimens.dart';

/// Returns different layouts for phone vs tablet vs desktop.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppDimens.tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= AppDimens.tabletBreakpoint && w < AppDimens.desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppDimens.desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppDimens.desktopBreakpoint && desktop != null) {
      return desktop!;
    }
    if (width >= AppDimens.tabletBreakpoint && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Constrains max width for tablet/desktop centering.
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Adaptive grid that switches columns based on screen width.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 3,
    this.tabletColumns = 4,
    this.spacing = 2,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveBuilder.isTablet(context) ||
            ResponsiveBuilder.isDesktop(context)
        ? tabletColumns
        : mobileColumns;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: children.length,
      itemBuilder: (_, i) => children[i],
    );
  }
}
