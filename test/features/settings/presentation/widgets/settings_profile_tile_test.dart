import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/profile/domain/entities/profile.dart';
import 'package:framee/features/settings/presentation/widgets/settings_profile_tile.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Profile profile() => Profile(
        id: 'user-1',
        username: 'jane',
        displayName: 'Jane Doe',
        createdAt: DateTime(2026, 1, 1),
      );

  testWidgets('renders the display name and username', (tester) async {
    await pumpApp(
      tester,
      SettingsProfilePreviewTile(profile: profile(), onEditTap: () {}),
    );

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('@jane'), findsOneWidget);
  });

  testWidgets('tapping Edit calls onEditTap', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      SettingsProfilePreviewTile(
        profile: profile(),
        onEditTap: () => tapped = true,
      ),
    );

    await tester.tap(find.text(AppStrings.edit));
    expect(tapped, isTrue);
  });
}
