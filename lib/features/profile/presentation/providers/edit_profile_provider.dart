import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/errors/failure_message.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../auth/data/providers/auth_data_providers.dart';
import '../../data/providers/profile_data_providers.dart';
import '../../domain/entities/profile.dart';
import 'profile_provider.dart';

// ── Edit Profile State ────────────────────────────────────────────────────────

class EditProfileState {
  const EditProfileState({
    this.avatarPreviewPath,
    this.bioLength = 0,
    this.isPrivate = false,
    this.isSaving = false,
    this.errorMessage,
    this.savedSuccessfully = false,
  });

  final String? avatarPreviewPath;
  final int bioLength;
  final bool isPrivate;
  final bool isSaving;
  final String? errorMessage;
  final bool savedSuccessfully;

  EditProfileState copyWith({
    String? avatarPreviewPath,
    int? bioLength,
    bool? isPrivate,
    bool? isSaving,
    String? errorMessage,
    bool? savedSuccessfully,
    bool clearError = false,
    bool clearAvatar = false,
  }) =>
      EditProfileState(
        avatarPreviewPath:
            clearAvatar ? null : (avatarPreviewPath ?? this.avatarPreviewPath),
        bioLength: bioLength ?? this.bioLength,
        isPrivate: isPrivate ?? this.isPrivate,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        savedSuccessfully: savedSuccessfully ?? this.savedSuccessfully,
      );
}

// ── Edit Profile Notifier ─────────────────────────────────────────────────────

class EditProfileNotifier extends Notifier<EditProfileState> {
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();
  final bioController = TextEditingController();
  final websiteController = TextEditingController();
  final emailController = TextEditingController();
  final _picker = ImagePicker();

  @override
  EditProfileState build() {
    ref.onDispose(() {
      usernameController.dispose();
      displayNameController.dispose();
      bioController.dispose();
      websiteController.dispose();
      emailController.dispose();
    });

    return _buildInitialState();
  }

  /// Populates text controllers and returns the initial state.
  /// Reads auth user first (always available), then the profile (may not be loaded yet).
  EditProfileState _buildInitialState() {
    final authUser = ref.read(authRepositoryProvider).currentUser;
    final profile = ref.read(profileProvider(null)).valueOrNull;

    final username = profile?.username ??
        authUser?.username ??
        (authUser != null ? authUser.email.split('@').first : '');
    final displayName = profile?.displayName ?? authUser?.fullName ?? '';
    final bio = profile?.bio ?? '';
    final website = profile?.website ?? '';
    final avatarUrl = profile?.avatarUrl;

    usernameController.text = username;
    displayNameController.text = displayName;
    bioController.text = bio;
    websiteController.text = website;
    emailController.text = authUser?.email ?? '';

    AppLogger.d('EditProfile: initial state — $username');

    // If the profile isn't loaded yet, update controllers reactively when it arrives
    if (profile == null) {
      ref.listen<AsyncValue<Profile>>(profileProvider(null), (_, next) {
        next.whenData((p) {
          final fallbackUsername = authUser?.email.split('@').first ?? '';
          if (usernameController.text.isEmpty ||
              usernameController.text == fallbackUsername) {
            usernameController.text = p.username;
          }
          if (displayNameController.text.isEmpty) {
            displayNameController.text = p.displayName;
          }
          if (bioController.text.isEmpty && (p.bio ?? '').isNotEmpty) {
            bioController.text = p.bio!;
            state = state.copyWith(bioLength: p.bio!.length);
          }
          if (websiteController.text.isEmpty && (p.website?.isNotEmpty ?? false)) {
            websiteController.text = p.website!;
          }
          if (p.avatarUrl != null && state.avatarPreviewPath == null) {
            state = state.copyWith(avatarPreviewPath: p.avatarUrl);
          }
          // Sync the private flag from the loaded profile — unless the user
          // already toggled it. Without this, opening Edit Profile before the
          // profile loads and saving would silently reset a private account.
          if (!_privateTouched) {
            state = state.copyWith(isPrivate: p.isPrivate);
          }
        });
      });
    }

    return EditProfileState(
      avatarPreviewPath: avatarUrl,
      bioLength: bio.length,
      isPrivate: profile?.isPrivate ?? false,
    );
  }

  // ── Reactive handlers ───────────────────────────────────────────────────────

  void onBioChanged() =>
      state = state.copyWith(bioLength: bioController.text.length);

  /// Set once the user manually toggles privacy, so the reactive profile-load
  /// listener stops overwriting their choice.
  bool _privateTouched = false;

  void setPrivate(bool val) {
    _privateTouched = true;
    state = state.copyWith(isPrivate: val);
  }

  // ── Avatar tanlov ───────────────────────────────────────────────────────────

  Future<void> pickAvatar(BuildContext context) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    if (!context.mounted) return;

    final croppedPath =
        await context.push<String>(AppRoutes.avatarCrop, extra: file.path);

    if (croppedPath != null) {
      AppLogger.d('EditProfile: avatar selected');
      state = state.copyWith(avatarPreviewPath: croppedPath);
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> save() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = state.copyWith(errorMessage: 'User is not authenticated.');
      return;
    }

    AppLogger.i('EditProfile: saving — $userId');
    state = state.copyWith(isSaving: true, clearError: true);

    final params = UpdateProfileParams(
      userId: userId,
      username: usernameController.text.trim(),
      displayName: displayNameController.text.trim(),
      bio: bioController.text.trim(),
      website: websiteController.text.trim(),
      avatarLocalPath: state.avatarPreviewPath,
      isPrivate: state.isPrivate,
    );

    final result = await ref.read(updateProfileUseCaseProvider).call(params);

    switch (result) {
      case Ok(:final value):
        AppLogger.i('EditProfile: saved — ${value.username}');
        // Update both the null-keyed own-profile instance and the id-keyed one
        // (the latter is watched when navigating to own profile via /user/:id).
        ref.read(profileProvider(null).notifier).updateProfile(value);
        ref.read(profileProvider(value.id).notifier).updateProfile(value);
        state = state.copyWith(
          isSaving: false,
          savedSuccessfully: true,
          avatarPreviewPath: value.avatarUrl,
        );
      case Err(:final failure):
        AppLogger.w('EditProfile: save error — ${failure.code}');
        state = state.copyWith(
          isSaving: false,
          errorMessage: localizedFailure(failure),
        );
    }
  }
}

final editProfileProvider =
    NotifierProvider<EditProfileNotifier, EditProfileState>(
  EditProfileNotifier.new,
);
