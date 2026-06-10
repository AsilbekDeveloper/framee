import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';

abstract interface class AuthRemoteDataSource {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;

  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AuthUser?>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<void>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<void>> sendPasswordResetEmail(String email);
  Future<Result<void>> updatePassword(String newPassword);
  Future<Result<void>> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _toEntity(user);
  }

  @override
  Stream<AuthUser?> get authStateChanges =>
      _client.auth.onAuthStateChange.map(
        (event) => event.session?.user == null
            ? null
            : _toEntity(event.session!.user),
      );

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        return const Err(
          UnknownAuthFailure(message: 'Kirish muvaffaqiyatli, lekin user qaytmadi.'),
        );
      }
      return Ok(_toEntity(user));
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: signIn xatosi — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: signIn kutilmagan xato', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<AuthUser?>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      final user = res.user;
      // user == null → email tasdiqlash kutilmoqda
      return Ok(user == null ? null : _toEntity(user));
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: signUp xatosi — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: signUp kutilmagan xato', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(OAuthProvider.google);
      return const Ok(null);
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: Google sign-in xatosi — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: Google sign-in kutilmagan xato', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Ok(null);
    } catch (e, st) {
      AppLogger.e('AuthDS: signOut xatosi', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Ok(null);
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: password reset xatosi — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: password reset kutilmagan xato', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return const Ok(null);
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: updatePassword xatosi — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: updatePassword kutilmagan xato', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      // Supabase Edge Function yoki RPC orqali o'chirish
      // Hozircha: foydalanuvchi ma'lumotlarini o'chirish + sign out
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Err(UnknownAuthFailure(message: 'Foydalanuvchi topilmadi'));
      }
      // Profilni o'chirish (cascade orqali barcha ma'lumotlar o'chadi)
      await _client.from('profiles').delete().eq('id', userId);
      await _client.auth.signOut();
      return const Ok(null);
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: deleteAccount xatosi — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: deleteAccount kutilmagan xato', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  AuthUser _toEntity(User user) {
    final meta = user.userMetadata ?? {};
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      fullName: meta['full_name'] as String?,
      username: meta['username'] as String?,
      avatarUrl: meta['avatar_url'] as String?,
    );
  }

  AuthFailure _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return const InvalidCredentialsFailure();
    }
    if (msg.contains('email not confirmed')) {
      return const EmailNotConfirmedFailure();
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return const EmailAlreadyInUseFailure();
    }
    if (msg.contains('password should be at least')) {
      return const WeakPasswordFailure();
    }
    if (msg.contains('user not found')) {
      return const UserNotFoundFailure();
    }
    if (msg.contains('session') && msg.contains('expir')) {
      return const SessionExpiredFailure();
    }
    return UnknownAuthFailure(message: e.message, originalError: e);
  }
}
