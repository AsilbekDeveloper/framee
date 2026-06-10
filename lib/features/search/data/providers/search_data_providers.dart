import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/get_explore_posts_usecase.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../datasources/search_remote_datasource.dart';
import '../repositories/search_repository_impl.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────────

final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
  name: 'searchSupabaseClient',
);

final _searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>(
  (ref) => SearchRemoteDataSourceImpl(ref.read(_supabaseClientProvider)),
);

// ── Repository ─────────────────────────────────────────────────────────────────

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(ref.read(_searchRemoteDataSourceProvider)),
);

// ── Use Cases ──────────────────────────────────────────────────────────────────

final searchUsersUseCaseProvider = Provider<SearchUsersUseCase>(
  (ref) => SearchUsersUseCase(ref.read(searchRepositoryProvider)),
);

final getExplorePostsUseCaseProvider = Provider<GetExplorePostsUseCase>(
  (ref) => GetExplorePostsUseCase(ref.read(searchRepositoryProvider)),
);
