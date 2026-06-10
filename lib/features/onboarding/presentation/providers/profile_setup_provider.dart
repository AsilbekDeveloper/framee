import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_logger.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../profile/data/providers/profile_data_providers.dart';
import '../../../profile/domain/entities/profile.dart';

class ProfileSetupState {
  const ProfileSetupState({
    this.step = 1,
    this.avatarLocalPath,
    this.isUsernameAvailable,
    this.bioLength = 0,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
  });

  final int step;
  final String? avatarLocalPath;
  final bool? isUsernameAvailable;
  final int bioLength;
  final bool isSaving;
  /// true bo'lsa — sahifa o'tishi triggeri
  final bool isSaved;
  final String? errorMessage;

  ProfileSetupState copyWith({
    int? step,
    String? avatarLocalPath,
    bool? isUsernameAvailable,
    int? bioLength,
    bool? isSaving,
    bool? isSaved,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ProfileSetupState(
        step: step ?? this.step,
        avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
        isUsernameAvailable: isUsernameAvailable ?? this.isUsernameAvailable,
        bioLength: bioLength ?? this.bioLength,
        isSaving: isSaving ?? this.isSaving,
        isSaved: isSaved ?? this.isSaved,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  final _picker = ImagePicker();

  @override
  ProfileSetupState build() => const ProfileSetupState();

  void onUsernameChanged(String value) {
    // Minimal UI feedback — haqiqiy validatsiya UpdateProfileUseCase ichida
    state = state.copyWith(isUsernameAvailable: null);
  }

  void onBioChanged(String bioText) {
    state = state.copyWith(bioLength: bioText.length);
  }

  Future<void> pickAvatar(BuildContext context) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    if (!context.mounted) return;

    // go_router orqali avatar crop ekranini ochib, natijani kutamiz
    final croppedPath =
        await context.push<String>(AppRoutes.avatarCrop, extra: file.path);

    if (croppedPath != null) {
      AppLogger.d('ProfileSetup: avatar crop qilindi — $croppedPath');
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
      state = state.copyWith(errorMessage: 'Tizimga kirmagan foydalanuvchi');
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    AppLogger.i('ProfileSetup: saqlash boshlandi — $username');

    // Validatsiya UpdateProfileUseCase ichida — bu yerda takrorlanmaydi
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
        AppLogger.i('ProfileSetup: muvaffaqiyatli saqlandi');
        state = state.copyWith(isSaving: false, isSaved: true);
      case Err(:final failure):
        AppLogger.e('ProfileSetup: saqlashda xato — ${failure.message}');
        state = state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        );
    }
  }
}

final profileSetupProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
  ProfileSetupNotifier.new,
);
