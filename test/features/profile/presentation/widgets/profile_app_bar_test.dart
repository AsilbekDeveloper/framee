import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/profile/presentation/widgets/profile_app_bar.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('own profile shows a create button and a settings button',
      (tester) async {
    var created = false;
    var settingsTapped = false;
    await pumpApp(
      tester,
      ProfileAppBar(
        username: 'jane',
        isOwnProfile: true,
        onSettingsTap: () => settingsTapped = true,
        onCreateTap: () => created = true,
      ),
    );

    expect(find.text('jane'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(created, isTrue);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    expect(settingsTapped, isTrue);
  });

  testWidgets(
      'someone else\'s profile shows a back button and no settings button',
      (tester) async {
    var backTapped = false;
    await pumpApp(
      tester,
      ProfileAppBar(
        username: 'bob',
        isOwnProfile: false,
        onCreateTap: () {},
        onBackTap: () => backTapped = true,
      ),
    );

    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    expect(backTapped, isTrue);
  });
}
