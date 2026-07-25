import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/failures/post_failure.dart';
import 'package:framee/features/post/domain/usecases/add_comment_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockPostRepository repository;
  late AddCommentUseCase useCase;

  setUpAll(registerFallbackValues);

  setUp(() {
    repository = MockPostRepository();
    useCase = AddCommentUseCase(repository);
  });

  group('AddCommentUseCase', () {
    test('rejects a blank comment', () async {
      final result = await useCase.call(const AddCommentParams(
        postId: 'post-1',
        userId: 'user-1',
        text: '   ',
      ));

      expect((result as Err).failure, isA<PostValidationFailure>());
      verifyNever(() => repository.addComment(any()));
    });

    test('rejects a comment over 500 characters', () async {
      final result = await useCase.call(AddCommentParams(
        postId: 'post-1',
        userId: 'user-1',
        text: 'a' * 501,
      ));

      expect((result as Err).failure, isA<PostValidationFailure>());
    });

    test('trims the text before delegating', () async {
      // AddCommentParams has no value equality, so exact-instance stubbing
      // would never match the usecase's freshly-constructed params — stub
      // with any() and assert on the captured argument instead.
      final comment = _comment();
      when(() => repository.addComment(any()))
          .thenAnswer((_) async => Ok(comment));

      final result = await useCase.call(const AddCommentParams(
        postId: 'post-1',
        userId: 'user-1',
        text: '  Nice post!  ',
      ));

      expect(result, isA<Ok<Comment>>());
      final captured =
          verify(() => repository.addComment(captureAny())).captured;
      final sentParams = captured.single as AddCommentParams;
      expect(sentParams.postId, 'post-1');
      expect(sentParams.userId, 'user-1');
      expect(sentParams.text, 'Nice post!');
    });

    test('passes parentId through for a reply', () async {
      when(() => repository.addComment(any()))
          .thenAnswer((_) async => Ok(_comment(parentId: 'comment-1')));

      final result = await useCase.call(const AddCommentParams(
        postId: 'post-1',
        userId: 'user-1',
        text: 'A reply',
        parentId: 'comment-1',
      ));

      expect((result as Ok).value.parentId, 'comment-1');
    });
  });
}

Comment _comment({String? parentId}) => Comment(
      id: 'comment-1',
      postId: 'post-1',
      author: const PostAuthor(id: 'user-1', username: 'u', displayName: 'U'),
      text: 'Nice post!',
      createdAt: DateTime(2026, 1, 1),
      parentId: parentId,
    );
