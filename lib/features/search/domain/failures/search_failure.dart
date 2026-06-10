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
          message: 'Tarmoq xatosi. Internet aloqasini tekshiring.',
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
          message: 'Qidiruv so\'zi bo\'sh bo\'lmasligi kerak.',
          code: 'search/empty-query',
        );
}
