import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn, GoogleSignInException, GoogleSignInExceptionCode;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';

/// Contract for the auth remote data source.
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

/// Supabase-backed implementation of [AuthRemoteDataSource].
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
          UnknownAuthFailure(message: 'Sign-in succeeded but no user was returned.'),
        );
      }
      return Ok(_toEntity(user));
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: signIn error — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: signIn unexpected error', error: e, stackTrace: st);
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
      // user == null means email confirmation is pending.
      return Ok(user == null ? null : _toEntity(user));
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: signUp error — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: signUp unexpected error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return const Err(UnknownAuthFailure(message: 'Google sign-in: no ID token received.'));
      }
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return const Ok(null);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return const Ok(null);
      AppLogger.w('AuthDS: signInWithGoogle error — ${e.code}');
      return Err(NetworkFailure(originalError: e, stackTrace: StackTrace.current));
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: signInWithGoogle error — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: signInWithGoogle unexpected error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Ok(null);
    } catch (e, st) {
      AppLogger.e('AuthDS: signOut error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Ok(null);
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: password reset error — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: password reset unexpected error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return const Ok(null);
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: updatePassword error — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: updatePassword unexpected error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      // Delete via Supabase Edge Function or RPC.
      // Currently: delete the profile row and sign out (cascade removes all data).
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Err(UnknownAuthFailure(message: 'User not found.'));
      }
      // Deleting the profile triggers a cascade that removes all user data.
      await _client.from('profiles').delete().eq('id', userId);
      await _client.auth.signOut();
      return const Ok(null);
    } on AuthException catch (e) {
      AppLogger.w('AuthDS: deleteAccount error — ${e.message}');
      return Err(_mapAuthException(e));
    } catch (e, st) {
      AppLogger.e('AuthDS: deleteAccount unexpected error', error: e, stackTrace: st);
      return Err(NetworkFailure(originalError: e, stackTrace: st));
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Maps a Supabase [User] to the domain [AuthUser] entity.
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

  /// Converts a Supabase [AuthException] to a typed [AuthFailure].
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
