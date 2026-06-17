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
import '../widgets/signup_header.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
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
        title: Text(AppStrings.confirmEmailTitle),
        content: Text(AppStrings.confirmEmailBody(_emailController.text)),
        actions: [
          TextButton(
            onPressed: () {
              ctx.pop();
              ctx.go(AppRoutes.login);
            },
            child: Text(AppStrings.goToSignIn),
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
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        context.go(AppRoutes.profileSetup);
      }
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
              const SignUpHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                    vertical: AppDimens.vxl,
                  ),
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _fullNameController,
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

                      AppTextField(
                        controller: _confirmPasswordController,
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
                        onPressed: _submit,
                        isLoading: state.isLoading,
                      ),
                      Gap(AppDimens.vxxxl),

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
                            onTap: () {
                              ref.read(authProvider.notifier).clearError();
                              context.pop();
                            },
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
