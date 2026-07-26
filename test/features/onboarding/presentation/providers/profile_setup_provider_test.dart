import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/onboarding/presentation/providers/profile_setup_provider.dart';
import 'package:framee/features/profile/data/providers/profile_data_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const userId = 'user-1';

  late MockProfileRepository profileRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    profileRepository = MockProfileRepository();
    container = ProviderContainer(overrides: [
      profileRepositoryProvider.overrideWithValue(profileRepository),
      currentUserIdProvider.overrideWithValue(userId),
    ]);
    addTearDown(container.dispose);
  });

  test('onUsernameChanged checks availability after the debounce window',
      () async {
    when(() => profileRepository.isUsernameAvailable('janedoe',
            excludeUserId: userId))
        .thenAnswer((_) async => const Ok(true));

    final notifier = container.read(profileSetupProvider.notifier);
    notifier.onUsernameChanged('janedoe');

    expect(container.read(profileSetupProvider).isUsernameAvailable, isNull);
    verifyNever(() => profileRepository.isUsernameAvailable(any(),
        excludeUserId: any(named: 'excludeUserId')));

    await Future<void>.delayed(const Duration(milliseconds: 450));

    expect(container.read(profileSetupProvider).isUsernameAvailable, isTrue);
  });

  test('onUsernameChanged skips the check for a malformed username',
      () async {
    final notifier = container.read(profileSetupProvider.notifier);
    notifier.onUsernameChanged('a');

    await Future<void>.delayed(const Duration(milliseconds: 450));

    expect(container.read(profileSetupProvider).isUsernameAvailable, isNull);
    verifyNever(() => profileRepository.isUsernameAvailable(any(),
        excludeUserId: any(named: 'excludeUserId')));
  });

  test('onBioChanged tracks the bio text length', () {
    final notifier = container.read(profileSetupProvider.notifier);

    notifier.onBioChanged('hello world');

    expect(container.read(profileSetupProvider).bioLength, 11);
  });

  group('save', () {
    test('marks the state saved on success', () async {
      when(() => profileRepository.isUsernameAvailable(any(),
              excludeUserId: any(named: 'excludeUserId')))
          .thenAnswer((_) async => const Ok(true));
      when(() => profileRepository.updateProfile(any())).thenAnswer(
        (_) async => Ok(makeProfile(id: userId, username: 'janedoe')),
      );

      await container.read(profileSetupProvider.notifier).save(
            username: 'janedoe',
            displayName: 'Jane Doe',
            bio: '',
            website: '',
          );

      final state = container.read(profileSetupProvider);
      expect(state.isSaved, isTrue);
      expect(state.isSaving, isFalse);
    });

    test('sets an error message when the username is taken', () async {
      when(() => profileRepository.isUsernameAvailable(any(),
              excludeUserId: any(named: 'excludeUserId')))
          .thenAnswer((_) async => const Ok(false));

      await container.read(profileSetupProvider.notifier).save(
            username: 'taken',
            displayName: 'Jane Doe',
            bio: '',
            website: '',
          );

      final state = container.read(profileSetupProvider);
      expect(state.isSaved, isFalse);
      expect(state.errorMessage, isNotNull);
      verifyNever(() => profileRepository.updateProfile(any()));
    });

    test('propagates a validation failure for an empty display name',
        () async {
      await container.read(profileSetupProvider.notifier).save(
            username: 'janedoe',
            displayName: '   ',
            bio: '',
            website: '',
          );

      final state = container.read(profileSetupProvider);
      expect(state.errorMessage, isNotNull);
      verifyNever(() => profileRepository.isUsernameAvailable(any(),
          excludeUserId: any(named: 'excludeUserId')));
    });
  });
}
