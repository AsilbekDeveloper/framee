import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/create_post_provider.dart';
import '../widgets/caption_field.dart';
import '../widgets/create_post_app_bar.dart';
import '../widgets/image_picker_area.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPostProvider);
    final notifier = ref.read(createPostProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(profileProvider(null)).valueOrNull;

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
        body: Column(
          children: [
            // ── Scrollable content (image + caption) ──────────────────────────
            // Wrapped in Expanded so the Scaffold's resizeToAvoidBottomInset
            // shrinks this region when the keyboard appears — the image scrolls
            // away naturally instead of overflowing.
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Image area — full-width, no horizontal padding
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: state.hasImage
                          ? SelectedImage(
                              key: ValueKey(state.selectedImagePath),
                              path: state.selectedImagePath!,
                              onRemove: notifier.removeImage,
                              onCrop: notifier.pickImage,
                            )
                          : _ImagePlaceholder(
                              key: const ValueKey('placeholder'),
                              onTap: notifier.pickImage,
                              isDark: isDark,
                            ),
                    ),
                  ),

                  // Error banner
                  if (state.hasError)
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
                                state.errorMessage!,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Caption row: avatar + text field
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.screenPadding,
                        vertical: AppDimens.vlg,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AvatarCircle(avatarUrl: profile?.avatarUrl),
                          Gap(AppDimens.md),
                          Expanded(
                            child: CaptionField(
                              controller: notifier.captionController,
                              onChanged: notifier.onCaptionChanged,
                              isDark: isDark,
                              charCount: state.captionLength,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom toolbar — always visible above keyboard ─────────────────
            _BottomToolbar(
              onGalleryTap: notifier.pickImage,
              isDark: isDark,
            ),
          ],
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

// ── Image Placeholder ─────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({super.key, required this.onTap, required this.isDark});
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
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
              Gap(AppDimens.vsm),
              Text(
                AppStrings.addPhoto,
                style: AppTextStyles.bodyMedium.copyWith(
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

// ── User Avatar Circle ────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({this.avatarUrl});
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      radius: 18.r,
      backgroundColor:
          isDark ? AppColors.darkElevated : AppColors.lightElevated,
      backgroundImage:
          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Icon(Icons.person_rounded,
              size: 20.r,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
          : null,
    );
  }
}

// ── Bottom Toolbar ─────────────────────────────────────────────────────────────

class _BottomToolbar extends StatelessWidget {
  const _BottomToolbar({required this.onGalleryTap, required this.isDark});
  final VoidCallback onGalleryTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;
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
                _ToolbarButton(
                  icon: Icons.photo_library_outlined,
                  label: AppStrings.addPhoto,
                  onTap: onGalleryTap,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22.w, color: color),
          Gap(6.w),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
