import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/auth/presentation/widgets/forgot_password_dialog.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('pre-fills the email field with the initial email',
      (tester) async {
    await pumpApp(
      tester,
      ForgotPasswordDialog(initialEmail: 'jane@example.com', onSend: (_) {}),
    );

    expect(find.text(AppStrings.resetPassword), findsOneWidget);
    expect(find.text(AppStrings.cancel), findsOneWidget);
    expect(find.text(AppStrings.send), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'jane@example.com',
    );
  });
}
