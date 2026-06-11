import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/profile.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
    required this.profile,
    required this.isOwnProfile,
    required this.onFollowersTap,
    required this.onFollowingTap,
    required this.onEditTap,
    required this.onShareTap,
    required this.onFollowTap,
  });

  final Profile profile;
  final bool isOwnProfile;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;
  final VoidCallback onEditTap;
  final VoidCallback onShareTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.xl,
        AppDimens.vxl,
        AppDimens.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                imageUrl: profile.avatarUrl,
                initials: profile.initials,
                size: AvatarSize.xl,
                hasStoryRing: true,
              ),
              Gap(AppDimens.lg),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ProfileStatColumn(
                      value: profile.postsCount.compact,
                      label: AppStrings.posts,
                      onTap: null,
                    ),
                    ProfileStatColumn(
                      value: profile.followersCount.compact,
                      label: AppStrings.followersLabel,
                      onTap: onFollowersTap,
                    ),
                    ProfileStatColumn(
                      value: profile.followingCount.compact,
                      label: AppStrings.followingLabel,
                      onTap: onFollowingTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(AppDimens.vmd),
          Text(
            profile.displayName,
            style: AppTextStyles.h4.copyWith(color: textColor),
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Gap(4.h),
            Text(
              profile.bio!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (profile.website != null && profile.website!.isNotEmpty) ...[
            Gap(5.h),
            Row(
              children: [
                Icon(Icons.link_rounded, size: 14.w, color: AppColors.primary),
                Gap(4.w),
                Text(
                  profile.website!,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
          Gap(AppDimens.vmd),
          if (isOwnProfile)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppDimens.buttonHeightSm,
                    child: OutlinedButton(
                      onPressed: onEditTap,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AppStrings.editProfile),
                      ),
                    ),
                  ),
                ),
                Gap(AppDimens.sm),
                Expanded(
                  child: SizedBox(
                    height: AppDimens.buttonHeightSm,
                    child: OutlinedButton(
                      onPressed: onShareTap,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AppStrings.shareProfile),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FollowButton(
                    isFollowing: profile.isFollowing,
                    onTap: onFollowTap,
                  ),
                ),
                Gap(AppDimens.sm),
                Expanded(
                  child: SizedBox(
                    height: AppDimens.buttonHeightSm,
                    child: OutlinedButton(
                      onPressed: onShareTap,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AppStrings.shareProfile),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Gap(AppDimens.vmd),
        ],
      ),
    );
  }
}

class ProfileStatColumn extends StatelessWidget {
  const ProfileStatColumn({
    super.key,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.statNumber.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          Gap(2.h),
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(
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
