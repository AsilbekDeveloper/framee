import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/follow_repository.dart';
import '../../domain/usecases/follow_user_usecase.dart';
import '../../domain/usecases/get_followers_usecase.dart';
import '../../domain/usecases/get_following_usecase.dart';
import '../../domain/usecases/unfollow_user_usecase.dart';
import '../datasources/follow_remote_datasource.dart';
import '../repositories/follow_repository_impl.dart';

final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
  name: 'followSupabaseClient',
);

final _followRemoteDataSourceProvider = Provider<FollowRemoteDataSource>(
  (ref) => FollowRemoteDataSourceImpl(ref.read(_supabaseClientProvider)),
);

final followRepositoryProvider = Provider<FollowRepository>(
  (ref) => FollowRepositoryImpl(ref.read(_followRemoteDataSourceProvider)),
);

final followUserUseCaseProvider = Provider<FollowUserUseCase>(
  (ref) => FollowUserUseCase(ref.read(followRepositoryProvider)),
);

final unfollowUserUseCaseProvider = Provider<UnfollowUserUseCase>(
  (ref) => UnfollowUserUseCase(ref.read(followRepositoryProvider)),
);

final getFollowersUseCaseProvider = Provider<GetFollowersUseCase>(
  (ref) => GetFollowersUseCase(ref.read(followRepositoryProvider)),
);

final getFollowingUseCaseProvider = Provider<GetFollowingUseCase>(
  (ref) => GetFollowingUseCase(ref.read(followRepositoryProvider)),
);
