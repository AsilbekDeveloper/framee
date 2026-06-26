import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../../core/components/app_avatar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../auth/data/providers/auth_data_providers.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class ReplyBanner extends StatelessWidget {
  const ReplyBanner({
    super.key,
    required this.username,
    required this.onClear,
  });

  final String username;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.vsm,
      ),
      color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
      child: Row(
        children: [
          Icon(Icons.reply_rounded, size: 14.w, color: AppColors.primary),
          Gap(6.w),
          Text(
            '@$username',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(4.w),
          Text(
            AppStrings.replyingTo,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 16.w,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentInputBar extends ConsumerStatefulWidget {
  const CommentInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.focusNode,
  });

  final TextEditingController controller;
  final AsyncCallback onSend;
  final FocusNode? focusNode;

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  bool _isSending = false;

  Future<void> _handleSend() async {
    if (_isSending || widget.controller.text.trim().isEmpty) return;
    setState(() => _isSending = true);
    try {
      await widget.onSend();
      if (mounted) {
        widget.controller.clear();
        widget.focusNode?.unfocus();
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Prefer the profile's uploaded (http) avatar over auth metadata, which can
    // still hold a stale local crop-cache path that no longer exists on disk.
    final profile = ref.watch(profileProvider(null)).valueOrNull;
    final authUser = ref.watch(authUserStreamProvider).valueOrNull;
    final avatarUrl = profile?.avatarUrl ?? authUser?.avatarUrl;
    final initials = profile?.initials ??
        (authUser?.username?.isNotEmpty == true
            ? authUser!.username![0].toUpperCase()
            : 'A');

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.lg,
        AppDimens.vmd,
        AppDimens.lg,
        AppDimens.vmd + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: avatarUrl,
            initials: initials,
            size: AvatarSize.xs,
          ),
          Gap(AppDimens.md),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 40.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.lightInput,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLines: 4,
                minLines: 1,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.addCommentPlaceholder,
                  hintStyle: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          Gap(AppDimens.md),
          GestureDetector(
            onTap: _isSending ? null : _handleSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _isSending
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: _isSending ? null : AppColors.primaryShadow,
              ),
              child: _isSending
                  ? Padding(
                      padding: EdgeInsets.all(10.w),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.send_rounded, size: 18.w, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
