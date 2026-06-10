import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/responsive_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Kichik ekranlarda (< 600 px) scroll bilan ishlaydi,
              // katta ekranlarda Spacer orqali vertikal markazda ko'rinadi.
              final isCompact = constraints.maxHeight < 600;

              if (isCompact) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                    vertical: AppDimens.vxxxl,
                  ),
                  child: _OnboardingContent(),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _OnboardingContent(),
                    const Spacer(flex: 1),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Onboarding asosiy kontent ────────────────────────────────────────────────
class _OnboardingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoArt(),
        Gap(AppDimens.vxxxl),
        Text(
          AppStrings.appTagline,
          style: AppTextStyles.h2.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        Gap(AppDimens.vhuge),
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
        Gap(AppDimens.vlg),
      ],
    );
  }
}

// ─── Logo art ─────────────────────────────────────────────────────────────────
class _LogoArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180.w,
              height: 180.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryMuted,
              ),
            ),
            Container(
              width: 124.w,
              height: 124.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'F',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 56.sp,
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
