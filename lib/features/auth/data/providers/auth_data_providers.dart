import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../datasources/auth_remote_datasource.dart';
import '../repositories/auth_repository_impl.dart';

final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final _authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.read(_supabaseClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(_authRemoteDataSourceProvider)),
);

final updatePasswordUseCaseProvider = Provider<UpdatePasswordUseCase>(
  (ref) => UpdatePasswordUseCase(ref.read(authRepositoryProvider)),
);

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>(
  (ref) => DeleteAccountUseCase(ref.read(authRepositoryProvider)),
);

/// Auth holati oqimi — repository orqali, Supabase'ga to'g'ridan-to'g'ri
/// murojaat qilinmaydi. Router va [AuthNotifier] shu provider'dan foydalanadi.
final authUserStreamProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);
