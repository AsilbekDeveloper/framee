import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/create_post_provider.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPostProvider);
    final notifier = ref.read(createPostProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Post muvaffaqiyatli e'lon qilindi → snackbar + pop
    ref.listen<CreatePostState>(createPostProvider, (prev, next) {
      if (!next.isPublished) return;
      if (prev?.isPublished == true) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.postPublished),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    });

    return PopScope(
      // Yozilgan content bo'lsa — chiqishdan oldin tasdiqlash
      canPop: !state.hasUnsavedContent,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _CreatePostAppBar(
          onClose: () {
            if (state.hasUnsavedContent) {
              _confirmDiscard(context);
            } else {
              context.pop();
            }
          },
          onPost: state.isSubmittable && !state.isLoading
              ? notifier.submit
              : null,
          isLoading: state.isLoading,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPadding,
            vertical: AppDimens.vlg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post type chips
              _TypeSelector(
                selected: state.postType,
                onSelect: notifier.setPostType,
              ),
              Gap(AppDimens.vlg),

              // Error message
              if (state.hasError)
                Padding(
                  padding: EdgeInsets.only(bottom: AppDimens.vlg),
                  child: Container(
                    padding: EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Image area
              if (state.postType != PostTypeSelection.textOnly)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: state.selectedImagePath != null
                      ? _SelectedImage(
                          key: ValueKey(state.selectedImagePath),
                          path: state.selectedImagePath!,
                          onRemove: notifier.removeImage,
                          onCrop: notifier.pickImage,
                        )
                      : _ImagePickerArea(
                          key: const ValueKey('picker'),
                          onTap: notifier.pickImage,
                        ),
                ),

              Gap(AppDimens.vlg),

              // Caption field
              if (state.postType != PostTypeSelection.imageOnly ||
                  state.selectedImagePath != null)
                _CaptionField(
                  controller: notifier.captionController,
                  onChanged: notifier.onCaptionChanged,
                  isDark: isDark,
                  charCount: state.captionLength,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.discardPost),
        content: const Text(AppStrings.discardPostSub),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.discardPostConfirm),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) context.pop();
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _CreatePostAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CreatePostAppBar({
    required this.onClose,
    required this.onPost,
    required this.isLoading,
  });

  final VoidCallback onClose;
  final AsyncCallback? onPost;
  final bool isLoading;

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: preferredSize.height + topPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding,
        left: AppDimens.xl,
        right: AppDimens.xl,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close_rounded,
              size: AppDimens.iconMd,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          Text(AppStrings.createPost, style: AppTextStyles.h3),
          const Spacer(),
          AnimatedOpacity(
            opacity: onPost != null ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: onPost,
              child: Container(
                height: AppDimens.buttonHeightSm,
                padding: EdgeInsets.symmetric(horizontal: AppDimens.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  boxShadow: onPost != null ? AppColors.primaryShadow : null,
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.post,
                          style: AppTextStyles.buttonSmall
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Type Selector ────────────────────────────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onSelect});

  final PostTypeSelection selected;
  final ValueChanged<PostTypeSelection> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PostTypeSelection.values.map((type) {
          final isSelected = selected == type;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => onSelect(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 34.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryMuted
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.darkBorderSubtle
                            : AppColors.lightBorderSubtle,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    type.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Image Picker Area ────────────────────────────────────────────────────────
class _ImagePickerArea extends StatelessWidget {
  const _ImagePickerArea({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: AppDimens.postImageAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40.w,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
              Gap(AppDimens.vmd),
              Text(
                AppStrings.addPhoto,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
              Gap(AppDimens.vxs),
              Text(
                AppStrings.photoFormats,
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Selected Image ───────────────────────────────────────────────────────────
// Rasmni natural o'lchamida ko'rsatadi (crop qilingan nisbatda)
class _SelectedImage extends StatelessWidget {
  const _SelectedImage({
    super.key,
    required this.path,
    required this.onRemove,
    required this.onCrop,
  });

  final String path;
  final VoidCallback onRemove;
  final VoidCallback onCrop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Natural aspect ratio — AspectRatio yo'q, rasm o'z o'lchamida
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Image.file(
            File(path),
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        // Crop tugmasi
        Positioned(
          top: 8.h,
          left: 8.w,
          child: _ImageActionButton(
            icon: Icons.crop_rounded,
            onTap: onCrop,
          ),
        ),
        // Remove tugmasi
        Positioned(
          top: 8.h,
          right: 8.w,
          child: _ImageActionButton(
            icon: Icons.close_rounded,
            onTap: onRemove,
          ),
        ),
      ],
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
        width: 34.w,
        height: 34.w,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18.w),
      ),
    );
  }
}

// ─── Caption Field ────────────────────────────────────────────────────────────
class _CaptionField extends StatelessWidget {
  const _CaptionField({
    required this.controller,
    required this.onChanged,
    required this.isDark,
    required this.charCount,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final int charCount;

  static const _maxChars = CreatePostState.maxCaptionLength;
  bool get _isOverLimit => charCount > _maxChars;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: null,
          // maxLength olib tashlandi — Flutter'ning built-in counter'i ishlatilmaydi
          // _isOverLimit orqali o'zimiz ko'rsatamiz
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.writeCaptionPlaceholder,
            hintStyle: AppTextStyles.inputHint.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            contentPadding: EdgeInsets.all(AppDimens.lg),
            // Limit oshirilganda border qizaradi
            enabledBorder: _isOverLimit
                ? OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.error),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  )
                : null,
          ),
        ),
        Gap(AppDimens.vxs),
        Text(
          '$charCount / $_maxChars',
          style: AppTextStyles.caption.copyWith(
            color: _isOverLimit
                ? AppColors.error
                : isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
            fontWeight:
                _isOverLimit ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
