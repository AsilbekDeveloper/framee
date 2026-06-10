import 'failure.dart';

/// Muvaffaqiyat yoki xato natijasini ifodalovchi sealed class.
///
/// Exception throw qilish o'rniga ishlatiladi — type-safe, aniq, test qilish oson.
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

  /// Muvaffaqiyat qiymatini qaytaradi, xato bo'lsa `null`
  T? get valueOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  /// Xato ob'ektini qaytaradi, muvaffaqiyat bo'lsa `null`
  Failure? get failureOrNull => switch (this) {
        Ok() => null,
        Err(:final failure) => failure,
      };

  /// Pattern matching yordamchi metod
  R fold<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) =>
      switch (this) {
        Ok(:final value) => ok(value),
        Err(:final failure) => err(failure),
      };

  /// Qiymatni transform qiladi — xato bo'lsa o'zgarmaydi
  Result<U> map<U>(U Function(T value) transform) => switch (this) {
        Ok(:final value) => Ok(transform(value)),
        Err(:final failure) => Err(failure),
      };

  /// Async chain: Ok bo'lsa keyingi amalga o'tadi
  Future<Result<U>> flatMap<U>(
    Future<Result<U>> Function(T value) transform,
  ) =>
      switch (this) {
        Ok(:final value) => transform(value),
        Err(:final failure) => Future.value(Err(failure)),
      };
}

/// Muvaffaqiyatli natija
final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  String toString() => 'Ok($value)';
}

/// Xatolik natijasi
final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  String toString() => 'Err(${failure.code}: ${failure.message})';
}

// ── Extensions ────────────────────────────────────────────────────────────────

extension ResultExtension<T> on Result<T> {
  /// Exception'ni Result'ga o'giradi
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
  /// `map` ning async versiyasi
  Future<Result<U>> thenMap<U>(U Function(T value) transform) async {
    return (await this).map(transform);
  }

  /// `flatMap` ning async versiyasi
  Future<Result<U>> thenFlatMap<U>(
    Future<Result<U>> Function(T value) transform,
  ) async {
    return (await this).flatMap(transform);
  }
}
