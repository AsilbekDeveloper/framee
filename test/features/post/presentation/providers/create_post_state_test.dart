import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/post/presentation/providers/create_post_provider.dart';

void main() {
  group('CreatePostState', () {
    test('is not submittable with neither image nor caption', () {
      const state = CreatePostState();

      expect(state.hasImage, isFalse);
      expect(state.hasCaption, isFalse);
      expect(state.isSubmittable, isFalse);
    });

    test('is submittable with only an image', () {
      const state = CreatePostState(selectedImagePath: '/tmp/a.jpg');

      expect(state.isSubmittable, isTrue);
    });

    test('is submittable with only a caption', () {
      const state = CreatePostState(captionLength: 5);

      expect(state.isSubmittable, isTrue);
    });

    test('is not submittable once the caption exceeds the max length', () {
      const state = CreatePostState(
        selectedImagePath: '/tmp/a.jpg',
        captionLength: CreatePostState.maxCaptionLength + 1,
      );

      expect(state.isCaptionOverLimit, isTrue);
      expect(state.isSubmittable, isFalse);
    });

    test('hasUnsavedContent is true with an image even if caption is empty',
        () {
      const state = CreatePostState(selectedImagePath: '/tmp/a.jpg');

      expect(state.hasUnsavedContent, isTrue);
    });

    test('clearImage removes the selected image via copyWith', () {
      const state = CreatePostState(selectedImagePath: '/tmp/a.jpg');

      final cleared = state.copyWith(clearImage: true);

      expect(cleared.selectedImagePath, isNull);
      expect(cleared.hasImage, isFalse);
    });

    test('clearError removes the error message via copyWith', () {
      const state = CreatePostState(errorMessage: 'boom');

      final cleared = state.copyWith(clearError: true);

      expect(cleared.errorMessage, isNull);
      expect(cleared.hasError, isFalse);
    });

    test('isPublished reflects whether a post has been set', () {
      const state = CreatePostState();
      expect(state.isPublished, isFalse);
    });
  });
}
