import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/errors/failure_message.dart';
import '../../../../../core/errors/result.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../auth/data/providers/auth_data_providers.dart';

class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<ChangePasswordSheet> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPw = _newPasswordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (newPw.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = AppStrings.fillAllFields);
      return;
    }
    if (newPw != confirm) {
      setState(() => _errorMessage = AppStrings.passwordMismatch);
      return;
    }
    // Minimum-length is enforced by UpdatePasswordUseCase, which returns a
    // WeakPasswordFailure surfaced in the Err branch below.

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(updatePasswordUseCaseProvider).call(newPw);

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case Ok():
        context.pop();
        context.showSnackBar(AppStrings.passwordChanged);
      case Err(:final failure):
        setState(() => _errorMessage = localizedFailure(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.xl,
        AppDimens.vxl,
        AppDimens.xl,
        AppDimens.vxl + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBorderSubtle
                    : AppColors.lightBorderSubtle,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Gap(AppDimens.vxl),
          Text(AppStrings.changePassword, style: AppTextStyles.h3),
          Gap(AppDimens.vxl),
          AppTextField(
            controller: _newPasswordController,
            label: AppStrings.newPassword,
            obscureText: true,
          ),
          Gap(AppDimens.vmd),
          AppTextField(
            controller: _confirmController,
            label: AppStrings.confirmPassword,
            obscureText: true,
          ),
          if (_errorMessage != null) ...[
            Gap(AppDimens.vmd),
            Text(
              _errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
          Gap(AppDimens.vlg),
          AppButton(
            label: AppStrings.save,
            onPressed: _submit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
