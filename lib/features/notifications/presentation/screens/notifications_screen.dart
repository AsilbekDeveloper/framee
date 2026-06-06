import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/models/ui_models.dart';
import '../../../../core/router/app_router.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    final unread = state.notifications.where((n) => !n.isRead).toList();
    final read = state.notifications.where((n) => n.isRead).toList();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.notifications),
        actions: [
          if (unread.isNotEmpty)
            TextButton(
              onPressed: notifier.markAllRead,
              child: Text(
                AppStrings.markAllRead,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
              ? EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: AppStrings.noNotifications,
                  subtitle: AppStrings.noNotificationsSub,
                )
              : CustomScrollView(
                  slivers: [
                    if (unread.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: SectionLabel(
                          '${AppStrings.newSection} · ${unread.length}',
                        ),
                      ),
                      SliverList.builder(
                        itemCount: unread.length,
                        itemBuilder: (context, i) => _NotifTile(
                          notif: unread[i],
                          onTap: () {
                            notifier.markRead(unread[i].id);
                            _navigate(context, unread[i]);
                          },
                          onFollowTap: () =>
                              notifier.toggleFollow(unread[i].id),
                        ),
                      ),
                    ],
                    if (read.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: SectionLabel(AppStrings.earlier),
                      ),
                      SliverList.builder(
                        itemCount: read.length,
                        itemBuilder: (context, i) => _NotifTile(
                          notif: read[i],
                          onTap: () => _navigate(context, read[i]),
                          onFollowTap: () =>
                              notifier.toggleFollow(read[i].id),
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(child: SizedBox(height: AppDimens.vlg)),
                  ],
                ),
    );
  }

  void _navigate(BuildContext context, NotificationModel notif) {
    switch (notif.type) {
      case NotificationType.like:
      case NotificationType.comment:
        context.push(AppRoutes.postDetailPath('post_001'));
      case NotificationType.follow:
        context.push(AppRoutes.userProfilePath(notif.actor.id));
    }
  }
}

// ─── Notification Tile ────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.onTap,
    required this.onFollowTap,
  });

  final NotificationModel notif;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: !notif.isRead
            ? AppColors.primaryMuted
            : Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Type icon
            _NotifIcon(type: notif.type),
            Gap(AppDimens.md),

            // Actor avatar
            AppAvatar(
              imageUrl: notif.actor.avatarUrl,
              initials: notif.actor.initials,
              size: AvatarSize.sm,
            ),
            Gap(AppDimens.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NotifText(notif: notif),
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

            // Right side: follow button or post thumbnail
            Gap(AppDimens.md),
            if (notif.type == NotificationType.follow)
              FollowButton(
                isFollowing: notif.actor.isFollowing,
                onTap: onFollowTap,
              )
            else
              _PostThumbnail(imageUrl: notif.postImageUrl),
          ],
        ),
      ),
    );
  }
}

class _NotifIcon extends StatelessWidget {
  const _NotifIcon({required this.type});
  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = switch (type) {
      NotificationType.like => (
          AppColors.like,
          AppColors.likeBackground,
          Icons.favorite_rounded,
        ),
      NotificationType.follow => (
          AppColors.primary,
          AppColors.primaryMuted,
          Icons.person_add_rounded,
        ),
      NotificationType.comment => (
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

class _NotifText extends StatelessWidget {
  const _NotifText({required this.notif});
  final NotificationModel notif;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    String body = switch (notif.type) {
      NotificationType.like =>
        '${AppStrings.andOthers} ${AppStrings.likedYourPost}',
      NotificationType.follow => AppStrings.startedFollowingYou,
      NotificationType.comment =>
        '${AppStrings.commented} "${notif.commentText ?? ''}"',
    };

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${notif.actor.username} ',
            style: AppTextStyles.labelSmall.copyWith(color: textColor),
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

class _PostThumbnail extends StatelessWidget {
  const _PostThumbnail({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
      ),
      child: Icon(
        Icons.image_outlined,
        size: 18.w,
        color: AppColors.primary.withOpacity(0.3),
      ),
    );
  }
}
