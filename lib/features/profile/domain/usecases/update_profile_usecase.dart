import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/profile.dart';
import '../failures/profile_failure.dart';
import '../repositories/profile_repository.dart';

/// Validates inputs and updates the user profile via the repository.
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final ProfileRepository _repository;

  // Username regex: 3–30 characters, letters/digits/._  only
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,30}$');

  Future<Result<Profile>> call(UpdateProfileParams params) async {
    // ── Client-side validation ───────────────────────────────────────────────
    final username = params.username?.trim() ?? '';
    final displayName = params.displayName?.trim() ?? '';

    if (username.isEmpty || displayName.isEmpty) {
      return const Err(
        ValidationFailure(
          message: 'Username and display name must not be empty.',
          field: 'required-fields',
        ),
      );
    }

    if (!_usernameRegex.hasMatch(username)) {
      return const Err(InvalidUsernameFailure());
    }

    // ── Username availability check ──────────────────────────────────────────
    // Exclude the current user so re-saving the same username does not fail
    final availResult = await _repository.isUsernameAvailable(
      username,
      excludeUserId: params.userId,
    );
    switch (availResult) {
      case Ok(:final value) when !value:
        return const Err(UsernameAlreadyTakenFailure());
      case Err():
        // Network error — skip the check and let the server return its own error
        break;
      case Ok():
        break;
    }

    return _repository.updateProfile(params);
  }
}
