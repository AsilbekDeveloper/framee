import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/components/responsive_builder.dart';
import '../../../../core/router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _LogoArt(),
                Gap(AppDimens.vxxxl),
                Text(
                  AppStrings.appTagline,
                  style: AppTextStyles.h2.copyWith(
                    color: context.isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                AppButton(
                  label: AppStrings.createAccount,
                  onPressed: () => context.push(AppRoutes.signUp),
                ),
                Gap(AppDimens.vmd),
                AppButton(
                  label: AppStrings.signIn,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push(AppRoutes.login),
                ),
                Gap(AppDimens.vxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Decorative circles
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryMuted,
              ),
            ),
            // Inner circle with logo
            Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'F',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 64.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        Gap(AppDimens.vxxl),
        Text(
          AppStrings.appName,
          style: AppTextStyles.displayLarge,
        ),
      ],
    );
  }
}

// ignore: unused_element
extension _ContextX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
