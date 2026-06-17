import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Firebase Cloud Messaging (FCM) for Framee.
/// Call [initialize] once in main() before runApp.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _routeStream = StreamController<String>.broadcast();

  static const _channelId = 'framee_channel';
  static const _channelName = 'Framee Notifications';
  static const _channelDesc = 'Framee social activity notifications';

  /// Notification tap qilinganda navigate qilish kerak bo'lgan route stream.
  Stream<String> get navigationStream => _routeStream.stream;

  String? _pendingRoute;

  /// App terminated holatdan notification tap qilinsa saqlangan route.
  /// Bir marta o'qilgandan keyin null bo'ladi.
  String? consumePendingRoute() {
    final r = _pendingRoute;
    _pendingRoute = null;
    return r;
  }

  Future<void> initialize() async {
    // 1. Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
    }

    // 2. Setup local notifications channel (Android)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // 3. Initialize local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 4. Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 5. Background / terminated open handler
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 6. App terminated holatdan notification tap qilinsa (cold start)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final route = initialMessage.data['route'] as String?;
      if (kDebugMode) debugPrint('[FCM] Cold start route: $route');
      if (route != null) _pendingRoute = route;
    }

    // 7. Get FCM token and save to Supabase if user is logged in
    final token = await _messaging.getToken();
    if (kDebugMode) debugPrint('[FCM] Token: $token');
    if (token != null) await _saveTokenToSupabase(token);

    // 8. Token refresh — save updated token
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) debugPrint('[FCM] Token refreshed: $newToken');
      _saveTokenToSupabase(newToken);
    });
  }

  /// Call this after a successful login to ensure the token is saved.
  Future<void> saveTokenAfterLogin() async {
    final token = await _messaging.getToken();
    if (token != null) await _saveTokenToSupabase(token);
  }

  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      await client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);

      if (kDebugMode) debugPrint('[FCM] Token saved to Supabase');
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Failed to save token: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'],
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (kDebugMode) debugPrint('[FCM] Opened from notification: $route');
    if (route != null) _routeStream.add(route);
  }

  void _onNotificationTap(NotificationResponse response) {
    final route = response.payload;
    if (kDebugMode) debugPrint('[FCM] Tapped notification route: $route');
    if (route != null) _routeStream.add(route);
  }

  Future<String?> getToken() => _messaging.getToken();
}
