import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.initialValue,
    this.showTogglePassword = false,
    this.helperText,
    this.errorText,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool showTogglePassword;
  final String? helperText;
  final String? errorText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: AppTextStyles.inputLabel.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Gap(6.h),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: _obscured ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          style: AppTextStyles.inputText.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.inputHint.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 10.w),
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: widget.showTogglePassword
                ? _PasswordToggle(
                    isObscured: _obscured,
                    onToggle: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon != null
                    ? Padding(
                        padding: EdgeInsets.only(right: 14.w),
                        child: widget.suffixIcon,
                      )
                    : null,
            suffixIconConstraints: const BoxConstraints(),
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperStyle: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            counterText: '',
            contentPadding: widget.prefixIcon != null
                ? EdgeInsets.symmetric(vertical: 14.h)
                : EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ],
    );
  }
}

class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({
    required this.isObscured,
    required this.onToggle,
  });

  final bool isObscured;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.only(right: 14.w),
        child: Icon(
          isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppDimens.iconSm,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInput : AppColors.lightInput,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        style: AppTextStyles.inputText.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.inputHint.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 10.w),
            child: Icon(
              Icons.search_rounded,
              size: 18.w,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(),
          suffixIcon: controller != null && (controller!.text.isNotEmpty)
              ? GestureDetector(
                  onTap: () {
                    controller?.clear();
                    onClear?.call();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.w,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
