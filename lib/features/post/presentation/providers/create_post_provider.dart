import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../post/data/providers/post_data_providers.dart';
import '../../../post/domain/entities/post.dart';

// ── Post Type ─────────────────────────────────────────────────────────────────

enum PostTypeSelection {
  all,
  textOnly,
  imageOnly;

  String get label => switch (this) {
        all => AppStrings.allPosts,
        textOnly => AppStrings.textOnly,
        imageOnly => AppStrings.imageOnly,
      };
}

// ── State ─────────────────────────────────────────────────────────────────────

class CreatePostState {
  const CreatePostState({
    this.postType = PostTypeSelection.all,
    this.selectedImagePath,
    this.captionLength = 0,
    this.isLoading = false,
    this.errorMessage,
    this.publishedPost,
  });

  final PostTypeSelection postType;
  final String? selectedImagePath;
  final int captionLength;
  final bool isLoading;
  final String? errorMessage;
  final Post? publishedPost;

  static const int maxCaptionLength = 2200;

  bool get hasImage => selectedImagePath != null;
  bool get hasCaption => captionLength > 0;
  bool get isCaptionOverLimit => captionLength > maxCaptionLength;

  bool get isSubmittable {
    if (isCaptionOverLimit) return false;
    return hasCaption || hasImage;
  }

  bool get hasError => errorMessage != null;
  bool get isPublished => publishedPost != null;

  /// True when the user has entered content — used to show a discard confirmation on close.
  bool get hasUnsavedContent => hasImage || hasCaption;

  CreatePostState copyWith({
    PostTypeSelection? postType,
    String? selectedImagePath,
    int? captionLength,
    bool? isLoading,
    String? errorMessage,
    Post? publishedPost,
    bool clearImage = false,
    bool clearError = false,
  }) =>
      CreatePostState(
        postType: postType ?? this.postType,
        selectedImagePath:
            clearImage ? null : (selectedImagePath ?? this.selectedImagePath),
        captionLength: captionLength ?? this.captionLength,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        publishedPost: publishedPost ?? this.publishedPost,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CreatePostNotifier extends Notifier<CreatePostState> {
  final captionController = TextEditingController();
  final _picker = ImagePicker();

  @override
  CreatePostState build() {
    ref.onDispose(captionController.dispose);
    return const CreatePostState();
  }

  void setPostType(PostTypeSelection type) {
    // textOnly → clear any selected image since the user switched to text-only mode
    final shouldClearImage = type == PostTypeSelection.textOnly;
    state = state.copyWith(postType: type, clearImage: shouldClearImage);
  }

  void onCaptionChanged(String val) =>
      state = state.copyWith(captionLength: val.length, clearError: true);

  // ── Image Pick + Crop ───────────────────────────────────────────────────────

  Future<void> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 90,
    );
    if (file == null) return;

    AppLogger.d('CreatePost: image selected — ${file.path}');

    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppStrings.cropImage,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          backgroundColor: Colors.black,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: AppStrings.cropImage,
          doneButtonTitle: 'Done',
          cancelButtonTitle: AppStrings.cancel,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          resetAspectRatioEnabled: true,
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    // User cancelled the crop dialog
    if (cropped == null) {
      AppLogger.d('CreatePost: crop cancelled');
      return;
    }

    AppLogger.d('CreatePost: image cropped — ${cropped.path}');
    state = state.copyWith(selectedImagePath: cropped.path);
  }

  void removeImage() => state = state.copyWith(clearImage: true);

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> submit() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = state.copyWith(errorMessage: AppStrings.errorNotLoggedIn);
      return;
    }

    if (state.postType == PostTypeSelection.imageOnly && !state.hasImage) {
      state = state.copyWith(errorMessage: AppStrings.errorImageRequired);
      return;
    }

    if (state.isCaptionOverLimit) {
      state = state.copyWith(errorMessage: AppStrings.errorCaptionTooLong);
      return;
    }

    AppLogger.i('CreatePost: submitting post — $userId');
    state = state.copyWith(isLoading: true, clearError: true);

    final params = CreatePostParams(
      userId: userId,
      imageLocalPath: state.selectedImagePath,
      caption: captionController.text.trim().isEmpty
          ? null
          : captionController.text.trim(),
    );

    final result = await ref.read(createPostUseCaseProvider).call(params);

    switch (result) {
      case Ok(:final value):
        AppLogger.i('CreatePost: post created — ${value.id}');
        // Invalidate the feed so the new post appears immediately
        ref.invalidate(homeProvider);
        state = state.copyWith(isLoading: false, publishedPost: value);

      case Err(:final failure):
        AppLogger.w('CreatePost: error — ${failure.code}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }
}

final createPostProvider =
    NotifierProvider<CreatePostNotifier, CreatePostState>(
  CreatePostNotifier.new,
);
