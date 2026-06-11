import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/create_post_provider.dart';
import '../widgets/caption_field.dart';
import '../widgets/create_post_app_bar.dart';
import '../widgets/image_picker_area.dart';
import '../widgets/post_type_selector.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPostProvider);
    final notifier = ref.read(createPostProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<CreatePostState>(createPostProvider, (prev, next) {
      if (!next.isPublished) return;
      if (prev?.isPublished == true) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.postPublished),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    });

    return PopScope(
      canPop: !state.hasUnsavedContent,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CreatePostAppBar(
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
              PostTypeSelector(
                selected: state.postType,
                onSelect: notifier.setPostType,
              ),
              Gap(AppDimens.vlg),
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
              if (state.postType != PostTypeSelection.textOnly)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: state.selectedImagePath != null
                      ? SelectedImage(
                          key: ValueKey(state.selectedImagePath),
                          path: state.selectedImagePath!,
                          onRemove: notifier.removeImage,
                          onCrop: notifier.pickImage,
                        )
                      : ImagePickerArea(
                          key: const ValueKey('picker'),
                          onTap: notifier.pickImage,
                        ),
                ),
              Gap(AppDimens.vlg),
              if (state.postType != PostTypeSelection.imageOnly ||
                  state.selectedImagePath != null)
                CaptionField(
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
        title: Text(AppStrings.discardPost),
        content: Text(AppStrings.discardPostSub),
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
    if (confirm == true && context.mounted) context.pop();
  }
}
