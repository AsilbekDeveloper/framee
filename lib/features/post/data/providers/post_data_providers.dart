import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/delete_post_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/get_saved_posts_usecase.dart';
import '../../domain/usecases/get_user_posts_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import '../../domain/usecases/toggle_save_usecase.dart';
import '../datasources/post_remote_datasource.dart';
import '../repositories/post_repository_impl.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────────

final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
  name: 'postSupabaseClient',
);

final _postRemoteDataSourceProvider = Provider<PostRemoteDataSource>(
  (ref) => PostRemoteDataSourceImpl(ref.read(_supabaseClientProvider)),
);

// ── Repository ─────────────────────────────────────────────────────────────────

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepositoryImpl(ref.read(_postRemoteDataSourceProvider)),
);

// ── Use Cases ──────────────────────────────────────────────────────────────────

final getFeedUseCaseProvider = Provider<GetFeedUseCase>(
  (ref) => GetFeedUseCase(ref.read(postRepositoryProvider)),
);

final createPostUseCaseProvider = Provider<CreatePostUseCase>(
  (ref) => CreatePostUseCase(ref.read(postRepositoryProvider)),
);

final getPostUseCaseProvider = Provider<GetPostUseCase>(
  (ref) => GetPostUseCase(ref.read(postRepositoryProvider)),
);

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>(
  (ref) => ToggleLikeUseCase(ref.read(postRepositoryProvider)),
);

final toggleSaveUseCaseProvider = Provider<ToggleSaveUseCase>(
  (ref) => ToggleSaveUseCase(ref.read(postRepositoryProvider)),
);

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>(
  (ref) => GetCommentsUseCase(ref.read(postRepositoryProvider)),
);

final addCommentUseCaseProvider = Provider<AddCommentUseCase>(
  (ref) => AddCommentUseCase(ref.read(postRepositoryProvider)),
);

final deletePostUseCaseProvider = Provider<DeletePostUseCase>(
  (ref) => DeletePostUseCase(ref.read(postRepositoryProvider)),
);

final getUserPostsUseCaseProvider = Provider<GetUserPostsUseCase>(
  (ref) => GetUserPostsUseCase(ref.read(postRepositoryProvider)),
);

final getSavedPostsUseCaseProvider = Provider<GetSavedPostsUseCase>(
  (ref) => GetSavedPostsUseCase(ref.read(postRepositoryProvider)),
);
