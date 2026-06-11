import '../../../../core/errors/failure.dart';

abstract class SearchFailure extends Failure {
  const SearchFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

final class SearchNetworkFailure extends SearchFailure {
  const SearchNetworkFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Network error. Please check your internet connection.',
          code: 'search/network',
        );
}

final class SearchServerFailure extends SearchFailure {
  const SearchServerFailure({required super.message, super.originalError})
      : super(code: 'search/server');
}

final class EmptyQueryFailure extends SearchFailure {
  const EmptyQueryFailure()
      : super(
          message: 'Search query must not be empty.',
          code: 'search/empty-query',
        );
}
