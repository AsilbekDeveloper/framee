import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../providers/search_provider.dart';
import '../widgets/explore_grid.dart';
import '../widgets/search_results.dart';

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
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.discover)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.lg,
              AppDimens.vmd,
              AppDimens.lg,
              AppDimens.vsm,
            ),
            child: AppSearchBar(
              controller: _controller,
              focusNode: _focusNode,
              hint: AppStrings.searchUsersPlaceholder,
              onChanged: (val) => notifier.search(val),
              onClear: () {
                _controller.clear();
                notifier.clearSearch();
              },
            ),
          ),
          Expanded(
            child: _buildContent(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
  ) {
    if (state.isQueryActive) {
      if (state.isSearching) {
        return const SearchLoading(key: ValueKey('loading'));
      }
      // A failed request must not look like "no results" — surface it with Retry.
      if (state.errorMessage != null) {
        return EmptyState(
          key: const ValueKey('error'),
          icon: Icons.error_outline_rounded,
          title: AppStrings.errorOccurred,
          action: notifier.retrySearch,
          actionLabel: AppStrings.retry,
        );
      }
      if (state.userResults.isEmpty) {
        return EmptyState(
          key: const ValueKey('empty'),
          icon: Icons.search_off_rounded,
          title: AppStrings.noResults,
          subtitle: AppStrings.noResultsSub,
        );
      }
      return SearchResults(
        key: const ValueKey('results'),
        results: state.userResults,
        onUserTap: (id) => context.push(AppRoutes.userProfilePath(id)),
        onFollowTap: (id) => notifier.toggleFollow(id),
      );
    }

    if (state.isLoadingExplore) {
      return const ExploreShimmer(key: ValueKey('exploreShimmer'));
    }
    return ExploreGrid(
      key: const ValueKey('explore'),
      posts: state.explorePosts,
      // Opens a feed (tapped post + more posts below) with inline comments,
      // rather than a single post detail.
      onPostTap: (id) => context.push(AppRoutes.exploreFeedPath(id)),
      onUserTap: (id) => context.push(AppRoutes.userProfilePath(id)),
      onRefresh: () => notifier.refreshExplore(),
      onLikeTap: (id) => notifier.toggleLike(id),
      onSaveTap: (id) => notifier.toggleSave(id),
    );
  }
}
