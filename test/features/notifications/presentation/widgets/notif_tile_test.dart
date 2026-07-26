import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/components/app_avatar.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/notifications/domain/entities/notification.dart';
import 'package:framee/features/notifications/presentation/widgets/notif_tile.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  AppNotification notif({
    NotificationType type = NotificationType.like,
    FollowStatus followStatus = FollowStatus.none,
    bool isRead = false,
    String? postImageUrl,
  }) =>
      AppNotification(
        id: 'n1',
        type: type,
        actor: NotificationActor(
          id: 'actor-1',
          username: 'jane',
          displayName: 'Jane',
          followStatus: followStatus,
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: isRead,
        postImageUrl: postImageUrl,
      );

  testWidgets('renders the notification text for a like', (tester) async {
    await pumpApp(
      tester,
      NotifTile(
          notif: notif(), onTap: () {}, onActorTap: () {}, onFollowTap: () {}),
    );

    expect(find.textContaining('jane', findRichText: true), findsOneWidget);
    expect(
        find.textContaining(AppStrings.likedYourPost, findRichText: true),
        findsOneWidget);
  });

  testWidgets('tapping the tile calls onTap', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      NotifTile(
        notif: notif(),
        onTap: () => tapped = true,
        onActorTap: () {},
        onFollowTap: () {},
      ),
    );

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });

  testWidgets('tapping the avatar calls onActorTap, not onTap', (tester) async {
    var tapped = false;
    var actorTapped = false;
    await pumpApp(
      tester,
      NotifTile(
        notif: notif(),
        onTap: () => tapped = true,
        onActorTap: () => actorTapped = true,
        onFollowTap: () {},
      ),
    );

    await tester.tap(find.byType(AppAvatar));
    expect(actorTapped, isTrue);
    expect(tapped, isFalse);
  });

  testWidgets('tapping the username calls onActorTap', (tester) async {
    var actorTapped = false;
    await pumpApp(
      tester,
      NotifTile(
        notif: notif(),
        onTap: () {},
        onActorTap: () => actorTapped = true,
        onFollowTap: () {},
      ),
    );

    await tester.tapAt(
      tester.getTopLeft(find.textContaining('jane', findRichText: true)) +
          const Offset(4, 8),
    );
    expect(actorTapped, isTrue);
  });

  testWidgets('a follow-request notification shows an Accept button',
      (tester) async {
    var accepted = false;
    await pumpApp(
      tester,
      NotifTile(
        notif: notif(type: NotificationType.followRequest),
        onTap: () {},
        onActorTap: () {},
        onFollowTap: () => accepted = true,
      ),
    );

    expect(find.text(AppStrings.accept), findsOneWidget);
    await tester.tap(find.text(AppStrings.accept));
    expect(accepted, isTrue);
  });

  testWidgets('a follow notification shows Requested for a pending request',
      (tester) async {
    await pumpApp(
      tester,
      NotifTile(
        notif: notif(
          type: NotificationType.follow,
          followStatus: FollowStatus.requested,
        ),
        onTap: () {},
        onActorTap: () {},
        onFollowTap: () {},
      ),
    );

    expect(find.text(AppStrings.requested), findsOneWidget);
  });

  testWidgets('tapping the follow button calls onFollowTap', (tester) async {
    var followed = false;
    await pumpApp(
      tester,
      NotifTile(
        notif: notif(type: NotificationType.follow),
        onTap: () {},
        onActorTap: () {},
        onFollowTap: () => followed = true,
      ),
    );

    await tester.tap(find.byType(GestureDetector).last);
    expect(followed, isTrue);
  });

  testWidgets('a comment notification shows a post thumbnail placeholder',
      (tester) async {
    await pumpApp(
      tester,
      NotifTile(
        notif: notif(type: NotificationType.comment),
        onTap: () {},
        onActorTap: () {},
        onFollowTap: () {},
      ),
    );

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });
}
