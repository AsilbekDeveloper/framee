import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';

/// Auth domain contract — the data layer implements this interface.
/// All methods return [Result] and never throw exceptions.
abstract interface class AuthRepository {
  /// Returns the currently cached user synchronously (may be null if not signed in).
  AuthUser? get currentUser;

  /// Emits the current user whenever the auth state changes.
  Stream<AuthUser?> get authStateChanges;

  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  });

  /// Registers a new user. Returns `Ok(null)` when email confirmation is required.
  Future<Result<AuthUser?>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<void>> signInWithGoogle();
  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Updates the password for the currently signed-in user.
  Future<Result<void>> updatePassword(String newPassword);

  /// Permanently deletes the user's account and all associated data.
  Future<Result<void>> deleteAccount();
}
