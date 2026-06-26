import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/share_utils.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/router/app_router.dart';
import '../providers/profile_provider.dart';
import '../providers/user_posts_provider.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_tabs.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isOwnProfile = userId == null || userId == currentUserId;

    final profileAsync = ref.watch(profileProvider(userId));
    final tabIndex = ref.watch(profileTabIndexProvider(userId));

    return profileAsync.when(
      loading: () => const Scaffold(
        body: SingleChildScrollView(child: ProfileShimmer()),
      ),
      error: (err, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const Gap(12),
              Text(AppStrings.errorOccurred, style: AppTextStyles.bodyMedium),
              const Gap(8),
              AppButton(
                label: AppStrings.retry,
                onPressed: () =>
                    ref.read(profileProvider(userId).notifier).refresh(),
              ),
            ],
          ),
        ),
      ),
      data: (profile) => Scaffold(
        appBar: ProfileAppBar(
          username: profile.username,
          isOwnProfile: isOwnProfile,
          onSettingsTap: () => context.push(AppRoutes.settings),
          onCreateTap: () => context.push(AppRoutes.createPost),
          onBackTap: isOwnProfile ? null : () => context.pop(),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => Future.wait([
                ref.read(profileProvider(userId).notifier).refresh(),
                ref.read(userPostsProvider(profile.id).notifier).refresh(),
              ]),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ProfileInfo(
                  profile: profile,
                  isOwnProfile: isOwnProfile,
                  onFollowersTap: () => context.push(
                    '${AppRoutes.followersPath(profile.id)}?tab=followers',
                  ),
                  onFollowingTap: () => context.push(
                    '${AppRoutes.followersPath(profile.id)}?tab=following',
                  ),
                  onEditTap: () => context.push(AppRoutes.editProfile),
                  onShareTap: () => ShareUtils.shareProfile(
                    userId: profile.id,
                    username: profile.username,
                  ),
                  onCopyLinkTap: () {
                    Clipboard.setData(
                      ClipboardData(
                          text: ShareUtils.profileUrl(profile.id)),
                    );
                    context.showSnackBar(AppStrings.linkCopied);
                  },
                  onFollowTap: () =>
                      ref.read(profileProvider(userId).notifier).toggleFollow(),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: ProfileTabDelegate(
                  selectedIndex: tabIndex,
                  onTabChanged: (i) =>
                      ref.read(profileTabIndexProvider(userId).notifier).state =
                          i,
                ),
              ),
              if (tabIndex == 0)
                ProfileImagePostsTab(
                  userId: profile.id,
                  onPostTap: (postId) => context.push(
                    AppRoutes.profilePostsFeedPath(profile.id, postId),
                  ),
                )
              else
                ProfileTextPostsTab(
                  userId: profile.id,
                  onPostTap: (postId) =>
                      context.push(AppRoutes.postDetailPath(postId)),
                  onUserTap: (uid) =>
                      context.push(AppRoutes.userProfilePath(uid)),
                ),
              SliverToBoxAdapter(child: SizedBox(height: AppDimens.vhuge)),
            ],
          ),
        ),
      ),
    );
  }
}
