import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/errors/failure_message.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../profile/data/providers/profile_data_providers.dart';
import '../../../profile/domain/entities/profile.dart';

class ProfileSetupState {
  const ProfileSetupState({
    this.avatarLocalPath,
    this.isUsernameAvailable,
    this.bioLength = 0,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
  });

  final String? avatarLocalPath;
  final bool? isUsernameAvailable;
  final int bioLength;
  final bool isSaving;
  /// When true, triggers navigation to the next screen.
  final bool isSaved;
  final String? errorMessage;

  ProfileSetupState copyWith({
    String? avatarLocalPath,
    bool? isUsernameAvailable,
    int? bioLength,
    bool? isSaving,
    bool? isSaved,
    String? errorMessage,
    bool clearError = false,
    bool clearUsernameStatus = false,
  }) =>
      ProfileSetupState(
        avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
        isUsernameAvailable: clearUsernameStatus
            ? null
            : (isUsernameAvailable ?? this.isUsernameAvailable),
        bioLength: bioLength ?? this.bioLength,
        isSaving: isSaving ?? this.isSaving,
        isSaved: isSaved ?? this.isSaved,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  final _picker = ImagePicker();

  // Mirrors UpdateProfileUseCase: 3–30 chars, letters/digits/._ only.
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,30}$');

  Timer? _usernameDebounce;
  String? _lastUsernameQuery;

  @override
  ProfileSetupState build() {
    ref.onDispose(() => _usernameDebounce?.cancel());
    return const ProfileSetupState();
  }

  void onUsernameChanged(String value) {
    final username = value.trim();
    _usernameDebounce?.cancel();

    // Only check well-formed usernames; otherwise hide the indicator (a format
    // error still surfaces on save). The two-state UI has no "invalid" icon.
    if (!_usernameRegex.hasMatch(username)) {
      _lastUsernameQuery = null;
      state = state.copyWith(clearUsernameStatus: true);
      return;
    }

    // Clear the previous result while the debounced check is pending.
    state = state.copyWith(clearUsernameStatus: true);
    _lastUsernameQuery = username;
    _usernameDebounce = Timer(
      const Duration(milliseconds: AppConfig.searchDebounceMsec),
      () => _checkUsername(username),
    );
  }

  Future<void> _checkUsername(String username) async {
    final userId = ref.read(currentUserIdProvider);
    final result = await ref.read(profileRepositoryProvider).isUsernameAvailable(
          username,
          excludeUserId: userId,
        );

    // Ignore a stale response — the field changed while this was in flight.
    if (_lastUsernameQuery != username) return;

    if (result case Ok(:final value)) {
      state = state.copyWith(isUsernameAvailable: value);
    }
  }

  void onBioChanged(String bioText) {
    state = state.copyWith(bioLength: bioText.length);
  }

  Future<void> pickAvatar(BuildContext context) async {
    // imageQuality matches EditProfile — a full-resolution camera shot decoded
    // at source size is enough to OOM on low-end devices before cropping.
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    if (!context.mounted) return;

    // Open the avatar crop screen via go_router and wait for the result
    final croppedPath =
        await context.push<String>(AppRoutes.avatarCrop, extra: file.path);

    if (croppedPath != null) {
      AppLogger.d('ProfileSetup: avatar cropped — $croppedPath');
      state = state.copyWith(avatarLocalPath: croppedPath);
    }
  }

  Future<void> save({
    required String username,
    required String displayName,
    required String bio,
    required String website,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = state.copyWith(errorMessage: 'User is not authenticated.');
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    AppLogger.i('ProfileSetup: save started — $username');

    // Validation is handled inside UpdateProfileUseCase — no duplication here
    final params = UpdateProfileParams(
      userId: userId,
      username: username.trim(),
      displayName: displayName.trim(),
      bio: bio.trim().isEmpty ? null : bio.trim(),
      website: website.trim().isEmpty ? null : website.trim(),
      avatarLocalPath: state.avatarLocalPath,
    );

    final result = await ref.read(updateProfileUseCaseProvider).call(params);

    switch (result) {
      case Ok():
        AppLogger.i('ProfileSetup: saved successfully');
        state = state.copyWith(isSaving: false, isSaved: true);
      case Err(:final failure):
        AppLogger.e('ProfileSetup: save error — ${failure.message}');
        state = state.copyWith(
          isSaving: false,
          errorMessage: localizedFailure(failure),
        );
    }
  }
}

final profileSetupProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
  ProfileSetupNotifier.new,
);
