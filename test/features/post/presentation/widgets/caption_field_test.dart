import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/post/presentation/widgets/caption_field.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the char count and calls onChanged while typing',
      (tester) async {
    final controller = TextEditingController();
    String? changed;
    await pumpApp(
      tester,
      CaptionField(
        controller: controller,
        onChanged: (v) => changed = v,
        isDark: false,
        charCount: 0,
      ),
    );

    expect(find.text('0 / 2200'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'hello');
    expect(changed, 'hello');
  });

  testWidgets('shows the current char count out of the max', (tester) async {
    await pumpApp(
      tester,
      CaptionField(
        controller: TextEditingController(),
        onChanged: (_) {},
        isDark: false,
        charCount: 150,
      ),
    );

    expect(find.text('150 / 2200'), findsOneWidget);
  });
}
