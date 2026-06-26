import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/failures/post_failure.dart';
import '../dtos/post_dto.dart';

abstract interface class PostRemoteDataSource {
  Future<Result<List<PostDto>>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  });

  Future<Result<PostDto>> getPost({
    required String postId,
    required String currentUserId,
  });

  Future<Result<PostDto>> createPost(CreatePostParams params);

  Future<Result<bool>> deletePost({
    required String postId,
    required String currentUserId,
  });

  Future<Result<({int likesCount, bool isLiked})>> toggleLike({
    required String postId,
    required String currentUserId,
  });

  Future<Result<bool>> toggleSave({
    required String postId,
    required String currentUserId,
  });

  Future<Result<List<PostDto>>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });

  Future<Result<List<PostDto>>> getSavedPosts({
    required String userId,
    int limit = 30,
    int offset = 0,
  });

  Future<Result<PostDto>> updatePost(UpdatePostParams params);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  const PostRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  static const _postsTable = 'posts';
  static const _likesTable = 'post_likes';
  static const _savedTable = 'saved_posts';
  static const _postImagesBucket = 'post-images';

  // ── Feed ────────────────────────────────────────────────────────────────────

  @override
  Future<Result<List<PostDto>>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      AppLogger.d('PostDS: loading feed — limit:$limit offset:$offset');

      final data = await _client.rpc('get_feed_posts', params: {
        'p_user_id': currentUserId,
        'p_limit': limit,
        'p_offset': offset,
      }) as List<dynamic>;

      final posts = data
          .cast<Map<String, dynamic>>()
          .map(PostDto.fromRpc)
          .toList();

      AppLogger.d('PostDS: ${posts.length} posts loaded');
      return Ok(posts);
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: getFeed DB error', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      AppLogger.e('PostDS: getFeed unexpected error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Get Single Post ─────────────────────────────────────────────────────────

  @override
  Future<Result<PostDto>> getPost({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final data = await _client.rpc('get_post_by_id', params: {
        'p_post_id': postId,
        'p_user_id': currentUserId,
      }) as List<dynamic>;

      if (data.isEmpty) {
        return const Err(PostNotFoundFailure());
      }

      return Ok(PostDto.fromRpc(data.first as Map<String, dynamic>));
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: getPost DB error', error: e);
      if (e.code == 'PGRST116') return const Err(PostNotFoundFailure());
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Create Post ─────────────────────────────────────────────────────────────

  @override
  Future<Result<PostDto>> createPost(CreatePostParams params) async {
    try {
      AppLogger.i('PostDS: creating post — ${params.userId}');

      String? imageUrl;

      if (params.imageLocalPath != null) {
        final uploadResult = await _uploadPostImage(
          userId: params.userId,
          localPath: params.imageLocalPath!,
        );
        switch (uploadResult) {
          case Ok(:final value):
            imageUrl = value;
          case Err(:final failure):
            AppLogger.e('PostDS: image upload failed', error: failure);
            return Err(failure);
        }
      }

      final insertData = <String, dynamic>{
        'user_id': params.userId,
        'image_url': ?imageUrl,
        if (params.caption != null && params.caption!.trim().isNotEmpty)
          'caption': params.caption!.trim(),
      };

      final data = await _client
          .from(_postsTable)
          .insert(insertData)
          .select('''
            id, user_id, image_url, caption,
            likes_count, comments_count, created_at,
            profiles!user_id(id, username, display_name, avatar_url, is_verified)
          ''')
          .single();

      AppLogger.i('PostDS: post created — ${data['id']}');
      return Ok(PostDto.fromJoin(data));
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: createPost DB error', error: e);
      return Err(PostCreateFailure(originalError: e));
    } catch (e, st) {
      AppLogger.e('PostDS: createPost unexpected error', error: e, stackTrace: st);
      return Err(PostCreateFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Delete Post ─────────────────────────────────────────────────────────────

  @override
  Future<Result<bool>> deletePost({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      await _client
          .from(_postsTable)
          .delete()
          .eq('id', postId)
          .eq('user_id', currentUserId);

      AppLogger.i('PostDS: post deleted — $postId');
      return const Ok(true);
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: deletePost error', error: e);
      if (e.code == '42501') return const Err(PostUnauthorizedFailure());
      return Err(PostDeleteFailure(originalError: e));
    } catch (e, st) {
      return Err(PostDeleteFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Like ────────────────────────────────────────────────────────────────────

  @override
  Future<Result<({int likesCount, bool isLiked})>> toggleLike({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final existing = await _client
          .from(_likesTable)
          .select()
          .eq('post_id', postId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from(_likesTable)
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUserId);
      } else {
        await _client.from(_likesTable).insert({
          'post_id': postId,
          'user_id': currentUserId,
        });
      }

      final postData = await _client
          .from(_postsTable)
          .select('likes_count')
          .eq('id', postId)
          .single();

      final likesCount = postData['likes_count'] as int? ?? 0;
      final isLiked = existing == null;

      return Ok((likesCount: likesCount, isLiked: isLiked));
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: toggleLike error', error: e);
      return Err(PostInteractionFailure(originalError: e));
    } catch (e) {
      return Err(PostInteractionFailure(originalError: e));
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  @override
  Future<Result<bool>> toggleSave({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final existing = await _client
          .from(_savedTable)
          .select()
          .eq('post_id', postId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from(_savedTable)
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUserId);
        return const Ok(false);
      } else {
        await _client.from(_savedTable).insert({
          'post_id': postId,
          'user_id': currentUserId,
        });
        return const Ok(true);
      }
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: toggleSave error', error: e);
      return Err(PostInteractionFailure(originalError: e));
    } catch (e) {
      return Err(PostInteractionFailure(originalError: e));
    }
  }

  // ── User Posts ───────────────────────────────────────────────────────────────

  @override
  Future<Result<List<PostDto>>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      AppLogger.d('PostDS: loading user posts — $userId');
      final data = await _client
          .from(_postsTable)
          .select('''
            id, user_id, image_url, caption,
            likes_count, comments_count, created_at,
            profiles!user_id(id, username, display_name, avatar_url, is_verified)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final postIds = (data as List).map((e) => e['id'] as String).toList();
      final likedIds = await _getLikedPostIds(currentUserId, postIds);
      final savedIds = await _getSavedPostIds(currentUserId, postIds);

      final dtos = data.map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        map['is_liked'] = likedIds.contains(map['id']);
        map['is_saved'] = savedIds.contains(map['id']);
        return PostDto.fromJoin(map);
      }).toList();

      return Ok(dtos);
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: getUserPosts error', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<List<PostDto>>> getSavedPosts({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      AppLogger.d('PostDS: loading saved posts — $userId');
      final data = await _client
          .from(_savedTable)
          .select('''
            post_id,
            posts!post_id(
              id, user_id, image_url, caption,
              likes_count, comments_count, created_at,
              profiles!user_id(id, username, display_name, avatar_url, is_verified)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final dtos = (data as List).map((row) {
        final postMap = Map<String, dynamic>.from(row['posts'] as Map);
        postMap['is_liked'] = false;
        postMap['is_saved'] = true;
        return PostDto.fromJoin(postMap);
      }).toList();

      return Ok(dtos);
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: getSavedPosts error', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Update Post ─────────────────────────────────────────────────────────────

  @override
  Future<Result<PostDto>> updatePost(UpdatePostParams params) async {
    try {
      AppLogger.i('PostDS: updating post — ${params.postId}');

      final updates = <String, dynamic>{};

      if (params.removeImage) {
        updates['image_url'] = null;
      } else if (params.newImageLocalPath != null) {
        final uploadResult = await _uploadPostImage(
          userId: params.userId,
          localPath: params.newImageLocalPath!,
        );
        switch (uploadResult) {
          case Ok(:final value):
            updates['image_url'] = value;
          case Err(:final failure):
            return Err(failure);
        }
      }

      updates['caption'] = params.caption?.trim().isEmpty == true
          ? null
          : params.caption?.trim();

      final data = await _client
          .from(_postsTable)
          .update(updates)
          .eq('id', params.postId)
          .eq('user_id', params.userId)
          .select('''
            id, user_id, image_url, caption,
            likes_count, comments_count, created_at,
            profiles!user_id(id, username, display_name, avatar_url, is_verified)
          ''')
          .single();

      AppLogger.i('PostDS: post updated — ${params.postId}');
      return Ok(PostDto.fromJoin(data));
    } on PostgrestException catch (e) {
      AppLogger.e('PostDS: updatePost DB error', error: e);
      return Err(ServerFailure(message: e.message, originalError: e));
    } catch (e, st) {
      AppLogger.e('PostDS: updatePost unexpected error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<Set<String>> _getLikedPostIds(
      String userId, List<String> postIds) async {
    if (postIds.isEmpty) return {};
    try {
      final data = await _client
          .from(_likesTable)
          .select('post_id')
          .eq('user_id', userId)
          .inFilter('post_id', postIds);
      return (data as List).map((e) => e['post_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<Set<String>> _getSavedPostIds(
      String userId, List<String> postIds) async {
    if (postIds.isEmpty) return {};
    try {
      final data = await _client
          .from(_savedTable)
          .select('post_id')
          .eq('user_id', userId)
          .inFilter('post_id', postIds);
      return (data as List).map((e) => e['post_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<Result<String>> _uploadPostImage({
    required String userId,
    required String localPath,
  }) async {
    try {
      final bytes = await File(localPath).readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$userId/$timestamp.jpg';

      await _client.storage.from(_postImagesBucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      final url = _client.storage
          .from(_postImagesBucket)
          .getPublicUrl(storagePath);

      AppLogger.i('PostDS: image uploaded — $url');
      return Ok(url);
    } catch (e, st) {
      AppLogger.e('PostDS: image upload error', error: e, stackTrace: st);
      return Err(PostImageUploadFailure(originalError: e, stackTrace: st));
    }
  }
}
