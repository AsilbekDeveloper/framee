import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum PostTypeSelection {
  all,
  textOnly,
  imageOnly;

  String get label {
    switch (this) {
      case PostTypeSelection.all:
        return 'All';
      case PostTypeSelection.textOnly:
        return 'Text only';
      case PostTypeSelection.imageOnly:
        return 'Image only';
    }
  }
}

class CreatePostState {
  const CreatePostState({
    this.postType = PostTypeSelection.all,
    this.selectedImagePath,
    this.captionLength = 0,
    this.isLoading = false,
  });

  final PostTypeSelection postType;
  final String? selectedImagePath;
  final int captionLength;
  final bool isLoading;

  bool get isSubmittable => captionLength > 0 || selectedImagePath != null;

  CreatePostState copyWith({
    PostTypeSelection? postType,
    String? selectedImagePath,
    int? captionLength,
    bool? isLoading,
    bool clearImage = false,
  }) =>
      CreatePostState(
        postType: postType ?? this.postType,
        selectedImagePath:
            clearImage ? null : selectedImagePath ?? this.selectedImagePath,
        captionLength: captionLength ?? this.captionLength,
        isLoading: isLoading ?? this.isLoading,
      );
}

class CreatePostNotifier extends Notifier<CreatePostState> {
  final captionController = TextEditingController();
  final _picker = ImagePicker();

  @override
  CreatePostState build() {
    ref.onDispose(captionController.dispose);
    return const CreatePostState();
  }

  void setPostType(PostTypeSelection type) =>
      state = state.copyWith(postType: type);

  void onCaptionChanged(String val) =>
      state = state.copyWith(captionLength: val.length);

  Future<void> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (file != null) {
      state = state.copyWith(selectedImagePath: file.path);
    }
  }

  void removeImage() => state = state.copyWith(clearImage: true);

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    // Upload to Supabase Storage then insert post record
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
  }

}

final createPostProvider =
    NotifierProvider<CreatePostNotifier, CreatePostState>(
  CreatePostNotifier.new,
);
