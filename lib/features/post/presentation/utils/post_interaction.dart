import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../data/providers/post_data_providers.dart';
import '../../domain/entities/post.dart';

/// Shared optimistic-update logic for like/save actions used by all
/// list-based feed providers. Each notifier supplies its own [patchPost]
/// so its state layout stays self-contained.
Future<void> performToggleLike({
  required Ref ref,
  required String postId,
  required String currentUserId,
  required Post original,
  required void Function(Post Function(Post)) patchPost,
}) async {
  patchPost(
    (p) => p.copyWith(
      isLiked: !p.isLiked,
      likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
    ),
  );

  final result = await ref.read(toggleLikeUseCaseProvider).call(
        postId: postId,
        currentUserId: currentUserId,
      );

  switch (result) {
    case Ok(:final value):
      patchPost((p) => p.copyWith(
            isLiked: value.isLiked,
            likesCount: value.likesCount,
          ));
    case Err(:final failure):
      AppLogger.w('toggleLike rollback — ${failure.code}');
      patchPost((p) => p.copyWith(
            isLiked: original.isLiked,
            likesCount: original.likesCount,
          ));
  }
}

Future<void> performToggleSave({
  required Ref ref,
  required String postId,
  required String currentUserId,
  required Post original,
  required void Function(Post Function(Post)) patchPost,
}) async {
  patchPost((p) => p.copyWith(isSaved: !p.isSaved));

  final result = await ref.read(toggleSaveUseCaseProvider).call(
        postId: postId,
        currentUserId: currentUserId,
      );

  if (result is Err) {
    AppLogger.w('toggleSave rollback');
    patchPost((p) => p.copyWith(isSaved: original.isSaved));
  }
}
