import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/auth/data/providers/auth_data_providers.dart';
import 'package:framee/features/auth/domain/failures/auth_failure.dart';
import 'package:framee/features/settings/presentation/widgets/change_password_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
  });

  Future<void> pumpSheet(WidgetTester tester) => pumpApp(
        tester,
        const ChangePasswordSheet(),
        overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
      );

  testWidgets('renders both password fields and the save button',
      (tester) async {
    await pumpSheet(tester);

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text(AppStrings.save), findsOneWidget);
  });

  testWidgets('shows an error when a field is left empty', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text(AppStrings.save));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.fillAllFields), findsOneWidget);
    verifyNever(() => authRepository.updatePassword(any()));
  });

  testWidgets('shows an error when the passwords do not match',
      (tester) async {
    await pumpSheet(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'password1');
    await tester.enterText(find.byType(TextFormField).at(1), 'password2');
    await tester.tap(find.text(AppStrings.save));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.passwordMismatch), findsOneWidget);
    verifyNever(() => authRepository.updatePassword(any()));
  });

  testWidgets('surfaces the repository failure message', (tester) async {
    when(() => authRepository.updatePassword(any())).thenAnswer(
        (_) async => const Err(UnknownAuthFailure(message: 'boom')));

    await pumpSheet(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'password1');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.text(AppStrings.save));
    await tester.pumpAndSettle();

    verify(() => authRepository.updatePassword('password1')).called(1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
