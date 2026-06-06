import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles Firebase Cloud Messaging (FCM) for Framee.
/// Call [initialize] once in main() before runApp.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'framee_channel';
  static const _channelName = 'Framee Notifications';
  static const _channelDesc = 'Framee social activity notifications';

  Future<void> initialize() async {
    // 1. Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint(
        '[FCM] Permission: ${settings.authorizationStatus}',
      );
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

    // 6. Get & print FCM token
    final token = await _messaging.getToken();
    if (kDebugMode) debugPrint('[FCM] Token: $token');

    // Send token to Supabase user profile in production:
    // await supabase.from('profiles').update({'fcm_token': token})
    //     .eq('id', supabase.auth.currentUser!.id);

    // 7. Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) debugPrint('[FCM] Token refreshed: $newToken');
      // Update Supabase profile
    });
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
    // Navigate to the relevant screen based on message.data
    // Use your GoRouter navigatorKey to push route
    final route = message.data['route'] as String?;
    if (kDebugMode) debugPrint('[FCM] Opened from notification: $route');
    // routerNavigatorKey.currentContext?.push(route);
  }

  void _onNotificationTap(NotificationResponse response) {
    final route = response.payload;
    if (kDebugMode) debugPrint('[FCM] Tapped notification route: $route');
    // routerNavigatorKey.currentContext?.push(route ?? '/');
  }

  Future<String?> getToken() => _messaging.getToken();
}
