import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  LocalNotificationsService._();
  static final instance = LocalNotificationsService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  var _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<void> showSyncComplete({required int sessionCount}) async {
    await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'marksmanmate_sync',
        'Sync',
        channelDescription: 'Shoot log sync status',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      1,
      'Sync complete',
      sessionCount > 0
          ? '$sessionCount session${sessionCount == 1 ? '' : 's'} loaded'
          : 'Your account is up to date',
      details,
    );
  }

  Future<void> showSyncFailed(String message) async {
    await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'marksmanmate_sync',
        'Sync',
        channelDescription: 'Shoot log sync status',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(2, 'Sync failed', message, details);
  }
}
