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

  void _submit() {
    ref.read(authProvider.notifier).signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated == false) {
        context.go(AppRoutes.home);
      }
    });

    final state = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
                // Logo
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.displayMedium,
                      ),
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

                // Email
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

                // Password
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

                // Error message
                if (state.errorMessage != null) ...[
                  Gap(AppDimens.vsm),
                  Text(
                    state.errorMessage!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.error),
                  ),
                ],

                Gap(AppDimens.vsm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot password?',
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

                // Divider
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

                // Google
                AppButton(
                  label: AppStrings.continueWithGoogle,
                  variant: AppButtonVariant.secondary,
                  onPressed: ref.read(authProvider.notifier).signInWithGoogle,
                  leadingIcon: _GoogleIcon(),
                ),
                Gap(AppDimens.vxxxl),

                // Footer
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

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.w,
      height: 20.w,
      child: const _GooglePainter(),
    );
  }
}

class _GooglePainter extends StatelessWidget {
  const _GooglePainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      3.1416,
      true,
      paint,
    );
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      -3.1416,
      true,
      paint,
    );
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.65, paint);
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.15, radius, radius * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
