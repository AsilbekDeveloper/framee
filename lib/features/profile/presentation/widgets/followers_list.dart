import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../../core/components/app_avatar.dart';
import '../../../../../core/components/follow_button.dart';
import '../../../../../core/components/shared_widgets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../follow/domain/entities/follow.dart';

class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, required this.isActive});
  final String count;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryMuted
            : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        count,
        style: AppTextStyles.overlineBold.copyWith(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        ),
      ),
    );
  }
}

class FollowerUserList extends StatelessWidget {
  const FollowerUserList({
    super.key,
    required this.users,
    required this.onUserTap,
    required this.onFollowToggle,
  });

  final List<FollowUser> users;
  final ValueChanged<String> onUserTap;
  final ValueChanged<String> onFollowToggle;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return EmptyState(
        icon: Icons.group_outlined,
        title: AppStrings.noResults,
      );
    }
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => const AppDivider(),
      itemBuilder: (context, i) => FollowerRow(
        user: users[i],
        onTap: () => onUserTap(users[i].id),
        onFollowToggle: () => onFollowToggle(users[i].id),
      ),
    );
  }
}

class FollowerRow extends StatelessWidget {
  const FollowerRow({
    super.key,
    required this.user,
    required this.onTap,
    required this.onFollowToggle,
  });

  final FollowUser user;
  final VoidCallback onTap;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: user.avatarUrl,
              initials: user.initials,
              size: AvatarSize.md,
            ),
            Gap(AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: AppTextStyles.username.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        Gap(4.w),
                        Icon(Icons.verified_rounded,
                            size: 14.w, color: AppColors.primary),
                      ],
                    ],
                  ),
                  Gap(2.h),
                  Text(
                    '@${user.username}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Gap(AppDimens.sm),
            FollowButton(
              isFollowing: user.isFollowing || user.isRequested,
              label: user.isRequested ? AppStrings.requested : null,
              onTap: onFollowToggle,
            ),
          ],
        ),
      ),
    );
  }
}
