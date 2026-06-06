import 'dart:io';

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

    return Scaffold(
      appBar: _CreatePostAppBar(
        onClose: () => context.pop(),
        onPost: state.isSubmittable
            ? () async {
                await notifier.submit();
                if (context.mounted) context.pop();
              }
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

            // Image area (shown when not textOnly)
            if (state.postType != PostTypeSelection.textOnly)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: state.selectedImagePath != null
                    ? _SelectedImage(
                        key: ValueKey(state.selectedImagePath),
                        path: state.selectedImagePath!,
                        onRemove: notifier.removeImage,
                      )
                    : _ImagePickerArea(
                        key: const ValueKey('picker'),
                        onTap: notifier.pickImage,
                      ),
              ),

            Gap(AppDimens.vlg),

            // Caption
            _CaptionField(
              controller: notifier.captionController,
              onChanged: notifier.onCaptionChanged,
              isDark: isDark,
              charCount: state.captionLength,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _CreatePostAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _CreatePostAppBar({
    required this.onClose,
    required this.onPost,
    required this.isLoading,
  });

  final VoidCallback onClose;
  final VoidCallback? onPost;
  final bool isLoading;

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: preferredSize.height,
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
      padding: EdgeInsets.symmetric(horizontal: AppDimens.xl),
      child: Row(
        children: [
          // Close
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close_rounded,
              size: AppDimens.iconMd,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          Text(AppStrings.createPost, style: AppTextStyles.h3),
          const Spacer(),
          // Post button
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
                        : Theme.of(context).brightness == Brightness.dark
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
                          : Theme.of(context).brightness == Brightness.dark
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
                color: AppColors.primary.withOpacity(0.55),
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
class _SelectedImage extends StatelessWidget {
  const _SelectedImage({
    super.key,
    required this.path,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: AppDimens.postImageAspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            child: Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8.w,
          right: 8.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18.w,
              ),
            ),
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: null,
          maxLength: 2200,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.writeCaptionPlaceholder,
            hintStyle: AppTextStyles.inputHint.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            counterText: '',
            contentPadding: EdgeInsets.all(AppDimens.lg),
          ),
        ),
        Gap(AppDimens.vxs),
        Text(
          '$charCount / 2200',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
