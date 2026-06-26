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
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/search_result.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({
    super.key,
    required this.results,
    required this.onUserTap,
    required this.onFollowTap,
  });

  final List<SearchUser> results;
  final ValueChanged<String> onUserTap;
  final ValueChanged<String> onFollowTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SectionLabel('${AppStrings.people} · ${results.length}'),
        ),
        SliverList.separated(
          itemCount: results.length,
          separatorBuilder: (_, _) => const AppDivider(),
          itemBuilder: (context, i) => SearchUserRow(
            user: results[i],
            onTap: () => onUserTap(results[i].id),
            onFollowTap: () => onFollowTap(results[i].id),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppDimens.vlg)),
      ],
    );
  }
}

class SearchUserRow extends StatelessWidget {
  const SearchUserRow({
    super.key,
    required this.user,
    required this.onTap,
    required this.onFollowTap,
  });

  final SearchUser user;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

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
                      if (user.isPrivate) ...[
                        Gap(4.w),
                        Icon(
                          Icons.lock_rounded,
                          size: 12.w,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ],
                    ],
                  ),
                  Gap(2.h),
                  Text(
                    '@${user.username} · ${user.followersCount.compact} ${AppStrings.followers}',
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
              onTap: onFollowTap,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchLoading extends StatelessWidget {
  const SearchLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, _) => const UserRowShimmer(),
    );
  }
}
