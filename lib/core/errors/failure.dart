/// Base sealed class for all application errors.
///
/// Each feature extends this class with its own failure types.
/// [message]        — human-readable text shown to the user
/// [code]           — machine-readable identifier: 'auth/invalid-credentials'
/// [originalError]  — original exception, used for debugging
/// [stackTrace]     — stack trace, used for debugging
abstract class Failure implements Exception {
  const Failure({
    required this.message,
    required this.code,
    this.originalError,
    this.stackTrace,
  });

  final String message;
  final String code;
  final Object? originalError;
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure[$code]: $message';
}

// ── Shared failures — usable across all features ──────────────────────────────

/// No internet connection or server unreachable.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'Network error. Please check your connection.',
          code: 'network/unavailable',
        );
}

/// Server returned a 5xx error.
final class ServerFailure extends Failure {
  const ServerFailure({
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'Server error. Please try again later.',
          code: 'server/error',
        );
}

/// The requested resource was not found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String? message,
    super.originalError,
  }) : super(
          message: message ?? 'Data not found.',
          code: 'not-found',
        );
}

/// User is not authenticated or the session has expired.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.stackTrace})
      : super(
          message: 'Unauthorized. Please sign in again.',
          code: 'unauthorized',
        );
}

/// Input validation failed on the client side.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    String? field,
  }) : super(
          code: 'validation/${field ?? "general"}',
        );
}

/// File upload or read error (Storage).
final class StorageFailure extends Failure {
  const StorageFailure({
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'File storage error.',
          code: 'storage/error',
        );
}

/// Unexpected, uncategorized error.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'An unexpected error occurred.',
          code: 'unexpected',
        );
}
