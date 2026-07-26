import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/search/domain/entities/search_result.dart';
import 'package:framee/features/search/presentation/widgets/search_results.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  SearchUser user(
    String id, {
    String username = 'jane',
    String displayName = 'Jane Doe',
    bool isVerified = false,
    bool isPrivate = false,
    int followersCount = 5,
  }) =>
      SearchUser(
        id: id,
        username: username,
        displayName: displayName,
        isVerified: isVerified,
        isPrivate: isPrivate,
        followersCount: followersCount,
      );

  testWidgets('renders the section label with the result count',
      (tester) async {
    await pumpApp(
      tester,
      SearchResults(
        results: [user('u1'), user('u2')],
        onUserTap: (_) {},
        onFollowTap: (_) {},
      ),
    );

    expect(
        find.textContaining('${AppStrings.people} · 2'.toUpperCase()),
        findsOneWidget);
  });

  testWidgets('shows verified and private badges', (tester) async {
    await pumpApp(
      tester,
      SearchResults(
        results: [user('u1', isVerified: true, isPrivate: true)],
        onUserTap: (_) {},
        onFollowTap: (_) {},
      ),
    );

    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });

  testWidgets('tapping a row calls onUserTap with that user\'s id',
      (tester) async {
    String? tappedId;
    await pumpApp(
      tester,
      SearchResults(
        results: [user('u1')],
        onUserTap: (id) => tappedId = id,
        onFollowTap: (_) {},
      ),
    );

    await tester.tap(find.byType(InkWell));
    expect(tappedId, 'u1');
  });

  testWidgets(
      'tapping the follow button calls onFollowTap without triggering onUserTap',
      (tester) async {
    String? followedId;
    var userTapped = false;
    await pumpApp(
      tester,
      SearchResults(
        results: [user('u1')],
        onUserTap: (_) => userTapped = true,
        onFollowTap: (id) => followedId = id,
      ),
    );

    await tester.tap(find.byType(GestureDetector).last);
    expect(followedId, 'u1');
    expect(userTapped, isFalse);
  });
}
