import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/settings/presentation/widgets/settings_tiles.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('SettingsToggleTile', () {
    testWidgets('renders the title, subtitle, and current value',
        (tester) async {
      await pumpApp(
        tester,
        SettingsToggleTile(
          icon: Icons.notifications,
          title: 'Push notifications',
          subtitle: 'Get notified about likes',
          value: true,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Push notifications'), findsOneWidget);
      expect(find.text('Get notified about likes'), findsOneWidget);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('toggling the switch calls onChanged with the flipped value',
        (tester) async {
      bool? newValue;
      await pumpApp(
        tester,
        SettingsToggleTile(
          icon: Icons.notifications,
          title: 'Push notifications',
          value: false,
          onChanged: (v) => newValue = v,
        ),
      );

      await tester.tap(find.byType(Switch));
      expect(newValue, isTrue);
    });
  });

  group('SettingsNavTile', () {
    testWidgets('shows a chevron and trailing text, and calls onTap',
        (tester) async {
      var tapped = false;
      await pumpApp(
        tester,
        SettingsNavTile(
          icon: Icons.language,
          title: 'Language',
          trailing: 'English',
          onTap: () => tapped = true,
        ),
      );

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('hides the chevron when onTap is null', (tester) async {
      await pumpApp(
        tester,
        const SettingsNavTile(
          icon: Icons.info,
          title: 'Version',
          trailing: '1.0.0',
          onTap: null,
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });
  });

  group('SettingsDangerTile', () {
    testWidgets('renders the title in the error color and calls onTap',
        (tester) async {
      var tapped = false;
      await pumpApp(
        tester,
        SettingsDangerTile(
          icon: Icons.delete,
          title: 'Delete account',
          onTap: () => tapped = true,
        ),
      );

      expect(find.text('Delete account'), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
