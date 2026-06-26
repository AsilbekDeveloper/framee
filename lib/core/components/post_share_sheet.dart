import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../utils/share_utils.dart';
import '../../features/post/domain/entities/post.dart';

void showPostShareSheet(BuildContext context, Post post) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor =
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  final mutedColor =
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

  showModalBottomSheet(
    context: context,
    backgroundColor: bgColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.radiusXl),
      ),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.vlg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: AppDimens.vlg),
              decoration: BoxDecoration(
                color: mutedColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _ShareOption(
              icon: Icons.share_outlined,
              label: AppStrings.sharePost,
              textColor: textColor,
              onTap: () {
                Navigator.pop(context);
                ShareUtils.sharePost(post);
              },
            ),
            _ShareOption(
              icon: Icons.link_rounded,
              label: AppStrings.copyLink,
              textColor: textColor,
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                  ClipboardData(text: ShareUtils.postUrl(post.id)),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.linkCopied),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.screenPadding,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.w, color: textColor),
            Gap(AppDimens.lg),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
