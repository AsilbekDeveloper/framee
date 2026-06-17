/// App-wide constant values — eliminates magic numbers.
///
/// All limits, lengths, page sizes, and timeouts should be defined here.
abstract final class AppConfig {
  // ── Feed / Pagination ────────────────────────────────────────────────────────
  /// Number of posts loaded per page in the home feed.
  static const int feedPageSize = 20;
  /// Number of posts loaded per page in the explore grid.
  static const int explorePageSize = 30;
  /// Number of posts loaded per page on a user profile.
  static const int profilePostPageSize = 18;
  /// Number of notifications loaded per page.
  static const int notificationsPageSize = 30;
  /// Maximum number of users returned in a search query.
  static const int searchResultLimit = 20;

  // ── Post ─────────────────────────────────────────────────────────────────────
  /// Maximum caption length (similar to Instagram).
  static const int maxCaptionLength = 2200;
  /// Maximum avatar image size in megabytes.
  static const double maxAvatarSizeMb = 5.0;
  /// Maximum post image size in megabytes.
  static const double maxPostImageSizeMb = 10.0;

  // ── Profile ──────────────────────────────────────────────────────────────────
  /// Maximum bio length in characters.
  static const int maxBioLength = 150;
  /// Minimum allowed username length.
  static const int minUsernameLength = 3;
  /// Maximum allowed username length.
  static const int maxUsernameLength = 30;
  /// Maximum display name length.
  static const int maxDisplayNameLength = 50;
  /// Maximum website URL length.
  static const int maxWebsiteLength = 100;

  // ── Auth ─────────────────────────────────────────────────────────────────────
  /// Minimum password length required for sign-up.
  static const int minPasswordLength = 6;

  // ── Debounce ─────────────────────────────────────────────────────────────────
  /// Search input debounce delay in milliseconds.
  static const int searchDebounceMsec = 400;

  // ── Supabase storage ─────────────────────────────────────────────────────────
  static const String avatarsBucket = 'avatars';
  static const String postImagesBucket = 'post-images';
}
