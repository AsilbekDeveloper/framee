import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/ui_models.dart';
import '../../../../core/utils/mock_data.dart';
import 'profile_provider.dart';

class EditProfileState {
  const EditProfileState({
    this.avatarUrl,
    this.bioLength = 0,
    this.isPrivate = false,
    this.showActivityStatus = true,
    this.isSaving = false,
  });

  final String? avatarUrl;
  final int bioLength;
  final bool isPrivate;
  final bool showActivityStatus;
  final bool isSaving;

  EditProfileState copyWith({
    String? avatarUrl,
    int? bioLength,
    bool? isPrivate,
    bool? showActivityStatus,
    bool? isSaving,
  }) =>
      EditProfileState(
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bioLength: bioLength ?? this.bioLength,
        isPrivate: isPrivate ?? this.isPrivate,
        showActivityStatus: showActivityStatus ?? this.showActivityStatus,
        isSaving: isSaving ?? this.isSaving,
      );
}

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
    _preload();
    return const EditProfileState();
  }

  void _preload() {
    final user = MockData.currentUser;
    usernameController.text = user.username;
    displayNameController.text = user.displayName;
    bioController.text = user.bio ?? '';
    websiteController.text = user.website ?? '';
    emailController.text = user.email ?? '';
    state = state.copyWith(
      avatarUrl: user.avatarUrl,
      bioLength: user.bio?.length ?? 0,
    );
  }

  void onBioChanged() =>
      state = state.copyWith(bioLength: bioController.text.length);

  void setPrivate(bool val) => state = state.copyWith(isPrivate: val);
  void setShowActivity(bool val) =>
      state = state.copyWith(showActivityStatus: val);

  Future<void> pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
    if (file != null) {
      state = state.copyWith(avatarUrl: file.path);
    }
  }

  Future<void> save() async {
    state = state.copyWith(isSaving: true);

    // Replace with Supabase profiles table PATCH
    await Future.delayed(const Duration(seconds: 1));

    final current = MockData.currentUser;
    final bioText = bioController.text.trim();
    final websiteText = websiteController.text.trim();

    final updated = UserModel(
      id: current.id,
      username: usernameController.text.trim(),
      displayName: displayNameController.text.trim(),
      email: emailController.text.trim(),
      avatarUrl: state.avatarUrl,
      bio: bioText.isEmpty ? null : bioText,
      website: websiteText.isEmpty ? null : websiteText,
      postsCount: current.postsCount,
      followersCount: current.followersCount,
      followingCount: current.followingCount,
      isFollowing: current.isFollowing,
      isPrivate: state.isPrivate,
      isVerified: current.isVerified,
    );

    // Persist in mock data so other parts of the app see the update
    MockData.currentUser = updated;

    // Update the profile screen's state immediately
    ref.read(profileProvider(null).notifier).updateUser(updated);

    state = state.copyWith(isSaving: false);
  }
}

final editProfileProvider =
    NotifierProvider<EditProfileNotifier, EditProfileState>(
  EditProfileNotifier.new,
);
