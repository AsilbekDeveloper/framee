import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/errors/failure_message.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/providers/user_posts_provider.dart';
import '../../data/providers/post_data_providers.dart';
import '../../domain/entities/post.dart';
import '../providers/create_post_provider.dart';
import '../providers/post_detail_provider.dart';
import '../widgets/caption_field.dart';

// ── Image State ───────────────────────────────────────────────────────────────

sealed class EditImageState {}

class _ExistingImage extends EditImageState {
  _ExistingImage(this.url);
  final String url;
}

class _NewLocalImage extends EditImageState {
  _NewLocalImage(this.path);
  final String path;
}

class _NoImage extends EditImageState {}

// ── State ─────────────────────────────────────────────────────────────────────

class _EditPostState {
  const _EditPostState({
    required this.imageState,
    required this.captionLength,
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
  });

  final EditImageState imageState;
  final int captionLength;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;

  bool get hasImage => imageState is! _NoImage;
  bool get hasError => errorMessage != null;
  bool get isSubmittable =>
      !isLoading &&
      captionLength <= CreatePostState.maxCaptionLength &&
      (hasImage || captionLength > 0);

  _EditPostState copyWith({
    EditImageState? imageState,
    int? captionLength,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSaved,
  }) =>
      _EditPostState(
        imageState: imageState ?? this.imageState,
        captionLength: captionLength ?? this.captionLength,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        isSaved: isSaved ?? this.isSaved,
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class EditPostScreen extends ConsumerStatefulWidget {
  const EditPostScreen({super.key, required this.post});
  final Post post;

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  late final TextEditingController _captionController;
  late _EditPostState _state;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption ?? '');
    _state = _EditPostState(
      imageState: widget.post.imageUrl != null
          ? _ExistingImage(widget.post.imageUrl!)
          : _NoImage(),
      captionLength: widget.post.caption?.length ?? 0,
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    final captionChanged =
        _captionController.text.trim() != (widget.post.caption ?? '').trim();
    final imageChanged = _state.imageState is! _ExistingImage ||
        (_state.imageState as _ExistingImage).url != widget.post.imageUrl;
    return captionChanged || imageChanged;
  }

  void _updateState(_EditPostState newState) => setState(() => _state = newState);

  void _onCaptionChanged(String val) {
    _updateState(_state.copyWith(captionLength: val.length, clearError: true));
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 90,
    );
    if (file == null) return;

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
          doneButtonTitle: AppStrings.done,
          cancelButtonTitle: AppStrings.cancel,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );
    if (cropped == null) return;

    _updateState(_state.copyWith(imageState: _NewLocalImage(cropped.path)));
  }

  void _removeImage() {
    _updateState(_state.copyWith(imageState: _NoImage()));
  }

  Future<void> _submit() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    _updateState(_state.copyWith(isLoading: true, clearError: true));

    final imageState = _state.imageState;
    final params = UpdatePostParams(
      postId: widget.post.id,
      userId: userId,
      caption: _captionController.text.trim().isEmpty
          ? null
          : _captionController.text.trim(),
      newImageLocalPath:
          imageState is _NewLocalImage ? imageState.path : null,
      removeImage: imageState is _NoImage && widget.post.imageUrl != null,
    );

    final result = await ref.read(updatePostUseCaseProvider).call(params);

    switch (result) {
      case Ok():
        AppLogger.i('EditPost: post updated — ${widget.post.id}');
        ref.invalidate(homeProvider);
        ref.invalidate(postDetailProvider(widget.post.id));
        ref.invalidate(userPostsProvider(userId));
        ref.invalidate(profileProvider(userId));
        ref.invalidate(profileProvider(null));

        _updateState(_state.copyWith(isLoading: false, isSaved: true));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.postUpdated),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }

      case Err(:final failure):
        AppLogger.w('EditPost: error — ${failure.code}');
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: localizedFailure(failure),
        ));
    }
  }

  Future<void> _confirmDiscard() async {
    if (!_hasUnsavedChanges) {
      context.pop();
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.discardChanges),
        content: Text(AppStrings.discardChangesSub),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppStrings.discardPostConfirm),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageState = _state.imageState;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _confirmDiscard,
          ),
          title: Text(AppStrings.editPost),
          actions: [
            if (_state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _state.isSubmittable ? _submit : null,
                child: Text(
                  AppStrings.save,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: _state.isSubmittable
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Image area
                  SliverToBoxAdapter(
                    child: switch (imageState) {
                      _ExistingImage(:final url) => _RemoteImagePreview(
                          url: url,
                          onReplace: _pickImage,
                          onRemove: _removeImage,
                          isDark: isDark,
                        ),
                      _NewLocalImage(:final path) => _LocalImagePreview(
                          path: path,
                          onReplace: _pickImage,
                          onRemove: _removeImage,
                          isDark: isDark,
                        ),
                      _NoImage() => _ImagePlaceholder(
                          onTap: _pickImage,
                          isDark: isDark,
                        ),
                    },
                  ),

                  // Error banner
                  if (_state.hasError)
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        color: AppColors.error.withValues(alpha: 0.1),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.screenPadding,
                          vertical: AppDimens.vsm,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 16),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                _state.errorMessage!,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Caption field
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.screenPadding,
                        vertical: AppDimens.vlg,
                      ),
                      child: CaptionField(
                        controller: _captionController,
                        onChanged: _onCaptionChanged,
                        isDark: isDark,
                        charCount: _state.captionLength,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom toolbar
            _BottomToolbar(onGalleryTap: _pickImage, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ── Image Preview Widgets ─────────────────────────────────────────────────────

class _RemoteImagePreview extends StatelessWidget {
  const _RemoteImagePreview({
    required this.url,
    required this.onReplace,
    required this.onRemove,
    required this.isDark,
  });

  final String url;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: AppDimens.postImageAspectRatio,
          child: GestureDetector(
            onTap: onReplace,
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _ImageActionButton(icon: Icons.close, onTap: onRemove),
        ),
      ],
    );
  }
}

class _LocalImagePreview extends StatelessWidget {
  const _LocalImagePreview({
    required this.path,
    required this.onReplace,
    required this.onRemove,
    required this.isDark,
  });

  final String path;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: AppDimens.postImageAspectRatio,
          child: GestureDetector(
            onTap: onReplace,
            child: Image.file(
              File(path),
              key: ValueKey(path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _ImageActionButton(icon: Icons.close, onTap: onRemove),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.onTap, required this.isDark});
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: AppDimens.postImageAspectRatio,
        child: ColoredBox(
          color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48.w,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              Gap(AppDimens.vsm),
              Text(
                AppStrings.addPhoto,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageActionButton extends StatelessWidget {
  const _ImageActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _BottomToolbar extends StatelessWidget {
  const _BottomToolbar({required this.onGalleryTap, required this.isDark});
  final VoidCallback onGalleryTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final color = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: dividerColor),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding,
              vertical: AppDimens.vsm,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onGalleryTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 22.w, color: color),
                      Gap(6.w),
                      Text(
                        AppStrings.addPhoto,
                        style: AppTextStyles.caption.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
