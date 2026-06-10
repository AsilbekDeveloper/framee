import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../data/providers/post_data_providers.dart';
import '../../../../core/components/post_card.dart';
import '../../domain/entities/post.dart';

class SavedPostsScreen extends ConsumerStatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  ConsumerState<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends ConsumerState<SavedPostsScreen> {
  List<Post>? _posts;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppStrings.errorOccurred;
      });
      return;
    }

    final result = await ref.read(getSavedPostsUseCaseProvider).call(
          userId: userId,
        );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      switch (result) {
        case Ok(:final value):
          _posts = value;
        case Err(:final failure):
          _errorMessage = failure.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.saved),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48.w, color: AppColors.error),
            Gap(AppDimens.vmd),
            Text(_errorMessage!),
            Gap(AppDimens.vmd),
            AppButton(
              label: AppStrings.retry,
              onPressed: _load,
              variant: AppButtonVariant.outline,
            ),
          ],
        ),
      );
    }

    final posts = _posts ?? [];

    if (posts.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: AppStrings.saved,
        subtitle: 'Saqlagan postlaringiz bu yerda ko\'rinadi',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, i) => PostCard(
          post: posts[i],
          onLikeTap: null,
          onCommentTap: () =>
              context.push(AppRoutes.postDetailPath(posts[i].id)),
          onSaveTap: () async {
            await ref.read(toggleSaveUseCaseProvider).call(
                  postId: posts[i].id,
                  currentUserId:
                      ref.read(currentUserIdProvider) ?? '',
                );
            await _load();
          },
          onUserTap: () =>
              context.push(AppRoutes.userProfilePath(posts[i].author.id)),
        ),
      ),
    );
  }
}


