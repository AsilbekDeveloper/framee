import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/components/shared_widgets.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/home/presentation/widgets/home_app_bar.dart';
import 'package:framee/features/notifications/presentation/providers/notifications_provider.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the app name and no badge when there is nothing unread',
      (tester) async {
    await pumpApp(
      tester,
      const HomeAppBar(),
      overrides: [hasUnreadNotificationsProvider.overrideWithValue(false)],
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
    final button = tester.widget<AppIconButton>(
      find.widgetWithIcon(AppIconButton, Icons.notifications_outlined),
    );
    expect(button.badge, isFalse);
  });

  testWidgets('shows a badge on the bell icon when there is an unread notification',
      (tester) async {
    await pumpApp(
      tester,
      const HomeAppBar(),
      overrides: [hasUnreadNotificationsProvider.overrideWithValue(true)],
    );

    final button = tester.widget<AppIconButton>(
      find.widgetWithIcon(AppIconButton, Icons.notifications_outlined),
    );
    expect(button.badge, isTrue);
  });
}
