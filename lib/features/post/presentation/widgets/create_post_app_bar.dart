import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';

class CreatePostAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreatePostAppBar({
    super.key,
    required this.onClose,
    required this.onPost,
    required this.isLoading,
  });

  final VoidCallback onClose;
  final AsyncCallback? onPost;
  final bool isLoading;

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: preferredSize.height + topPadding,
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
      padding: EdgeInsets.only(
        top: topPadding,
        left: AppDimens.xl,
        right: AppDimens.xl,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close_rounded,
              size: AppDimens.iconMd,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          Text(AppStrings.createPost, style: AppTextStyles.h3),
          const Spacer(),
          AnimatedOpacity(
            opacity: onPost != null ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: onPost,
              child: Container(
                height: AppDimens.buttonHeightSm,
                padding: EdgeInsets.symmetric(horizontal: AppDimens.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  boxShadow: onPost != null ? AppColors.primaryShadow : null,
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.post,
                          style: AppTextStyles.buttonSmall
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
