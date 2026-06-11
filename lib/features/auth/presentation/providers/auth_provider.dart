import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/errors/result.dart';
import '../../data/providers/auth_data_providers.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

// ── Use case providers ────────────────────────────────────────────────────────

final _signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.read(authRepositoryProvider)),
);
final _signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.read(authRepositoryProvider)),
);
final _signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.read(authRepositoryProvider)),
);
final _signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>(
  (ref) => SignInWithGoogleUseCase(ref.read(authRepositoryProvider)),
);
final _sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>(
  (ref) => SendPasswordResetUseCase(ref.read(authRepositoryProvider)),
);

// ── Auth State ────────────────────────────────────────────────────────────────

/// Immutable state for the authentication notifier.
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.awaitingEmailConfirmation = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final AuthUser? user;

  /// `true` when Supabase sent a confirmation email and sign-in is pending.
  final bool awaitingEmailConfirmation;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthUser? user,
    bool? awaitingEmailConfirmation,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        user: clearUser ? null : (user ?? this.user),
        awaitingEmailConfirmation:
            awaitingEmailConfirmation ?? this.awaitingEmailConfirmation,
      );
}

// ── Auth Notifier ─────────────────────────────────────────────────────────────

/// Drives all authentication flows and keeps [AuthState] consistent.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Listen to the auth stream for OAuth callbacks, token refreshes,
    // and sign-outs triggered from other tabs/devices.
    ref.listen<AsyncValue<AuthUser?>>(authUserStreamProvider, (_, next) {
      final incoming = next.valueOrNull;
      if (incoming?.id != state.user?.id) {
        AppLogger.i(
          incoming == null
              ? 'Auth: user signed out'
              : 'Auth: stream updated — ${incoming.email}',
        );
        state = state.copyWith(
          user: incoming,
          clearUser: incoming == null,
          clearError: true,
          isLoading: false,
          awaitingEmailConfirmation: false,
        );
      }
    });

    final current = ref.read(authRepositoryProvider).currentUser;
    AppLogger.d('Auth: initialized — ${current?.email ?? "guest"}');
    return AuthState(user: current);
  }

  /// Signs in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    AppLogger.i('Auth: sign in — $email');
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref
        .read(_signInUseCaseProvider)
        .call(email: email, password: password);

    switch (result) {
      case Ok(:final value):
        AppLogger.i('Auth: signed in — ${value.email}');
        state = state.copyWith(isLoading: false, user: value);
      case Err(:final failure):
        AppLogger.w('Auth: sign-in error — ${failure.code}');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  /// Registers a new account with email and password.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    AppLogger.i('Auth: sign up — $email');
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(_signUpUseCaseProvider).call(
          fullName: fullName,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
        );

    switch (result) {
      case Ok(:final value) when value == null:
        // Supabase requires email confirmation before the session is created.
        AppLogger.i('Auth: awaiting email confirmation — $email');
        state = state.copyWith(
          isLoading: false,
          awaitingEmailConfirmation: true,
        );
      case Ok(:final value):
        AppLogger.i('Auth: signed up — ${value!.email}');
        state = state.copyWith(isLoading: false, user: value);
      case Err(:final failure):
        AppLogger.w('Auth: sign-up error — ${failure.code}');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  /// Initiates Google OAuth sign-in. The result arrives via the auth stream.
  Future<void> signInWithGoogle() async {
    AppLogger.i('Auth: Google sign-in');
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(_signInWithGoogleUseCaseProvider).call();
    // On success, the auth stream delivers the new user — only handle errors here.
    if (result case Err(:final failure)) {
      AppLogger.w('Auth: Google sign-in error — ${failure.code}');
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  /// Sends a password-reset email to the given address.
  Future<void> sendPasswordReset(String email) async {
    AppLogger.i('Auth: password reset — $email');
    state = state.copyWith(isLoading: true, clearError: true);

    final result =
        await ref.read(_sendPasswordResetUseCaseProvider).call(email);

    switch (result) {
      case Ok():
        AppLogger.i('Auth: password reset email sent');
        state = state.copyWith(isLoading: false);
      case Err(:final failure):
        AppLogger.w('Auth: password reset error — ${failure.code}');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  /// Signs out the current user.
  /// Clears local state even if the network request fails.
  Future<void> signOut() async {
    AppLogger.i('Auth: sign out');
    final result = await ref.read(_signOutUseCaseProvider).call();
    if (result case Err(:final failure)) {
      AppLogger.e('Auth: sign-out error — ${failure.code}');
    }
    // Always reset local state regardless of the result.
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
