import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/search/domain/usecases/get_explore_posts_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test(
      'GetExplorePostsUseCase delegates to SearchRepository.getExplorePosts',
      () async {
    final repository = MockSearchRepository();
    when(() => repository.getExplorePosts(currentUserId: 'user-1'))
        .thenAnswer((_) async => const Ok(<Post>[]));

    final result = await GetExplorePostsUseCase(repository)
        .call(currentUserId: 'user-1');

    expect(result, isA<Ok<List<Post>>>());
    verify(() => repository.getExplorePosts(currentUserId: 'user-1'))
        .called(1);
  });
}
