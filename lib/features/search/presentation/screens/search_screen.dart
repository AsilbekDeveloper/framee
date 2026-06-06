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
import '../../../../core/router/app_router.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.discover)),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.lg, AppDimens.vmd, AppDimens.lg, AppDimens.vsm,
            ),
            child: AppSearchBar(
              controller: _controller,
              focusNode: _focusNode,
              hint: AppStrings.searchUsersPlaceholder,
              onChanged: (val) =>
                  ref.read(searchProvider.notifier).search(val),
              onClear: () =>
                  ref.read(searchProvider.notifier).clearSearch(),
            ),
          ),

          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: state.query.isEmpty
                  ? _ExploreGrid(key: const ValueKey('explore'))
                  : state.isLoading
                      ? _SearchLoading(key: const ValueKey('loading'))
                      : state.results.isEmpty
                          ? EmptyState(
                              key: const ValueKey('empty'),
                              icon: Icons.search_off_rounded,
                              title: AppStrings.noResults,
                              subtitle: AppStrings.noResultsSub,
                            )
                          : _SearchResults(
                              key: const ValueKey('results'),
                              results: state.results,
                              onUserTap: (userId) => context
                                  .push(AppRoutes.userProfilePath(userId)),
                              onFollowTap: (userId) => ref
                                  .read(searchProvider.notifier)
                                  .toggleFollow(userId),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Explore Grid ─────────────────────────────────────────────────────────────
class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid({super.key});

  static const List<Color> _gradients = [
    Color(0xFF667eea),
    Color(0xFFf093fb),
    Color(0xFF4facfe),
    Color(0xFFd4fc79),
    Color(0xFFffecd2),
    Color(0xFFf7971e),
    Color(0xFF11998e),
    Color(0xFFee9ca7),
    Color(0xFFa18cd1),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SectionLabel(AppStrings.explore),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(2),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: _gradients.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _gradients[i],
                      _gradients[(_gradients.length - 1 - i) %
                          _gradients.length],
                    ],
                  ),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 28.w,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Search Results ───────────────────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  const _SearchResults({
    super.key,
    required this.results,
    required this.onUserTap,
    required this.onFollowTap,
  });

  final List<UserModel> results;
  final ValueChanged<String> onUserTap;
  final ValueChanged<String> onFollowTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SectionLabel(AppStrings.people),
        ),
        SliverList.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const AppDivider(),
          itemBuilder: (context, i) => _UserRow(
            user: results[i],
            onTap: () => onUserTap(results[i].id),
            onFollowTap: () => onFollowTap(results[i].id),
          ),
        ),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.onTap,
    required this.onFollowTap,
  });

  final UserModel user;
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
              onTap: onFollowTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchLoading extends StatelessWidget {
  const _SearchLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => const UserRowShimmer(),
    );
  }
}
