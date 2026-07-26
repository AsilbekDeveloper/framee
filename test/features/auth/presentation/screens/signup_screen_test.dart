import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/auth/data/providers/auth_data_providers.dart';
import 'package:framee/features/auth/domain/failures/auth_failure.dart';
import 'package:framee/features/auth/presentation/screens/signup_screen.dart';
import 'package:framee/features/profile/data/providers/profile_data_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;

  setUpAll(registerFallbackValues);

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    when(() => authRepository.currentUser).thenReturn(null);
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  Future<void> pumpSignUp(WidgetTester tester) => pumpApp(
        tester,
        const SignUpScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
        ],
      );

  testWidgets('renders the sign-up form', (tester) async {
    await pumpSignUp(tester);

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.widgetWithText(ElevatedButton, AppStrings.createAccount),
        findsOneWidget);
  });

  testWidgets('submitting calls signUp with the entered values', (tester) async {
    when(() => authRepository.signUp(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async =>
        const Err(EmailAlreadyInUseFailure()));

    await pumpSignUp(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'jane@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password1');
    await tester.enterText(find.byType(TextFormField).at(3), 'password1');
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.createAccount));
    await tester.pumpAndSettle();

    verify(() => authRepository.signUp(
          fullName: 'Jane Doe',
          email: 'jane@example.com',
          password: 'password1',
        )).called(1);
  });

  testWidgets('shows an error message when sign-up fails', (tester) async {
    when(() => authRepository.signUp(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async =>
        const Err(EmailAlreadyInUseFailure()));

    await pumpSignUp(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'jane@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password1');
    await tester.enterText(find.byType(TextFormField).at(3), 'password1');
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.createAccount));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.bySigningUp), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
      'shows the email-confirmation dialog when the server requires it',
      (tester) async {
    when(() => authRepository.signUp(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Ok(null));

    await pumpSignUp(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'jane@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password1');
    await tester.enterText(find.byType(TextFormField).at(3), 'password1');
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.createAccount));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(AppStrings.confirmEmailTitle), findsOneWidget);
  });

  testWidgets('tapping the Google button triggers Google sign-in',
      (tester) async {
    when(() => authRepository.signInWithGoogle()).thenAnswer(
        (_) async => const Err(UnknownAuthFailure(message: 'boom')));

    await pumpSignUp(tester);
    await tester.tap(find.text(AppStrings.continueWithGoogle));
    await tester.pumpAndSettle();

    verify(() => authRepository.signInWithGoogle()).called(1);
  });
}
