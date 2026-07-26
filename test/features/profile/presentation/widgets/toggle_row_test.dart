import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/profile/presentation/widgets/toggle_row.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders title, subtitle, and current value', (tester) async {
    await pumpApp(
      tester,
      ToggleRow(
        title: 'Private account',
        subtitle: 'Only approved followers can see your posts',
        value: true,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Private account'), findsOneWidget);
    expect(find.text('Only approved followers can see your posts'),
        findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('toggling calls onChanged with the flipped value',
      (tester) async {
    bool? newValue;
    await pumpApp(
      tester,
      ToggleRow(
        title: 'Private account',
        subtitle: 'sub',
        value: false,
        onChanged: (v) => newValue = v,
      ),
    );

    await tester.tap(find.byType(Switch));
    expect(newValue, isTrue);
  });
}
