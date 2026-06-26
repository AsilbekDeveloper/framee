import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../follow/domain/entities/follow.dart';
import '../providers/followers_provider.dart';
import '../widgets/followers_list.dart';

class FollowersScreen extends ConsumerStatefulWidget {
  const FollowersScreen({
    super.key,
    required this.userId,
    this.initialTab = 'followers',
  });

  final String userId;
  final String initialTab;

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'following' ? 1 : 0,
    );
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(followersProvider(widget.userId));
    final notifier = ref.read(followersProvider(widget.userId).notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: stateAsync.maybeWhen(
          data: (s) {
            final followersCount = s.followers.length;
            final followingCount = s.following.length;
            return TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.followersLabel),
                      Gap(6.w),
                      CountBadge(
                        count: followersCount.toString(),
                        isActive: _tabController.index == 0,
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.followingLabel),
                      Gap(6.w),
                      CountBadge(
                        count: followingCount.toString(),
                        isActive: _tabController.index == 1,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          orElse: () => TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppStrings.followersLabel),
              Tab(text: AppStrings.followingLabel),
            ],
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48.w, color: AppColors.error),
              Gap(AppDimens.vmd),
              AppButton(
                label: AppStrings.retry,
                onPressed: notifier.refresh,
                variant: AppButtonVariant.outline,
              ),
            ],
          ),
        ),
        data: (state) => Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.lg,
                AppDimens.vmd,
                AppDimens.lg,
                AppDimens.vsm,
              ),
              child: AppSearchBar(
                controller: _searchController,
                hint: AppStrings.searchPlaceholder,
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
                onClear: () => setState(() => _searchQuery = ''),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FollowerUserList(
                    users: _filter(state.followers),
                    onUserTap: (id) =>
                        context.push(AppRoutes.userProfilePath(id)),
                    onFollowToggle: (id) =>
                        notifier.toggleFollow(id, isFollowers: true),
                  ),
                  FollowerUserList(
                    users: _filter(state.following),
                    onUserTap: (id) =>
                        context.push(AppRoutes.userProfilePath(id)),
                    onFollowToggle: (id) =>
                        notifier.toggleFollow(id, isFollowers: false),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  List<FollowUser> _filter(List<FollowUser> users) {
    if (_searchQuery.isEmpty) return users;
    return users
        .where(
          (u) =>
              u.username.toLowerCase().contains(_searchQuery) ||
              u.displayName.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }
}
