import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/auth/data/providers/auth_data_providers.dart';
import 'package:framee/features/profile/data/providers/profile_data_providers.dart';
import 'package:framee/features/profile/presentation/providers/edit_profile_provider.dart';
import 'package:framee/features/profile/presentation/providers/profile_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const userId = 'user-1';

  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;
  late ProviderContainer container;

  setUpAll(registerFallbackValues);

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();

    when(() => authRepository.currentUser).thenReturn(
      makeAuthUser(id: userId, email: 'jane@example.com', fullName: 'Jane'),
    );

    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      profileRepositoryProvider.overrideWithValue(profileRepository),
      currentUserIdProvider.overrideWithValue(userId),
    ]);
    addTearDown(container.dispose);
  });

  test('build seeds controllers from an already-loaded profile', () async {
    when(() => profileRepository.getProfile(userId, currentUserId: userId))
        .thenAnswer((_) async => Ok(makeProfile(
              id: userId,
              username: 'janedoe',
              displayName: 'Jane Doe',
              isPrivate: true,
            )));
    await container.read(profileProvider(null).future);

    final notifier = container.read(editProfileProvider.notifier);

    expect(notifier.usernameController.text, 'janedoe');
    expect(notifier.displayNameController.text, 'Jane Doe');
    expect(notifier.emailController.text, 'jane@example.com');
    expect(container.read(editProfileProvider).isPrivate, isTrue);
  });

  test(
      'falls back to the auth user, then updates reactively once the profile loads',
      () async {
    when(() => profileRepository.getProfile(userId, currentUserId: userId))
        .thenAnswer((_) async => Ok(makeProfile(
              id: userId,
              username: 'janedoe',
              displayName: 'Jane Doe',
            )));

    final notifier = container.read(editProfileProvider.notifier);
    // Profile hasn't resolved yet — falls back to the auth user's email prefix.
    expect(notifier.usernameController.text, 'jane');
    expect(notifier.displayNameController.text, 'Jane');

    await container.read(profileProvider(null).future);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.usernameController.text, 'janedoe');
  });

  test('onBioChanged tracks the bio controller length', () async {
    when(() => profileRepository.getProfile(userId, currentUserId: userId))
        .thenAnswer((_) async => Ok(makeProfile(id: userId)));
    await container.read(profileProvider(null).future);

    final notifier = container.read(editProfileProvider.notifier);
    notifier.bioController.text = 'hello';
    notifier.onBioChanged();

    expect(container.read(editProfileProvider).bioLength, 5);
  });

  test('setPrivate updates state and stops future profile-load overrides',
      () async {
    when(() => profileRepository.getProfile(userId, currentUserId: userId))
        .thenAnswer((_) async => Ok(makeProfile(id: userId)));
    await container.read(profileProvider(null).future);

    container.read(editProfileProvider.notifier).setPrivate(true);

    expect(container.read(editProfileProvider).isPrivate, isTrue);
  });

  group('save', () {
    test('updates state and propagates the new profile on success', () async {
      when(() => profileRepository.getProfile(userId, currentUserId: userId))
          .thenAnswer((_) async => Ok(makeProfile(id: userId)));
      await container.read(profileProvider(null).future);
      await container.read(profileProvider(userId).future);

      final notifier = container.read(editProfileProvider.notifier);
      notifier.usernameController.text = 'newname';
      notifier.displayNameController.text = 'New Name';

      when(() => profileRepository.isUsernameAvailable(
            any(),
            excludeUserId: any(named: 'excludeUserId'),
          )).thenAnswer((_) async => const Ok(true));
      final saved = makeProfile(
        id: userId,
        username: 'newname',
        displayName: 'New Name',
      );
      when(() => profileRepository.updateProfile(any()))
          .thenAnswer((_) async => Ok(saved));

      await notifier.save();

      expect(container.read(editProfileProvider).savedSuccessfully, isTrue);
      expect(container.read(editProfileProvider).isSaving, isFalse);
      expect(container.read(profileProvider(null)).value!.username, 'newname');
      expect(
          container.read(profileProvider(userId)).value!.username, 'newname');
    });

    test('sets an error message when the username is already taken',
        () async {
      when(() => profileRepository.getProfile(userId, currentUserId: userId))
          .thenAnswer((_) async => Ok(makeProfile(id: userId)));
      await container.read(profileProvider(null).future);

      final notifier = container.read(editProfileProvider.notifier);
      notifier.usernameController.text = 'taken';
      notifier.displayNameController.text = 'Name';

      when(() => profileRepository.isUsernameAvailable(
            any(),
            excludeUserId: any(named: 'excludeUserId'),
          )).thenAnswer((_) async => const Ok(false));

      await notifier.save();

      expect(container.read(editProfileProvider).errorMessage, isNotNull);
      expect(container.read(editProfileProvider).savedSuccessfully, isFalse);
      verifyNever(() => profileRepository.updateProfile(any()));
    });
  });
}
