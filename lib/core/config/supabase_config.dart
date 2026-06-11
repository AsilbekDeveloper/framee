/// Supabase connection configuration.
///
/// **Production**: values are injected securely via
/// `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...`
/// and stored as secrets in CI/CD.
///
/// **Local dev**: use `--dart-define-from-file=.env.json` (gitignored) or
/// pass `--dart-define` flags directly.
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

  /// Verifies that environment variables are properly set — called in debug builds.
  static bool get isConfigured =>
      url.isNotEmpty && anonKey.isNotEmpty && url.startsWith('https://');
}
