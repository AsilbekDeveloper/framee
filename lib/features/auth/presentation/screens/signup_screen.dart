import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/responsive_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // 1. UI controllers live safely in the state
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // 2. Dispose to prevent memory leaks
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showEmailConfirmationDialog(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Emailingizni tasdiqlang'),
        content: Text(
          '${_emailController.text} manziliga tasdiqlash havolasi yuborildi. '
          'Emailingizni tasdiqlang va qayta kiring.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctx.pop();
              ctx.go(AppRoutes.login);
            },
            child: const Text('Kirish sahifasiga o\'tish'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    ref.read(authProvider.notifier).signUp(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Muvaffaqiyatli ro'yxatdan o'tish — profile setup sahifasiga
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        context.go(AppRoutes.profileSetup);
      }
      // Email tasdiqlash kutilmoqda — dialog ko'rsatamiz
      if (next.awaitingEmailConfirmation &&
          !(previous?.awaitingEmailConfirmation ?? false)) {
        _showEmailConfirmationDialog(context);
      }
    });

    final state = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: MaxWidthBox(
          child: Column(
            children: [
              // Header
              _SignUpHeader(),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                    vertical: AppDimens.vxl,
                  ),
                  child: Column(
                    children: [
                      // Full Name
                      AppTextField(
                        controller: _fullNameController, // Use local controller
                        label: AppStrings.fullName,
                        hint: AppStrings.fullNamePlaceholder,
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          size: AppDimens.iconSm,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      Gap(AppDimens.vlg),

                      // Email
                      AppTextField(
                        controller: _emailController, // Use local controller
                        label: AppStrings.email,
                        hint: AppStrings.emailPlaceholder,
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          size: AppDimens.iconSm,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      Gap(AppDimens.vlg),

                      // Password
                      AppTextField(
                        controller: _passwordController, // Use local controller
                        label: AppStrings.password,
                        hint: AppStrings.minPasswordPlaceholder,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: AppDimens.iconSm,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        obscureText: true,
                        showTogglePassword: true,
                        textInputAction: TextInputAction.next,
                      ),
                      Gap(AppDimens.vlg),

                      // Confirm Password
                      AppTextField(
                        controller: _confirmPasswordController, // Use local controller
                        label: AppStrings.confirmPassword,
                        hint: AppStrings.repeatPasswordPlaceholder,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: AppDimens.iconSm,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        obscureText: true,
                        showTogglePassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),

                      if (state.errorMessage != null) ...[
                        Gap(AppDimens.vsm),
                        Text(
                          state.errorMessage!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.error),
                        ),
                      ],

                      Gap(AppDimens.vxl),

                      // Terms
                      Text(
                        AppStrings.bySigningUp,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(AppDimens.vxl),

                      AppButton(
                        label: AppStrings.createAccount,
                        onPressed: _submit, // Call local submit method
                        isLoading: state.isLoading,
                      ),
                      Gap(AppDimens.vxxxl),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.alreadyHaveAccount,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          Gap(4.w),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              AppStrings.signIn,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignUpHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.screenPadding,
        AppDimens.vxl,
        AppDimens.screenPadding,
        AppDimens.vxl,
      ),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: AppDimens.iconMd,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          Gap(AppDimens.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.createAccount, style: AppTextStyles.h3),
              Gap(2.h),
              Text(
                AppStrings.joinFramee,
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}