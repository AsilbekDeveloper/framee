import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/profile/presentation/widgets/followers_list.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  FollowUser user(
    String id, {
    String username = 'jane',
    String displayName = 'Jane Doe',
    bool isVerified = false,
    FollowStatus followStatus = FollowStatus.none,
  }) =>
      FollowUser(
        id: id,
        username: username,
        displayName: displayName,
        isVerified: isVerified,
        followStatus: followStatus,
      );

  testWidgets('shows an empty state when there are no users', (tester) async {
    await pumpApp(
      tester,
      FollowerUserList(users: const [], onUserTap: (_) {}, onFollowToggle: (_) {}),
    );

    expect(find.text(AppStrings.noResults), findsOneWidget);
  });

  testWidgets('renders a row for each user', (tester) async {
    await pumpApp(
      tester,
      FollowerUserList(
        users: [user('u1', displayName: 'Jane Doe', username: 'jane')],
        onUserTap: (_) {},
        onFollowToggle: (_) {},
      ),
    );

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('@jane'), findsOneWidget);
  });

  testWidgets('shows a verified badge for verified users', (tester) async {
    await pumpApp(
      tester,
      FollowerUserList(
        users: [user('u1', isVerified: true)],
        onUserTap: (_) {},
        onFollowToggle: (_) {},
      ),
    );

    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });

  testWidgets('shows Requested for a pending follow request', (tester) async {
    await pumpApp(
      tester,
      FollowerUserList(
        users: [user('u1', followStatus: FollowStatus.requested)],
        onUserTap: (_) {},
        onFollowToggle: (_) {},
      ),
    );

    expect(find.text(AppStrings.requested), findsOneWidget);
  });

  testWidgets('tapping a row calls onUserTap with that user\'s id',
      (tester) async {
    String? tappedId;
    await pumpApp(
      tester,
      FollowerUserList(
        users: [user('u1')],
        onUserTap: (id) => tappedId = id,
        onFollowToggle: (_) {},
      ),
    );

    await tester.tap(find.byType(InkWell));
    expect(tappedId, 'u1');
  });

  testWidgets(
      'tapping the follow button calls onFollowToggle without triggering onUserTap',
      (tester) async {
    String? toggledId;
    var userTapped = false;
    await pumpApp(
      tester,
      FollowerUserList(
        users: [user('u1')],
        onUserTap: (_) => userTapped = true,
        onFollowToggle: (id) => toggledId = id,
      ),
    );

    await tester.tap(find.byType(GestureDetector).last);
    expect(toggledId, 'u1');
    expect(userTapped, isFalse,
        reason: 'the follow button tap must not bubble to the row tap');
  });
}
