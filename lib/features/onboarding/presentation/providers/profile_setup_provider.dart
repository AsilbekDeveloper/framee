import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupState {
  const ProfileSetupState({
    this.step = 1,
    this.avatarUrl,
    this.isUsernameAvailable,
    this.bioLength = 0,
    this.isSaving = false,
  });

  final int step;
  final String? avatarUrl;
  final bool? isUsernameAvailable;
  final int bioLength;
  final bool isSaving;

  ProfileSetupState copyWith({
    int? step,
    String? avatarUrl,
    bool? isUsernameAvailable,
    int? bioLength,
    bool? isSaving,
  }) =>
      ProfileSetupState(
        step: step ?? this.step,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isUsernameAvailable: isUsernameAvailable ?? this.isUsernameAvailable,
        bioLength: bioLength ?? this.bioLength,
        isSaving: isSaving ?? this.isSaving,
      );
}

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() => const ProfileSetupState();

  void onUsernameChanged(String value) {
    state = state.copyWith(
      isUsernameAvailable: value.length >= 3 ? true : null,
    );
  }

  // The UI passes the current string to calculate the length
  void onBioChanged(String bioText) {
    state = state.copyWith(bioLength: bioText.length);
  }

  Future<void> pickAvatar() async {
    // Use image_picker in real implementation
    state = state.copyWith(avatarUrl: null);
  }

  // The UI passes all required fields when the user hits 'Save'
  Future<void> save({
    required String username,
    required String displayName,
    required String bio,
    required String website,
  }) async {
    state = state.copyWith(isSaving: true);

    try {
      // Replace with Supabase profile upsert using the passed arguments
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false);
    }
  }
}

final profileSetupProvider =
NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
  ProfileSetupNotifier.new,
);