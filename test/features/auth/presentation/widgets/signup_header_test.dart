import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/auth/presentation/widgets/signup_header.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the create-account title and subtitle',
      (tester) async {
    await pumpApp(tester, const SignUpHeader());

    expect(find.text(AppStrings.createAccount), findsOneWidget);
    expect(find.text(AppStrings.joinFramee), findsOneWidget);
  });
}
