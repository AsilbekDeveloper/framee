import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../follow/domain/entities/follow.dart';
import '../../domain/entities/notification.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notif_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppStrings.notifications),
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
            return EmptyState(
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
                  itemBuilder: (context, i) => NotifTile(
                    notif: unread[i],
                    onTap: () {
                      notifier.markRead(unread[i].id);
                      _navigate(context, unread[i]);
                    },
                    onFollowTap: () => _onFollowTap(notifier, unread[i]),
                  ),
                ),
              ],
              if (read.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionLabel(AppStrings.earlier),
                ),
                SliverList.builder(
                  itemCount: read.length,
                  itemBuilder: (context, i) => NotifTile(
                    notif: read[i],
                    onTap: () => _navigate(context, read[i]),
                    onFollowTap: () => _onFollowTap(notifier, read[i]),
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

  void _onFollowTap(NotificationsNotifier notifier, AppNotification notif) {
    if (notif.type == NotificationType.followRequest) {
      notifier.acceptFollowRequest(notif.actor.id);
    } else {
      final isFollowing = notif.actor.followStatus == FollowStatus.following;
      notifier.toggleFollow(notif.actor.id, isFollowing);
    }
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
