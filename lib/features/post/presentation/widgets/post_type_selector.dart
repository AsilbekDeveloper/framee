import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../providers/create_post_provider.dart';

class PostTypeSelector extends StatelessWidget {
  const PostTypeSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final PostTypeSelection selected;
  final ValueChanged<PostTypeSelection> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PostTypeSelection.values.map((type) {
          final isSelected = selected == type;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => onSelect(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 34.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryMuted
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.darkBorderSubtle
                            : AppColors.lightBorderSubtle,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    type.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
