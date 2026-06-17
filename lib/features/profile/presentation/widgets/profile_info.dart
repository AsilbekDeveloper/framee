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
    required this.onCopyLinkTap,
    required this.onFollowTap,
  });

  final Profile profile;
  final bool isOwnProfile;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;
  final VoidCallback onEditTap;
  final VoidCallback onShareTap;
  final VoidCallback onCopyLinkTap;
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
                      onPressed: () => _showProfileShareSheet(context),
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
                    // A pending request uses the same "outlined" style as Following.
                    isFollowing: profile.isFollowing || profile.isRequested,
                    isFollowBack: profile.isFollowingMe &&
                        !profile.isFollowing &&
                        !profile.isRequested,
                    label: profile.isRequested ? AppStrings.requested : null,
                    onTap: onFollowTap,
                  ),
                ),
                Gap(AppDimens.sm),
                Expanded(
                  child: SizedBox(
                    height: AppDimens.buttonHeightSm,
                    child: OutlinedButton(
                      onPressed: () => _showProfileShareSheet(context),
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

  void _showProfileShareSheet(BuildContext context) {
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
              _ProfileShareOption(
                icon: Icons.share_outlined,
                label: AppStrings.shareProfile,
                textColor: textColor,
                onTap: () {
                  Navigator.pop(context);
                  onShareTap();
                },
              ),
              _ProfileShareOption(
                icon: Icons.link_rounded,
                label: AppStrings.copyLink,
                textColor: textColor,
                onTap: () {
                  Navigator.pop(context);
                  onCopyLinkTap();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileShareOption extends StatelessWidget {
  const _ProfileShareOption({
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
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
          ],
        ),
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
