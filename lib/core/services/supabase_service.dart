// Supabase client setup — ready for integration.
// 1. Add supabase_flutter to pubspec.yaml
// 2. Run: flutter pub get
// 3. Replace placeholder URL and anon key with real values from
//    https://supabase.com/dashboard → Project Settings → API

/*
import 'package:supabase_flutter/supabase_flutter.dart';

/// Call once in main() before runApp.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://YOUR_PROJECT_ID.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'YOUR_ANON_KEY'),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 3,
    ),
  );
}

/// Convenient global accessor — use throughout the app.
final supabase = Supabase.instance.client;

/// Storage bucket names
abstract final class SupabaseBuckets {
  static const String avatars = 'avatars';
  static const String posts = 'posts';
}

/// Table names
abstract final class SupabaseTables {
  static const String profiles = 'profiles';
  static const String posts = 'posts';
  static const String comments = 'comments';
  static const String likes = 'likes';
  static const String follows = 'follows';
  static const String notifications = 'notifications';
}

/// Storage helper: upload and get public URL
class SupabaseStorageHelper {
  static Future<String> uploadAvatar({
    required String userId,
    required List<int> bytes,
    required String extension,
  }) async {
    final path = 'avatars/$userId.$extension';
    await supabase.storage
        .from(SupabaseBuckets.avatars)
        .uploadBinary(path, Uint8List.fromList(bytes),
            fileOptions: FileOptions(upsert: true));
    return supabase.storage
        .from(SupabaseBuckets.avatars)
        .getPublicUrl(path);
  }

  static Future<String> uploadPost({
    required String postId,
    required List<int> bytes,
    required String extension,
  }) async {
    final path = 'posts/$postId.$extension';
    await supabase.storage
        .from(SupabaseBuckets.posts)
        .uploadBinary(path, Uint8List.fromList(bytes));
    return supabase.storage
        .from(SupabaseBuckets.posts)
        .getPublicUrl(path);
  }
}
*/

// ── Placeholder to keep the file valid until supabase_flutter is added ───────
/// Supabase integration stub.
/// Uncomment the code above once supabase_flutter package is added.
abstract final class SupabasePlaceholder {
  static const String note =
      'Add supabase_flutter to pubspec.yaml and uncomment SupabaseService';
}
