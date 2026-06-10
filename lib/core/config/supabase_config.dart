/// Supabase ulanish sozlamalari.
///
/// **Production**: `--dart-define=SUPABASE_URL=...` va `--dart-define=SUPABASE_ANON_KEY=...`
/// orqali xavfsiz uzatiladi — CI/CD muhitida secret sifatida saqlanadi.
///
/// **Local dev**: `--dart-define-from-file=.env.json` (gitignore'da) yoki
/// to'g'ridan-to'g'ri `--dart-define` flaglari ishlatiladi.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vooohfvezikkidcpqcxv.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvb29oZnZlemlra2lkY3BxY3h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA3MjcxMjYsImV4cCI6MjA5NjMwMzEyNn0'
        '.DSOMomb47osPfRAKlfHKxs8IvVnOEebB2G_3KgucTk4',
  );

  /// Muhit to'g'ri sozlanganligini tekshiradi — debug build'larda chaqiriladi
  static bool get isConfigured =>
      url.isNotEmpty && anonKey.isNotEmpty && url.startsWith('https://');
}
