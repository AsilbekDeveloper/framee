import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/failures/post_failure.dart';
import '../dtos/comment_dto.dart';

abstract interface class CommentRemoteDataSource {
  Future<Result<List<CommentDto>>> getComments({
    required String postId,
    required String currentUserId,
  });

  Future<Result<CommentDto>> addComment(AddCommentParams params);

  Future<Result<bool>> deleteComment({
    required String commentId,
    required String currentUserId,
  });

  Future<Result<bool>> toggleCommentLike({
    required String commentId,
    required String currentUserId,
  });
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  const CommentRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  static const _commentsTable = 'comments';
  static const _commentLikesTable = 'comment_likes';

  @override
  Future<Result<List<CommentDto>>> getComments({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      AppLogger.d('CommentDS: loading comments — $postId');

      final data = await _client
          .from(_commentsTable)
          .select('''
            id, post_id, user_id, parent_id, text, likes_count, created_at,
            profiles!user_id(username, display_name, avatar_url)
          ''')
          .eq('post_id', postId)
          .order('created_at');

      final likedData = await _client
          .from(_commentLikesTable)
          .select('comment_id')
          .eq('user_id', currentUserId);

      final likedIds = (likedData as List)
          .map((e) => e['comment_id'] as String)
          .toSet();

      final dtos = (data as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        map['is_liked'] = likedIds.contains(map['id']);
        return CommentDto.fromJson(map);
      }).toList();

      return Ok(dtos);
    } on PostgrestException catch (e) {
      AppLogger.e('CommentDS: getComments error', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<CommentDto>> addComment(AddCommentParams params) async {
    try {
      final insertData = <String, dynamic>{
        'post_id': params.postId,
        'user_id': params.userId,
        'text': params.text,
        if (params.parentId != null) 'parent_id': params.parentId,
      };

      final data = await _client
          .from(_commentsTable)
          .insert(insertData)
          .select('''
            id, post_id, user_id, parent_id, text, likes_count, created_at,
            profiles!user_id(username, display_name, avatar_url)
          ''')
          .single();

      final map = Map<String, dynamic>.from(data);
      map['is_liked'] = false;
      AppLogger.d('CommentDS: comment added — ${data['id']}');
      return Ok(CommentDto.fromJson(map));
    } on PostgrestException catch (e) {
      AppLogger.e('CommentDS: addComment error', error: e);
      return Err(CommentFailure(originalError: e));
    } catch (e, st) {
      return Err(CommentFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> deleteComment({
    required String commentId,
    required String currentUserId,
  }) async {
    try {
      await _client
          .from(_commentsTable)
          .delete()
          .eq('id', commentId)
          .eq('user_id', currentUserId);
      return const Ok(true);
    } on PostgrestException catch (e) {
      AppLogger.e('CommentDS: deleteComment error', error: e);
      if (e.code == '42501') return const Err(PostUnauthorizedFailure());
      return Err(PostDeleteFailure(originalError: e));
    } catch (e, st) {
      return Err(PostDeleteFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<bool>> toggleCommentLike({
    required String commentId,
    required String currentUserId,
  }) async {
    try {
      final existing = await _client
          .from(_commentLikesTable)
          .select()
          .eq('comment_id', commentId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from(_commentLikesTable)
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', currentUserId);
        return const Ok(false);
      } else {
        await _client.from(_commentLikesTable).insert({
          'comment_id': commentId,
          'user_id': currentUserId,
        });
        return const Ok(true);
      }
    } on PostgrestException catch (e) {
      AppLogger.e('CommentDS: toggleCommentLike error', error: e);
      return Err(PostInteractionFailure(originalError: e));
    } catch (e) {
      return Err(PostInteractionFailure(originalError: e));
    }
  }
}
