/// App-wide sabit qiymatlar — magic number'larni yo'q qiladi.
///
/// Barcha limit, uzunlik, sahifa o'lchami va timeout
/// qiymatlari shu faylda saqlansin.
abstract final class AppConfig {
  // ── Feed / Pagination ────────────────────────────────────────────────────────
  /// Bir sahifada nechta post yuklanadi
  static const int feedPageSize = 20;
  /// Explore grid'da nechta post yuklanadi
  static const int explorePageSize = 30;
  /// Profile grid'da nechta post yuklanadi
  static const int profilePostPageSize = 18;
  /// Qidiruvda nechta foydalanuvchi ko'rsatiladi
  static const int searchResultLimit = 20;

  // ── Post ─────────────────────────────────────────────────────────────────────
  /// Post caption maksimal uzunligi (Instagram'ga o'xshash)
  static const int maxCaptionLength = 2200;
  /// Avatar rasm maksimal o'lchami (MB)
  static const double maxAvatarSizeMb = 5.0;
  /// Post rasm maksimal o'lchami (MB)
  static const double maxPostImageSizeMb = 10.0;

  // ── Profile ──────────────────────────────────────────────────────────────────
  /// Bio maksimal uzunligi
  static const int maxBioLength = 150;
  /// Username minimal uzunligi
  static const int minUsernameLength = 3;
  /// Username maksimal uzunligi
  static const int maxUsernameLength = 30;
  /// Display name maksimal uzunligi
  static const int maxDisplayNameLength = 50;
  /// Website URL maksimal uzunligi
  static const int maxWebsiteLength = 100;

  // ── Auth ─────────────────────────────────────────────────────────────────────
  /// Parol minimal uzunligi
  static const int minPasswordLength = 6;

  // ── Debounce ─────────────────────────────────────────────────────────────────
  /// Search input debounce (millisekund)
  static const int searchDebounceMsec = 400;

  // ── Supabase storage ─────────────────────────────────────────────────────────
  static const String avatarsBucket = 'avatars';
  static const String postImagesBucket = 'post-images';
}
