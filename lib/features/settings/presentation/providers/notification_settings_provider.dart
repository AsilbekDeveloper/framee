import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../profile/data/providers/profile_data_providers.dart';

const _kPushEnabled = 'notification_push_enabled';
const _kEmailEnabled = 'notification_email_enabled';

class NotificationSettingsState {
  const NotificationSettingsState({
    this.pushEnabled = true,
    this.emailEnabled = false,
  });

  final bool pushEnabled;
  final bool emailEnabled;

  NotificationSettingsState copyWith({bool? pushEnabled, bool? emailEnabled}) =>
      NotificationSettingsState(
        pushEnabled: pushEnabled ?? this.pushEnabled,
        emailEnabled: emailEnabled ?? this.emailEnabled,
      );
}

class NotificationSettingsNotifier
    extends AsyncNotifier<NotificationSettingsState> {
  @override
  Future<NotificationSettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettingsState(
      pushEnabled: prefs.getBool(_kPushEnabled) ?? true,
      emailEnabled: prefs.getBool(_kEmailEnabled) ?? false,
    );
  }

  Future<void> setPushEnabled(bool value) async {
    final current = state.valueOrNull ?? const NotificationSettingsState();
    state = AsyncData(current.copyWith(pushEnabled: value));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPushEnabled, value);

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final repo = ref.read(profileRepositoryProvider);

    if (value) {
      // Re-enable: save the current FCM token back to DB
      final token = await FcmService.instance.getToken();
      if (token != null) await repo.saveFcmToken(userId, token);
    } else {
      // Disable: remove token from DB so no pushes are sent
      await repo.clearFcmToken(userId);
    }
  }

  Future<void> setEmailEnabled(bool value) async {
    final current = state.valueOrNull ?? const NotificationSettingsState();
    state = AsyncData(current.copyWith(emailEnabled: value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEmailEnabled, value);
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  NotificationSettingsNotifier.new,
);
