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

  /// `true` — Supabase email tasdiqini yubordi, kirish hali mumkin emas
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

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Auth stream'ini ting — OAuth, token refresh, boshqa tab'dan chiqish
    ref.listen<AsyncValue<AuthUser?>>(authUserStreamProvider, (_, next) {
      final incoming = next.valueOrNull;
      if (incoming?.id != state.user?.id) {
        AppLogger.i(
          incoming == null
              ? 'Auth: foydalanuvchi chiqdi'
              : 'Auth: stream yangilandi — ${incoming.email}',
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
    AppLogger.d('Auth: boshlandi — ${current?.email ?? "mehmon"}');
    return AuthState(user: current);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    AppLogger.i('Auth: kirish — $email');
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref
        .read(_signInUseCaseProvider)
        .call(email: email, password: password);

    switch (result) {
      case Ok(:final value):
        AppLogger.i('Auth: muvaffaqiyatli kirdi — ${value.email}');
        state = state.copyWith(isLoading: false, user: value);
      case Err(:final failure):
        AppLogger.w('Auth: kirish xatosi — ${failure.code}');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    AppLogger.i("Auth: ro'yxatdan o'tish — $email");
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(_signUpUseCaseProvider).call(
          fullName: fullName,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
        );

    switch (result) {
      case Ok(:final value) when value == null:
        // Email tasdiqlash kutilmoqda
        AppLogger.i('Auth: email tasdiqlash kutilmoqda — $email');
        state = state.copyWith(
          isLoading: false,
          awaitingEmailConfirmation: true,
        );
      case Ok(:final value):
        AppLogger.i("Auth: ro'yxatdan o'tdi — ${value!.email}");
        state = state.copyWith(isLoading: false, user: value);
      case Err(:final failure):
        AppLogger.w("Auth: ro'yxatdan o'tish xatosi — ${failure.code}");
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  Future<void> signInWithGoogle() async {
    AppLogger.i('Auth: Google orqali kirish');
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(_signInWithGoogleUseCaseProvider).call();
    // OAuth muvaffaqiyatli bo'lsa natija stream'dan keladi — bu yerda faqat xatoni qaytaramiz
    if (result case Err(:final failure)) {
      AppLogger.w('Auth: Google xatosi — ${failure.code}');
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    AppLogger.i('Auth: parol tiklash — $email');
    state = state.copyWith(isLoading: true, clearError: true);

    final result =
        await ref.read(_sendPasswordResetUseCaseProvider).call(email);

    switch (result) {
      case Ok():
        AppLogger.i('Auth: parol tiklash emaili yuborildi');
        state = state.copyWith(isLoading: false);
      case Err(:final failure):
        AppLogger.w('Auth: parol tiklash xatosi — ${failure.code}');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  Future<void> signOut() async {
    AppLogger.i('Auth: chiqish');
    final result = await ref.read(_signOutUseCaseProvider).call();
    if (result case Err(:final failure)) {
      AppLogger.e('Auth: chiqishda xato — ${failure.code}');
    }
    // Xato bo'lsa ham local state'ni tozalaymiz
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
