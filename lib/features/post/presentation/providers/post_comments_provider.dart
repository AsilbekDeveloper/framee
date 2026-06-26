import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../data/providers/post_data_providers.dart';
import '../../domain/entities/post.dart';

/// Loads all comments for a post (top-level + nested replies), keyed by postId.
///
/// Used by read-only inline comment previews (e.g. the explore feed), where the
/// full comment thread is fetched once and the UI slices it locally for the
/// "more / less" expander. The full interactive thread lives in PostDetail.
final postCommentsProvider =
    FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return const [];

  final result = await ref.read(getCommentsUseCaseProvider).call(
        postId: postId,
        currentUserId: userId,
      );

  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});
