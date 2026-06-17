import '../constants/app_strings.dart';
import 'failure.dart';

/// Maps a domain [Failure] to a localized, user-facing message.
///
/// The domain layer stays locale-agnostic: each [Failure] carries a stable
/// machine-readable [Failure.code] (e.g. `'auth/invalid-credentials'`) plus an
/// English [Failure.message] used only for logs. This function is the single
/// place where a code becomes UI text, so adding a language means editing the
/// i18n files — never the domain.
///
/// Any code without an explicit case falls back to a generic localized message,
/// so unmapped or rare failures never surface raw English (or stray hardcoded)
/// strings to the user.
String localizedFailure(Failure failure) => switch (failure.code) {
      // ── Auth ────────────────────────────────────────────────────────────
      'auth/invalid-credentials' => AppStrings.errorInvalidCredentials,
      'auth/email-already-in-use' => AppStrings.errorEmailInUse,
      'auth/email-not-confirmed' => AppStrings.errorEmailNotConfirmed,
      'auth/weak-password' => AppStrings.errorWeakPassword,
      'auth/password-mismatch' => AppStrings.passwordMismatch,
      'auth/empty-fields' => AppStrings.fillAllFields,

      // ── Session / authorization ─────────────────────────────────────────
      'auth/session-expired' ||
      'unauthorized' ||
      'profile/unauthorized' ||
      'post/unauthorized' =>
        AppStrings.sessionExpired,

      // ── Profile ─────────────────────────────────────────────────────────
      'profile/username-taken' => AppStrings.usernameTaken,

      // ── Connectivity ────────────────────────────────────────────────────
      'network/unavailable' || 'search/network' =>
        AppStrings.noInternetConnection,

      // ── Posts ───────────────────────────────────────────────────────────
      'post/not-found' => AppStrings.postNotFound,

      // ── Fallback — every other code (server, storage, unknown, validation,
      //    interaction, etc.) shows a single generic localized message.
      _ => AppStrings.somethingWentWrong,
    };
