import '../../../../core/errors/failure.dart';

abstract class SearchFailure extends Failure {
  const SearchFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

final class EmptyQueryFailure extends SearchFailure {
  const EmptyQueryFailure()
      : super(
          message: 'Search query must not be empty.',
          code: 'search/empty-query',
        );
}
