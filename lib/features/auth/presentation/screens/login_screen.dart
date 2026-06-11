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
import '../widgets/forgot_password_dialog.dart';
import '../widgets/google_icon.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      builder: (_) => ForgotPasswordDialog(
        initialEmail: _emailController.text,
        onSend: (email) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Parol tiklash havolasi emailingizga yuborildi'),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    ref.read(authProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        context.go(AppRoutes.home);
      }
    });

    final state = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: MaxWidthBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding,
              vertical: AppDimens.vxxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(AppStrings.appName,
                          style: AppTextStyles.displayMedium),
                      Gap(AppDimens.vsm),
                      Text(
                        AppStrings.welcomeBack,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(AppDimens.vmassive),

                AppTextField(
                  controller: _emailController,
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

                AppTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  hint: AppStrings.passwordPlaceholder,
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
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                ],

                Gap(AppDimens.vsm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                Gap(AppDimens.vmd),

                AppButton(
                  label: AppStrings.signIn,
                  onPressed: _submit,
                  isLoading: state.isLoading,
                ),
                Gap(AppDimens.vxl),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorderSubtle
                            : AppColors.lightBorderSubtle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'or',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorderSubtle
                            : AppColors.lightBorderSubtle,
                      ),
                    ),
                  ],
                ),
                Gap(AppDimens.vxl),

                AppButton(
                  label: AppStrings.continueWithGoogle,
                  variant: AppButtonVariant.secondary,
                  onPressed: ref.read(authProvider.notifier).signInWithGoogle,
                  leadingIcon: const GoogleIcon(),
                ),
                Gap(AppDimens.vxxxl),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      Gap(4.w),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.signUp),
                        child: Text(
                          AppStrings.signUp,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
