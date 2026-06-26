import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background/terminated holatda kelgan FCM xabarlarini qayta ishlaydi.
///
/// Top-level funksiya bo'lishi SHART — u alohida (asosiy emas) isolate'da
/// ishga tushadi, shuning uchun `@pragma('vm:entry-point')` kerak.
/// `notification` payload'li xabarlarni Android tizimi avtomatik tray'da
/// ko'rsatadi; bu handler isolate'ni Firebase bilan ishga tushirish uchun kerak,
/// aks holda "background message could not be handled" ogohlantirishi chiqadi.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Handles Firebase Cloud Messaging (FCM) for Framee.
///
/// Call [setTokenSaver] once (before [initialize]) to wire up the persistence
/// callback — keeps FCM concerns out of the data layer.
/// Call [initialize] after the first frame from a ConsumerStatefulWidget.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Called whenever a token is obtained or refreshed.
  /// Set this from the app shell so the data layer (ProfileRepository)
  /// handles the actual Supabase write.
  Future<void> Function(String token)? _tokenSaver;

  void setTokenSaver(Future<void> Function(String token) saver) {
    _tokenSaver = saver;
  }

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

    // 7. Get FCM token and save to Supabase if user is logged in.
    // iOS'da APNS token tayyor bo'lmasa getToken() exception tashlashi mumkin —
    // shuning uchun himoyalaymiz, aks holda butun initialize() to'xtab qoladi.
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) debugPrint('[FCM] Token: $token');
      if (token != null) await _saveToken(token);
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] getToken failed: $e');
    }

    // 8. Token refresh — save updated token
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) debugPrint('[FCM] Token refreshed: $newToken');
      _saveToken(newToken);
    });
  }

  /// Call this after a successful login to ensure the token is saved.
  Future<void> saveTokenAfterLogin() async {
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    try {
      await _tokenSaver?.call(token);
      if (kDebugMode) debugPrint('[FCM] Token saved');
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
