import 'failure.dart';

/// Sealed class representing either a success or a failure.
///
/// Used instead of throwing exceptions — type-safe, explicit, easy to test.
///
/// ```dart
/// // Repository
/// Future<Result<User>> signIn(...) async { ... }
///
/// // Presenter
/// final result = await signIn(...);
/// switch (result) {
///   case Ok(:final value): navigate(value);
///   case Err(:final failure): showError(failure.message);
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Returns the success value, or `null` on failure.
  T? get valueOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  /// Returns the failure object, or `null` on success.
  Failure? get failureOrNull => switch (this) {
        Ok() => null,
        Err(:final failure) => failure,
      };

  /// Pattern-matching helper for handling both branches.
  R fold<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) =>
      switch (this) {
        Ok(:final value) => ok(value),
        Err(:final failure) => err(failure),
      };

  /// Transforms the success value; passes failures through unchanged.
  Result<U> map<U>(U Function(T value) transform) => switch (this) {
        Ok(:final value) => Ok(transform(value)),
        Err(:final failure) => Err(failure),
      };

  /// Async chain: proceeds to the next operation only on success.
  Future<Result<U>> flatMap<U>(
    Future<Result<U>> Function(T value) transform,
  ) =>
      switch (this) {
        Ok(:final value) => transform(value),
        Err(:final failure) => Future.value(Err(failure)),
      };
}

/// Successful result carrying a value.
final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  String toString() => 'Ok($value)';
}

/// Failed result carrying a failure.
final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  String toString() => 'Err(${failure.code}: ${failure.message})';
}

// ── Extensions ────────────────────────────────────────────────────────────────

extension ResultExtension<T> on Result<T> {
  /// Wraps a synchronous body in a Result, catching any exceptions.
  static Result<T> guard<T>(T Function() body) {
    try {
      return Ok(body());
    } on Failure catch (f) {
      return Err(f);
    } catch (e, st) {
      return Err(UnexpectedFailure(originalError: e, stackTrace: st));
    }
  }
}

extension AsyncResultExtension<T> on Future<Result<T>> {
  /// Async version of [Result.map].
  Future<Result<U>> thenMap<U>(U Function(T value) transform) async {
    return (await this).map(transform);
  }

  /// Async version of [Result.flatMap].
  Future<Result<U>> thenFlatMap<U>(
    Future<Result<U>> Function(T value) transform,
  ) async {
    return (await this).flatMap(transform);
  }
}
