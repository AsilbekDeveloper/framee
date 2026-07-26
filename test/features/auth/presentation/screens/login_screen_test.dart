import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/features/auth/data/providers/auth_data_providers.dart';
import 'package:framee/features/auth/domain/failures/auth_failure.dart';
import 'package:framee/features/auth/presentation/screens/login_screen.dart';
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

  Future<void> pumpLogin(WidgetTester tester) => pumpApp(
        tester,
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
        ],
      );

  testWidgets('renders the sign-in form', (tester) async {
    await pumpLogin(tester);

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text(AppStrings.signIn), findsOneWidget);
    expect(find.text(AppStrings.continueWithGoogle), findsOneWidget);
  });

  testWidgets('submitting valid-looking credentials calls signIn', (tester) async {
    when(() => authRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Err(InvalidCredentialsFailure()));

    await pumpLogin(tester);

    await tester.enterText(
        find.byType(TextFormField).at(0), 'jane@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.signIn));
    await tester.pumpAndSettle();

    verify(() => authRepository.signIn(
          email: 'jane@example.com',
          password: 'secret123',
        )).called(1);
  });

  testWidgets('shows an error message when sign-in fails', (tester) async {
    when(() => authRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Err(InvalidCredentialsFailure()));

    await pumpLogin(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.signIn), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) =>
          w is Text &&
          w.style?.color != null &&
          (w.data?.isNotEmpty ?? false) &&
          w.data != AppStrings.signIn &&
          w.data != AppStrings.appName),
      findsWidgets,
    );
  });

  testWidgets('shows a loading overlay while a sign-in is in flight',
      (tester) async {
    when(() => authRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return const Err(InvalidCredentialsFailure());
    });

    await pumpLogin(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.signIn));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('tapping the Google button triggers Google sign-in',
      (tester) async {
    when(() => authRepository.signInWithGoogle()).thenAnswer(
        (_) async => const Err(UnknownAuthFailure(message: 'boom')));

    await pumpLogin(tester);
    await tester.tap(find.text(AppStrings.continueWithGoogle));
    await tester.pumpAndSettle();

    verify(() => authRepository.signInWithGoogle()).called(1);
  });
}
