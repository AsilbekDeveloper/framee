import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../../core/router/app_router.dart';
import '../../../follow/domain/entities/follow.dart';
import '../../domain/entities/notification.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(AppStrings.notifications),
        actions: [
          notifAsync.whenOrNull(
            data: (list) {
              final hasUnread = list.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: notifier.markAllRead,
                child: Text(
                  AppStrings.markAllRead,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary),
                ),
              );
            },
          ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: notifAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48.w, color: AppColors.error),
              Gap(AppDimens.vmd),
              Text(e.toString(), textAlign: TextAlign.center),
              Gap(AppDimens.vmd),
              AppButton(
                label: AppStrings.retry,
                onPressed: notifier.refresh,
                variant: AppButtonVariant.outline,
              ),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: AppStrings.noNotifications,
              subtitle: AppStrings.noNotificationsSub,
            );
          }

          final unread = notifications.where((n) => !n.isRead).toList();
          final read = notifications.where((n) => n.isRead).toList();

          return CustomScrollView(
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
                        notifier.acceptFollowRequest(unread[i].actor.id),
                  ),
                ),
              ],
              if (read.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: SectionLabel(AppStrings.earlier),
                ),
                SliverList.builder(
                  itemCount: read.length,
                  itemBuilder: (context, i) => _NotifTile(
                    notif: read[i],
                    onTap: () => _navigate(context, read[i]),
                    onFollowTap: () =>
                        notifier.acceptFollowRequest(read[i].actor.id),
                  ),
                ),
              ],
              SliverToBoxAdapter(child: SizedBox(height: AppDimens.vlg)),
            ],
          );
        },
      ),
    );
  }

  void _navigate(BuildContext context, AppNotification notif) {
    switch (notif.type) {
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.mention:
        if (notif.postId != null) {
          context.push(AppRoutes.postDetailPath(notif.postId!));
        }
      case NotificationType.follow:
      case NotificationType.followRequest:
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

  final AppNotification notif;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: !notif.isRead ? AppColors.primaryMuted : Colors.transparent,
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

            Gap(AppDimens.md),

            // Right side: follow/accept button or post thumbnail
            if (notif.type == NotificationType.followRequest)
              _AcceptButton(onTap: onFollowTap)
            else if (notif.type == NotificationType.follow)
              FollowButton(
                isFollowing:
                    notif.actor.followStatus == FollowStatus.following,
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

// ─── Notif Icon ───────────────────────────────────────────────────────────────

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

// ─── Notif Text ───────────────────────────────────────────────────────────────

class _NotifText extends StatelessWidget {
  const _NotifText({required this.notif});
  final AppNotification notif;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final body = switch (notif.type) {
      NotificationType.like => AppStrings.likedYourPost,
      NotificationType.follow => AppStrings.startedFollowingYou,
      NotificationType.followRequest => 'wants to follow you',
      NotificationType.comment => 'commented on your post',
      NotificationType.mention => 'mentioned you in a comment',
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

// ─── Accept Button ────────────────────────────────────────────────────────────

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onTap});
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
          'Accept',
          style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Post Thumbnail ───────────────────────────────────────────────────────────

class _PostThumbnail extends StatelessWidget {
  const _PostThumbnail({this.imageUrl});
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
                placeholder: (_, _) => _FallbackThumbnail(
                    isDark: isDark, size: size),
                errorWidget: (_, _, _) => _FallbackThumbnail(
                    isDark: isDark, size: size),
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
