import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/features/onboarding/presentation/widgets/setup_header.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the setup title and subtitle', (tester) async {
    await pumpApp(tester, const SetupHeader());

    expect(find.text(AppStrings.setUpProfile), findsOneWidget);
    expect(find.text(AppStrings.setUpProfileSub), findsOneWidget);
  });
}
