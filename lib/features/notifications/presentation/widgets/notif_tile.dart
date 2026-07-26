import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:gap/gap.dart';

import '../../../../../core/components/app_avatar.dart';
import '../../../../../core/components/follow_button.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/notification.dart';

class NotifTile extends StatelessWidget {
  const NotifTile({
    super.key,
    required this.notif,
    required this.onTap,
    required this.onActorTap,
    required this.onFollowTap,
  });

  final AppNotification notif;
  final VoidCallback onTap;

  /// Called when the actor's avatar or username is tapped — navigates to
  /// their profile instead of [onTap]'s destination (e.g. the post a
  /// comment/like notification points to).
  final VoidCallback onActorTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: !notif.isRead ? AppColors.primaryMuted : Colors.transparent,
          border: notif.isRead
              ? null
              : const Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NotifIcon(type: notif.type),
            Gap(AppDimens.md),
            GestureDetector(
              onTap: onActorTap,
              child: AppAvatar(
                imageUrl: notif.actor.avatarUrl,
                initials: notif.actor.initials,
                size: AvatarSize.sm,
              ),
            ),
            Gap(AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotifText(notif: notif, onActorTap: onActorTap),
                  Gap(3.h),
                  Text(
                    notif.createdAt.timeAgo,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Gap(AppDimens.md),
            if (notif.type == NotificationType.followRequest)
              NotifAcceptButton(onTap: onFollowTap)
            else if (notif.type == NotificationType.follow)
              FollowButton(
                // A pending request to a private account uses the same outlined
                // style as Following, with a "Requested" label.
                isFollowing:
                    notif.actor.followStatus == FollowStatus.following ||
                        notif.actor.followStatus == FollowStatus.requested,
                label: notif.actor.followStatus == FollowStatus.requested
                    ? AppStrings.requested
                    : null,
                onTap: onFollowTap,
              )
            else
              NotifPostThumbnail(imageUrl: notif.postImageUrl),
          ],
        ),
      ),
    );
  }
}

class NotifIcon extends StatelessWidget {
  const NotifIcon({super.key, required this.type});
  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = switch (type) {
      NotificationType.like => (
          AppColors.like,
          AppColors.likeBackground,
          Icons.favorite_rounded,
        ),
      NotificationType.follow || NotificationType.followRequest => (
          AppColors.primary,
          AppColors.primaryMuted,
          Icons.person_add_rounded,
        ),
      NotificationType.comment || NotificationType.mention => (
          AppColors.success,
          AppColors.followBg,
          Icons.chat_bubble_rounded,
        ),
    };

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Icon(icon, size: 16.w, color: color),
    );
  }
}

class NotifText extends StatefulWidget {
  const NotifText({super.key, required this.notif, required this.onActorTap});
  final AppNotification notif;
  final VoidCallback onActorTap;

  @override
  State<NotifText> createState() => _NotifTextState();
}

class _NotifTextState extends State<NotifText> {
  late TapGestureRecognizer _usernameTap;

  @override
  void initState() {
    super.initState();
    _usernameTap = TapGestureRecognizer()..onTap = widget.onActorTap;
  }

  @override
  void didUpdateWidget(NotifText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _usernameTap.onTap = widget.onActorTap;
  }

  @override
  void dispose() {
    _usernameTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final body = switch (widget.notif.type) {
      NotificationType.like => AppStrings.likedYourPost,
      NotificationType.follow => AppStrings.startedFollowingYou,
      NotificationType.followRequest => AppStrings.wantsToFollowYou,
      NotificationType.comment => AppStrings.commentedYourPost,
      NotificationType.mention => AppStrings.mentionedYou,
    };

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${widget.notif.actor.username} ',
            style: AppTextStyles.labelSmall.copyWith(color: textColor),
            recognizer: _usernameTap,
          ),
          TextSpan(
            text: body,
            style: AppTextStyles.bodySmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class NotifAcceptButton extends StatelessWidget {
  const NotifAcceptButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: AppDimens.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
        ),
        child: Text(
          AppStrings.accept,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class NotifPostThumbnail extends StatelessWidget {
  const NotifPostThumbnail({super.key, this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = 44.w;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                memCacheWidth:
                    (size * MediaQuery.devicePixelRatioOf(context)).round(),
                placeholder: (_, _) =>
                    _FallbackThumbnail(isDark: isDark, size: size),
                errorWidget: (_, _, _) =>
                    _FallbackThumbnail(isDark: isDark, size: size),
              )
            : _FallbackThumbnail(isDark: isDark, size: size),
      ),
    );
  }
}

class _FallbackThumbnail extends StatelessWidget {
  const _FallbackThumbnail({required this.isDark, required this.size});
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
      child: Icon(
        Icons.image_outlined,
        size: 18.w,
        color: AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }
}
