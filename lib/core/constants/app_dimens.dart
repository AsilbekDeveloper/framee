import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Framee spacing, border radius, and size constants.
abstract final class AppDimens {
  // ─── Spacing ──────────────────────────────────────────────
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
  static double get huge => 40.w;
  static double get massive => 48.w;

  // ─── Vertical Spacing ─────────────────────────────────────
  static double get vxs => 4.h;
  static double get vsm => 8.h;
  static double get vmd => 12.h;
  static double get vlg => 16.h;
  static double get vxl => 20.h;
  static double get vxxl => 24.h;
  static double get vxxxl => 32.h;
  static double get vhuge => 40.h;
  static double get vmassive => 48.h;

  // ─── Horizontal Padding ───────────────────────────────────
  static double get screenPadding => 20.w;
  static double get cardPadding => 16.w;

  // ─── Border Radius ────────────────────────────────────────
  static double get radiusXs => 6.r;
  static double get radiusSm => 10.r;
  static double get radiusMd => 16.r;
  static double get radiusLg => 22.r;
  static double get radiusXl => 30.r;
  static double get radiusFull => 100.r;

  // ─── Avatar Sizes ─────────────────────────────────────────
  static double get avatarXs => 28.w;
  static double get avatarSm => 36.w;
  static double get avatarMd => 46.w;
  static double get avatarLg => 64.w;
  static double get avatarXl => 88.w;
  static double get avatarXxl => 96.w;

  // ─── Icon Sizes ───────────────────────────────────────────
  static double get iconSm => 18.w;
  static double get iconMd => 22.w;
  static double get iconLg => 26.w;
  static double get iconXl => 32.w;

  // ─── App Bar ──────────────────────────────────────────────
  static double get appBarHeight => 56.h;
  static double get statusBarExtra => 44.h;

  // ─── Bottom Nav ───────────────────────────────────────────
  static double get bottomNavHeight => 64.h;
  static double get bottomNavIconSize => 24.w;

  // ─── Button Heights ───────────────────────────────────────
  static double get buttonHeightLg => 52.h;
  static double get buttonHeightMd => 44.h;
  static double get buttonHeightSm => 36.h;
  static double get buttonHeightXs => 32.h;

  // ─── Input ────────────────────────────────────────────────
  static double get inputHeight => 52.h;
  static double get inputMinHeight => 44.h;

  // ─── Post ─────────────────────────────────────────────────
  static double get postImageAspectRatio => 4 / 3;
  static double get profileGridCellSize => 124.w;

  // ─── Tablet breakpoint ────────────────────────────────────
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 900;
}
