import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/services/post_cache_service.dart';
import '../../../../core/errors/failure_message.dart';
import '../../../../core/errors/result.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/providers/user_posts_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../profile/data/providers/profile_data_providers.dart';
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
final _sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>(
  (ref) => SendPasswordResetUseCase(ref.read(authRepositoryProvider)),
);
final _signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>(
  (ref) => SignInWithGoogleUseCase(ref.read(authRepositoryProvider)),
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

  /// Launches Google OAuth flow in the browser.
  Future<void> signInWithGoogle() async {
    AppLogger.i('Auth: sign in with Google');
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(_signInWithGoogleUseCaseProvider).call();

    switch (result) {
      case Ok():
        final user = ref.read(authRepositoryProvider).currentUser;
        state = state.copyWith(isLoading: false, user: user);
        FcmService.instance.saveTokenAfterLogin();
        ref.read(localeProvider.notifier).syncAfterLogin();
      case Err(:final failure):
        AppLogger.w('Auth: Google sign-in error — ${failure.code}');
        state = state.copyWith(
            isLoading: false, errorMessage: localizedFailure(failure));
    }
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
        FcmService.instance.saveTokenAfterLogin();
        ref.read(localeProvider.notifier).syncAfterLogin();
      case Err(:final failure):
        AppLogger.w('Auth: sign-in error — ${failure.code}');
        state = state.copyWith(
            isLoading: false, errorMessage: localizedFailure(failure));
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
        state = state.copyWith(
            isLoading: false, errorMessage: localizedFailure(failure));
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
        state = state.copyWith(
            isLoading: false, errorMessage: localizedFailure(failure));
    }
  }

  /// Clears any pending error message. Call when leaving a screen so a login
  /// error never lingers onto the sign-up screen (they share this notifier).
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Signs out the current user.
  /// Clears local state even if the network request fails.
  Future<void> signOut() async {
    AppLogger.i('Auth: sign out');
    // Clear FCM token BEFORE signing out so we still have userId
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref.read(profileRepositoryProvider).clearFcmToken(userId);
    }
    final result = await ref.read(_signOutUseCaseProvider).call();
    if (result case Err(:final failure)) {
      AppLogger.e('Auth: sign-out error — ${failure.code}');
    }
    await _clearUserScopedState();
    // Always reset local state regardless of the result.
    state = const AuthState();
  }

  /// Permanently deletes the account, then performs the same local cleanup as
  /// [signOut]. The data source signs out on success (which the router observes
  /// and redirects), so cleanup runs only when deletion actually succeeded —
  /// otherwise the user remains authenticated and nothing is wiped.
  Future<Result<void>> deleteAccount() async {
    AppLogger.i('Auth: delete account');
    final result = await ref.read(deleteAccountUseCaseProvider).call();
    if (result case Ok()) {
      await _clearUserScopedState();
      state = const AuthState();
    } else {
      AppLogger.w('Auth: delete account failed — state left intact');
    }
    return result;
  }

  /// Clears cached posts and resets every user-scoped provider so the next
  /// account starts clean and never sees the previous user's data.
  Future<void> _clearUserScopedState() async {
    await ref.read(postCacheServiceProvider).clearAll();
    ref.invalidate(homeProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(searchProvider);
    ref.invalidate(profileProvider);
    ref.invalidate(userPostsProvider);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
