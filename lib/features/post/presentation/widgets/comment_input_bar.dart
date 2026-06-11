import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../../core/components/app_avatar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';

class ReplyBanner extends StatelessWidget {
  const ReplyBanner({super.key, required this.onClear});
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.vsm,
      ),
      color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
      child: Row(
        children: [
          Text(
            'Javob yozilmoqda...',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 16.w,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentInputBar extends StatelessWidget {
  const CommentInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final AsyncCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.lg,
        AppDimens.vmd,
        AppDimens.lg,
        AppDimens.vmd + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      child: Row(
        children: [
          const AppAvatar(initials: 'A', size: AvatarSize.xs),
          Gap(AppDimens.md),
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.lightInput,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: TextField(
                controller: controller,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.addCommentPlaceholder,
                  hintStyle: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                ),
              ),
            ),
          ),
          Gap(AppDimens.md),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: AppColors.primaryShadow,
              ),
              child:
                  Icon(Icons.send_rounded, size: 18.w, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
