import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/core/components/follow_button.dart';
import 'package:framee/features/profile/domain/entities/profile.dart';
import 'package:framee/features/profile/presentation/widgets/profile_info.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Profile profile({
    String displayName = 'Jane Doe',
    int postsCount = 3,
    int followersCount = 10,
    int followingCount = 5,
    bool isFollowing = false,
    bool isRequested = false,
  }) =>
      Profile(
        id: 'user-1',
        username: 'jane',
        displayName: displayName,
        postsCount: postsCount,
        followersCount: followersCount,
        followingCount: followingCount,
        isFollowing: isFollowing,
        isRequested: isRequested,
        createdAt: DateTime(2026, 1, 1),
      );

  Widget buildInfo({
    required Profile p,
    required bool isOwnProfile,
    VoidCallback? onFollowersTap,
    VoidCallback? onFollowingTap,
    VoidCallback? onEditTap,
    VoidCallback? onFollowTap,
  }) =>
      ProfileInfo(
        profile: p,
        isOwnProfile: isOwnProfile,
        onFollowersTap: onFollowersTap ?? () {},
        onFollowingTap: onFollowingTap ?? () {},
        onEditTap: onEditTap ?? () {},
        onShareTap: () {},
        onCopyLinkTap: () {},
        onFollowTap: onFollowTap ?? () {},
      );

  testWidgets('renders the display name and stat counts', (tester) async {
    await pumpApp(
      tester,
      buildInfo(p: profile(), isOwnProfile: true),
    );

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('own profile shows Edit Profile instead of a follow button',
      (tester) async {
    var edited = false;
    await pumpApp(
      tester,
      buildInfo(p: profile(), isOwnProfile: true, onEditTap: () => edited = true),
    );

    expect(find.text(AppStrings.editProfile), findsOneWidget);
    await tester.tap(find.text(AppStrings.editProfile));
    expect(edited, isTrue);
  });

  testWidgets('someone else\'s profile shows a follow button', (tester) async {
    var followed = false;
    await pumpApp(
      tester,
      buildInfo(
        p: profile(),
        isOwnProfile: false,
        onFollowTap: () => followed = true,
      ),
    );

    expect(find.text(AppStrings.editProfile), findsNothing);
    await tester.tap(find.byType(FollowButton));
    expect(followed, isTrue);
  });

  testWidgets('shows Requested for a pending follow request', (tester) async {
    await pumpApp(
      tester,
      buildInfo(
        p: profile(isRequested: true),
        isOwnProfile: false,
      ),
    );

    expect(find.text(AppStrings.requested), findsOneWidget);
  });

  testWidgets('tapping the followers stat calls onFollowersTap',
      (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      buildInfo(
          p: profile(), isOwnProfile: true, onFollowersTap: () => tapped = true),
    );

    await tester.tap(find.text(AppStrings.followersLabel));
    expect(tapped, isTrue);
  });
}
