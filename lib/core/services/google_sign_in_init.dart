import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_logger.dart';

/// Initializes the `google_sign_in` plugin.
///
/// [GoogleSignIn.initialize] must run before any other GoogleSignIn call, but
/// it can fail for reasons that have nothing to do with Google sign-in itself
/// (no network on a cold start, Play Services hiccup) — if that happens
/// during app startup, it must never take the whole app down with it, since
/// the rest of the app (including email/password auth) doesn't depend on it.
abstract final class GoogleSignInInit {
  static const _serverClientId =
      '410555718765-uuvj8u3hl1m7qf67ofjv8h8ittrt4tn1.apps.googleusercontent.com';

  static bool _initialized = false;

  /// Call once at app startup, before `runApp`. Never throws — a failure is
  /// logged and left for [ensureInitialized] to retry later.
  static Future<void> initAtStartup() async {
    try {
      await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
      _initialized = true;
    } catch (e, st) {
      AppLogger.w('GoogleSignIn: startup initialize failed — $e');
      AppLogger.e('GoogleSignIn: startup initialize error',
          error: e, stackTrace: st);
    }
  }

  /// Call before any other `GoogleSignIn.instance` method. A no-op once
  /// startup init succeeded; otherwise retries it (e.g. the user now has a
  /// connection, even though the app didn't at cold start). Lets the normal
  /// call-site try/catch turn a renewed failure into a user-facing error
  /// instead of leaving GoogleSignIn permanently unusable for the session.
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _initialized = true;
  }
}
