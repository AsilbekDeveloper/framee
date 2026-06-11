import '../../../../core/errors/failure.dart';

/// Failure hierarchy for the profile feature.
/// All subclasses inherit [Failure] through [ProfileFailure].
abstract class ProfileFailure extends Failure {
  const ProfileFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Profile not found — no row in the `profiles` table for the given ID.
final class ProfileNotFoundFailure extends ProfileFailure {
  const ProfileNotFoundFailure({String? userId})
      : super(
          message: 'Profile not found.',
          code: 'profile/not-found',
        );
}

/// Username is already taken — must be unique across all profiles.
final class UsernameAlreadyTakenFailure extends ProfileFailure {
  const UsernameAlreadyTakenFailure()
      : super(
          message: 'This username is already taken.',
          code: 'profile/username-taken',
        );
}

/// Username has an invalid format — only letters, digits, underscores, and dots are allowed.
final class InvalidUsernameFailure extends ProfileFailure {
  const InvalidUsernameFailure()
      : super(
          message: "Username may only contain letters, digits, '_', and '.'.",
          code: 'profile/invalid-username',
        );
}

/// Avatar upload failed — Storage error.
final class AvatarUploadFailure extends ProfileFailure {
  const AvatarUploadFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Image upload failed. Please try again.',
          code: 'profile/avatar-upload-failed',
        );
}

/// Profile update failed — server error or RLS policy rejection.
final class ProfileUpdateFailure extends ProfileFailure {
  const ProfileUpdateFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Profile could not be saved. Please try again.',
          code: 'profile/update-failed',
        );
}

/// Unauthorized action — attempted to edit another user's profile.
final class ProfileUnauthorizedFailure extends ProfileFailure {
  const ProfileUnauthorizedFailure()
      : super(
          message: 'You are not authorized to perform this action.',
          code: 'profile/unauthorized',
        );
}
