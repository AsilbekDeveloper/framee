import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/auth/data/providers/auth_data_providers.dart';
import 'package:framee/features/auth/domain/failures/auth_failure.dart';
import 'package:framee/features/auth/presentation/providers/auth_provider.dart';
import 'package:framee/features/profile/data/providers/profile_data_providers.dart';
import 'package:framee/features/search/data/providers/search_data_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();

    when(() => authRepository.currentUser).thenReturn(null);
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => profileRepository.clearFcmToken(any()))
        .thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      profileRepositoryProvider.overrideWithValue(profileRepository),
    ]);
    addTearDown(container.dispose);
  });

  group('AuthNotifier.signIn', () {
    // A successful signIn is deliberately not exercised here: on success the
    // notifier calls FcmService.instance, a Firebase singleton with no DI
    // seam, which throws synchronously outside a real Firebase.initializeApp
    // context. Covering that path would require platform-channel mocking of
    // firebase_core/firebase_messaging, not a change to make on the side
    // while writing tests. The failure branch below never reaches that line.
    test('surfaces the failure message and clears loading on error',
        () async {
      when(() => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
          (_) async => const Err(InvalidCredentialsFailure()));

      await container.read(authProvider.notifier).signIn(
            email: 'test@example.com',
            password: 'wrong',
          );

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('AuthNotifier.signUp', () {
    test('sets awaitingEmailConfirmation when the repository returns null',
        () async {
      when(() => authRepository.signUp(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Ok(null));

      await container.read(authProvider.notifier).signUp(
            fullName: 'Test User',
            email: 'test@example.com',
            password: 'password123',
            confirmPassword: 'password123',
          );

      final state = container.read(authProvider);
      expect(state.awaitingEmailConfirmation, isTrue);
      expect(state.isAuthenticated, isFalse);
    });

    test('signs the user in immediately when no confirmation is required',
        () async {
      final user = makeAuthUser();
      when(() => authRepository.signUp(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Ok(user));

      await container.read(authProvider.notifier).signUp(
            fullName: 'Test User',
            email: 'test@example.com',
            password: 'password123',
            confirmPassword: 'password123',
          );

      expect(container.read(authProvider).isAuthenticated, isTrue);
    });
  });

  group('AuthNotifier.clearError', () {
    test('clears a pending error message', () async {
      when(() => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
          (_) async => const Err(InvalidCredentialsFailure()));
      final notifier = container.read(authProvider.notifier);
      await notifier.signIn(email: 'a@b.com', password: 'wrong');
      expect(container.read(authProvider).errorMessage, isNotNull);

      notifier.clearError();

      expect(container.read(authProvider).errorMessage, isNull);
    });
  });

  group('AuthNotifier.signOut', () {
    test('clears the FCM token and resets state', () async {
      // Seeded via the currentUser getter (read once in build()) rather than
      // a real signIn() call, which would hit the Firebase-coupled success
      // branch described above.
      when(() => authRepository.currentUser)
          .thenReturn(makeAuthUser(id: 'user-1'));
      // signOut() invalidates searchProvider (among others) to clear
      // user-scoped state. In debug/test mode Riverpod's invalidate() path
      // asserts against the target provider, which builds SearchNotifier as
      // a side effect; since currentUserIdProvider is non-null here, its
      // build() schedules a microtask that fetches explore posts. Stub the
      // repository it eventually reaches so that microtask resolves cleanly
      // instead of racing the container's disposal below.
      final searchRepository = MockSearchRepository();
      when(() => searchRepository.getExplorePosts(
            currentUserId: any(named: 'currentUserId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => const Ok([]));
      final signedInContainer = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        searchRepositoryProvider.overrideWithValue(searchRepository),
        currentUserIdProvider.overrideWithValue('user-1'),
      ]);
      addTearDown(signedInContainer.dispose);
      when(() => authRepository.signOut())
          .thenAnswer((_) async => const Ok(null));

      await signedInContainer.read(authProvider.notifier).signOut();
      // Let SearchNotifier's scheduled microtask finish before teardown
      // disposes the container.
      await Future<void>.delayed(Duration.zero);

      verify(() => profileRepository.clearFcmToken('user-1')).called(1);
      expect(signedInContainer.read(authProvider).isAuthenticated, isFalse);
    });

    test('still resets local state when the server call fails', () async {
      when(() => authRepository.signOut()).thenAnswer(
          (_) async => const Err(UnknownAuthFailure(message: 'boom')));

      await container.read(authProvider.notifier).signOut();

      expect(container.read(authProvider).isAuthenticated, isFalse);
    });
  });

  group('AuthNotifier.deleteAccount', () {
    test('resets state on success', () async {
      when(() => authRepository.deleteAccount())
          .thenAnswer((_) async => const Ok(null));

      final result =
          await container.read(authProvider.notifier).deleteAccount();

      expect(result.isOk, isTrue);
      expect(container.read(authProvider).isAuthenticated, isFalse);
    });

    test('leaves state untouched when the server rejects the deletion',
        () async {
      // Seeded via the currentUser getter rather than a real signIn() call —
      // see the note in the signIn group above.
      when(() => authRepository.currentUser).thenReturn(makeAuthUser());
      final signedInContainer = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ]);
      addTearDown(signedInContainer.dispose);
      expect(signedInContainer.read(authProvider).isAuthenticated, isTrue);

      when(() => authRepository.deleteAccount()).thenAnswer(
          (_) async => const Err(UnknownAuthFailure(message: 'boom')));

      final result =
          await signedInContainer.read(authProvider.notifier).deleteAccount();

      expect(result.isErr, isTrue);
      expect(signedInContainer.read(authProvider).isAuthenticated, isTrue,
          reason: 'a failed deletion must not sign the user out locally');
    });
  });
}
