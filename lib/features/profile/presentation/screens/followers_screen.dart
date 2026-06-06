import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/models/ui_models.dart';
import '../../../../core/utils/mock_data.dart';

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
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'following' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = MockData.users
        .where((u) =>
            _query.isEmpty ||
            u.username.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(widget.userId),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.followersLabel),
                  Gap(6.w),
                  _CountBadge(count: '200', isActive: _tabController.index == 0),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.followingLabel),
                  Gap(6.w),
                  _CountBadge(count: '150', isActive: _tabController.index == 1),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.lg, AppDimens.vmd, AppDimens.lg, AppDimens.vsm,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hint: AppStrings.searchPlaceholder,
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UserList(users: users),
                _UserList(users: users),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.isActive});
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

class _UserList extends StatefulWidget {
  const _UserList({required this.users});
  final List<UserModel> users;

  @override
  State<_UserList> createState() => _UserListState();
}

class _UserListState extends State<_UserList> {
  late List<UserModel> _users;

  @override
  void initState() {
    super.initState();
    _users = widget.users;
  }

  @override
  void didUpdateWidget(_UserList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.users != widget.users) _users = widget.users;
  }

  @override
  Widget build(BuildContext context) {
    if (_users.isEmpty) {
      return EmptyState(
        icon: Icons.group_outlined,
        title: AppStrings.noResults,
      );
    }
    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (_, __) => const AppDivider(),
      itemBuilder: (context, i) => _FollowerRow(
        user: _users[i],
        onFollowToggle: () {
          setState(() {
            _users = _users.map((u) {
              if (u.id != _users[i].id) return u;
              return u.copyWith(isFollowing: !u.isFollowing);
            }).toList();
          });
        },
      ),
    );
  }
}

class _FollowerRow extends StatelessWidget {
  const _FollowerRow({required this.user, required this.onFollowToggle});

  final UserModel user;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
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
                Text(
                  user.username,
                  style: AppTextStyles.username.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
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
          FollowButton(
            isFollowing: user.isFollowing,
            onTap: onFollowToggle,
          ),
        ],
      ),
    );
  }
}
