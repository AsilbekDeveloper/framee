import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/auth/data/providers/auth_data_providers.dart';
import 'package:framee/features/follow/data/providers/follow_data_providers.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/follow/domain/failures/follow_failure.dart';
import 'package:framee/features/notifications/data/providers/notification_data_providers.dart';
import 'package:framee/features/notifications/domain/entities/notification.dart';
import 'package:framee/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const userId = 'user-1';

  late MockAuthRepository authRepository;
  late MockNotificationRepository notificationRepository;
  late MockFollowRepository followRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    authRepository = MockAuthRepository();
    notificationRepository = MockNotificationRepository();
    followRepository = MockFollowRepository();

    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => notificationRepository.watchNewNotifications(any()))
        .thenAnswer((_) => const Stream.empty());

    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      notificationRepositoryProvider.overrideWithValue(notificationRepository),
      followRepositoryProvider.overrideWithValue(followRepository),
      currentUserIdProvider.overrideWithValue(userId),
    ]);
    addTearDown(container.dispose);
  });

  AppNotification notif(
    String id, {
    NotificationType type = NotificationType.follow,
    FollowStatus followStatus = FollowStatus.none,
    bool isRead = false,
  }) =>
      AppNotification(
        id: id,
        type: type,
        actor: NotificationActor(
          id: 'actor-$id',
          username: 'u$id',
          displayName: 'U$id',
          followStatus: followStatus,
        ),
        createdAt: DateTime(2026, 1, 1),
        isRead: isRead,
      );

  Future<NotifFeedState> loadFeed(List<AppNotification> notifications) async {
    when(() => notificationRepository.getNotifications(
          userId: userId,
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => Ok(notifications));
    return container.read(notificationsProvider.future);
  }

  test('build loads notifications for the current user', () async {
    final feed = await loadFeed([notif('n1')]);

    expect(feed.notifications, hasLength(1));
  });

  test('markRead optimistically flips isRead and calls the repository',
      () async {
    await loadFeed([notif('n1')]);
    when(() => notificationRepository.markRead('n1'))
        .thenAnswer((_) async => const Ok(true));

    await container.read(notificationsProvider.notifier).markRead('n1');

    final feed = container.read(notificationsProvider).value!;
    expect(feed.notifications.single.isRead, isTrue);
    verify(() => notificationRepository.markRead('n1')).called(1);
  });

  test('markAllRead marks every notification read on success', () async {
    await loadFeed([notif('n1'), notif('n2', isRead: true)]);
    when(() => notificationRepository.markAllRead(userId))
        .thenAnswer((_) async => const Ok(true));

    await container.read(notificationsProvider.notifier).markAllRead();

    final feed = container.read(notificationsProvider).value!;
    expect(feed.notifications.every((n) => n.isRead), isTrue);
  });

  test('markAllRead re-fetches the feed when the server call fails',
      () async {
    await loadFeed([notif('n1')]);
    when(() => notificationRepository.markAllRead(userId))
        .thenAnswer((_) async => const Err(FollowOperationFailure()));
    when(() => notificationRepository.getNotifications(
          userId: userId,
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => Ok([notif('n1')]));

    await container.read(notificationsProvider.notifier).markAllRead();

    verify(() => notificationRepository.getNotifications(
          userId: userId,
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).called(2);
  });

  group('toggleFollow', () {
    test('follows and patches the actor status on success', () async {
      await loadFeed([notif('n1', type: NotificationType.followRequest)]);
      when(() => followRepository.followUser(
            currentUserId: userId,
            targetUserId: 'actor-n1',
          )).thenAnswer((_) async => const Ok(FollowStatus.following));

      await container
          .read(notificationsProvider.notifier)
          .toggleFollow('actor-n1', false);

      final feed = container.read(notificationsProvider).value!;
      expect(feed.notifications.single.actor.followStatus,
          FollowStatus.following);
    });

    test('unfollows and clears the actor status on success', () async {
      await loadFeed([
        notif('n1', type: NotificationType.follow, followStatus: FollowStatus.following)
      ]);
      when(() => followRepository.unfollowUser(
            currentUserId: userId,
            targetUserId: 'actor-n1',
          )).thenAnswer((_) async => const Ok(true));

      await container
          .read(notificationsProvider.notifier)
          .toggleFollow('actor-n1', true);

      final feed = container.read(notificationsProvider).value!;
      expect(feed.notifications.single.actor.followStatus, FollowStatus.none);
    });

    test('leaves the actor status untouched when the server call fails',
        () async {
      await loadFeed([notif('n1', type: NotificationType.followRequest)]);
      when(() => followRepository.followUser(
            currentUserId: userId,
            targetUserId: 'actor-n1',
          )).thenAnswer(
          (_) async => const Err(FollowOperationFailure()));

      await container
          .read(notificationsProvider.notifier)
          .toggleFollow('actor-n1', false);

      final feed = container.read(notificationsProvider).value!;
      expect(feed.notifications.single.actor.followStatus, FollowStatus.none);
    });
  });

  test('acceptFollowRequest converts the notification to a read follow',
      () async {
    await loadFeed([notif('n1', type: NotificationType.followRequest)]);
    when(() => followRepository.acceptFollowRequest(
          currentUserId: userId,
          requesterId: 'actor-n1',
        )).thenAnswer((_) async => const Ok(true));

    await container
        .read(notificationsProvider.notifier)
        .acceptFollowRequest('actor-n1');

    final feed = container.read(notificationsProvider).value!;
    final updated = feed.notifications.single;
    expect(updated.type, NotificationType.follow);
    expect(updated.isRead, isTrue);
    expect(updated.actor.followStatus, FollowStatus.following);
  });
}
