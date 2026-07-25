import '../../../../core/errors/failure.dart';

/// Base class for all auth-feature failures, extending [Failure].
abstract class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Email or password is incorrect.
final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(
          message: 'Invalid email or password.',
          code: 'auth/invalid-credentials',
        );
}

/// Email address has not been confirmed yet.
final class EmailNotConfirmedFailure extends AuthFailure {
  const EmailNotConfirmedFailure()
      : super(
          message: 'Please confirm your email address.',
          code: 'auth/email-not-confirmed',
        );
}

/// Email is already registered.
final class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super(
          message: 'This email is already registered.',
          code: 'auth/email-already-in-use',
        );
}

/// Password does not meet the minimum length requirement.
final class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
      : super(
          message: 'Password must be at least 6 characters.',
          code: 'auth/weak-password',
        );
}

/// Passwords do not match (client-side check).
final class PasswordMismatchFailure extends AuthFailure {
  const PasswordMismatchFailure()
      : super(
          message: 'Passwords do not match.',
          code: 'auth/password-mismatch',
        );
}

/// One or more required fields are empty (client-side check).
final class EmptyFieldsFailure extends AuthFailure {
  const EmptyFieldsFailure()
      : super(
          message: 'Please fill in all fields.',
          code: 'auth/empty-fields',
        );
}

/// Email address is not a valid format (client-side check).
final class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure()
      : super(
          message: 'Please enter a valid email address.',
          code: 'auth/invalid-email',
        );
}

/// No account found for the given credentials.
final class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure()
      : super(
          message: 'User not found.',
          code: 'auth/user-not-found',
        );
}

/// The user's session has expired and they must sign in again.
final class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure()
      : super(
          message: 'Session expired. Please sign in again.',
          code: 'auth/session-expired',
        );
}

/// Uncategorized auth error — wraps an unknown message from Supabase.
final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'auth/unknown',
        );
}
