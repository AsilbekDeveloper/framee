import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/connectivity_provider.dart';

class NoInternetBanner extends ConsumerWidget {
  const NoInternetBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return Stack(
      children: [
        child,
        connectivityAsync.when(
          data: (isConnected) => isConnected
              ? const SizedBox.shrink()
              : Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _OfflineBanner(),
                ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: AppColors.error,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 16.w, color: Colors.white),
              Gap(8.w),
              Text(
                'No internet connection',
                style: AppTextStyles.labelSmall
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
