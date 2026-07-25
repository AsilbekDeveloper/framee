import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/failures/post_failure.dart';
import 'package:framee/features/post/domain/usecases/create_post_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockPostRepository repository;
  late CreatePostUseCase useCase;

  setUpAll(registerFallbackValues);

  setUp(() {
    repository = MockPostRepository();
    useCase = CreatePostUseCase(repository);
  });

  group('CreatePostUseCase', () {
    test('rejects a post with neither image nor caption', () async {
      final result = await useCase.call(const CreatePostParams(
        userId: 'user-1',
        imageLocalPath: null,
        caption: '   ',
      ));

      expect((result as Err).failure, isA<PostValidationFailure>());
      verifyNever(() => repository.createPost(any()));
    });

    test('rejects a caption over the max length', () async {
      final result = await useCase.call(CreatePostParams(
        userId: 'user-1',
        caption: 'a' * 2201,
      ));

      expect((result as Err).failure, isA<PostValidationFailure>());
    });

    test('accepts an image-only post with no caption', () async {
      const params = CreatePostParams(
        userId: 'user-1',
        imageLocalPath: '/tmp/photo.jpg',
      );
      when(() => repository.createPost(params)).thenAnswer(
        (_) async => Ok(_post()),
      );

      final result = await useCase.call(params);

      expect(result, isA<Ok<Post>>());
      verify(() => repository.createPost(params)).called(1);
    });

    test('accepts a caption-only post with no image', () async {
      const params = CreatePostParams(
        userId: 'user-1',
        caption: 'Just text, no image.',
      );
      when(() => repository.createPost(params))
          .thenAnswer((_) async => Ok(_post()));

      final result = await useCase.call(params);

      expect(result, isA<Ok<Post>>());
    });
  });
}

Post _post() => Post(
      id: 'post-1',
      author: const PostAuthor(id: 'user-1', username: 'u', displayName: 'U'),
      createdAt: DateTime(2026, 1, 1),
    );
