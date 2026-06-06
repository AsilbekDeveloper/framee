/// Framee error types for presentation layer.
sealed class AppError {
  const AppError();
  String get message;
}

class NetworkError extends AppError {
  const NetworkError([this._message]);
  final String? _message;
  @override
  String get message => _message ?? 'No internet connection. Please try again.';
}

class AuthError extends AppError {
  const AuthError([this._message]);
  final String? _message;
  @override
  String get message => _message ?? 'Authentication failed.';
}

class NotFoundError extends AppError {
  const NotFoundError([this._message]);
  final String? _message;
  @override
  String get message => _message ?? 'Content not found.';
}

class ServerError extends AppError {
  const ServerError([this._message]);
  final String? _message;
  @override
  String get message => _message ?? 'Something went wrong. Please try again.';
}

class ValidationError extends AppError {
  const ValidationError(this._message);
  final String _message;
  @override
  String get message => _message;
}

class UnknownError extends AppError {
  const UnknownError([this._message]);
  final String? _message;
  @override
  String get message => _message ?? 'An unexpected error occurred.';
}

/// Maps a raw exception to a typed [AppError].
AppError mapError(Object error) {
  final msg = error.toString();
  if (msg.contains('SocketException') ||
      msg.contains('NetworkException') ||
      msg.contains('No address associated')) {
    return const NetworkError();
  }
  if (msg.contains('401') || msg.contains('403') || msg.contains('auth')) {
    return const AuthError();
  }
  if (msg.contains('404')) return const NotFoundError();
  if (msg.contains('500') || msg.contains('502') || msg.contains('503')) {
    return const ServerError();
  }
  return UnknownError(msg);
}
