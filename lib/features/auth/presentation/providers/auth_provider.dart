import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill all fields');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Replace with: await supabase.auth.signInWithPassword(...)
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid email or password',
      );
    }
  }

  Future<void> signUp({required String fullName, required String email, required String password, required String confirmPassword}) async {
    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: 'Passwords do not match');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Replace with: await supabase.auth.signUp(...)
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    // await supabase.auth.signOut();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);