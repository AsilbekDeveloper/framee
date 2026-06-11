import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../providers/create_post_provider.dart';

class CaptionField extends StatelessWidget {
  const CaptionField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isDark,
    required this.charCount,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final int charCount;

  static const _maxChars = CreatePostState.maxCaptionLength;
  bool get _isOverLimit => charCount > _maxChars;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: null,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.writeCaptionPlaceholder,
            hintStyle: AppTextStyles.inputHint.copyWith(
              color:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            contentPadding: EdgeInsets.all(AppDimens.lg),
            enabledBorder: _isOverLimit
                ? OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.error),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  )
                : null,
          ),
        ),
        Gap(AppDimens.vxs),
        Text(
          '$charCount / $_maxChars',
          style: AppTextStyles.caption.copyWith(
            color: _isOverLimit
                ? AppColors.error
                : isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
            fontWeight:
                _isOverLimit ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
