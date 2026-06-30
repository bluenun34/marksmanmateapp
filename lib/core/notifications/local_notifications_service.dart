import 'package:flutter_local_notifications/flutter_local_notifications.dart';



typedef NotificationPayloadHandler = void Function(String? payload);



class LocalNotificationsService {

  LocalNotificationsService._();

  static final instance = LocalNotificationsService._();



  final _plugin = FlutterLocalNotificationsPlugin();

  var _initialized = false;

  NotificationPayloadHandler? onPayload;



  Future<void> initialize() async {

    if (_initialized) return;



    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        onPayload?.call(response.payload);
      },
    );

    _initialized = true;

  }



  Future<void> requestPermissions() async {

    await initialize();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<

        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<

        IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

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
      id: 1,
      title: 'Sync complete',
      body: sessionCount > 0
          ? '$sessionCount session${sessionCount == 1 ? '' : 's'} loaded'
          : 'Your account is up to date',
      notificationDetails: details,
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

    await _plugin.show(
      id: 2,
      title: 'Sync failed',
      body: message,
      notificationDetails: details,
    );

  }



  Future<void> showEventReminder({

    required int eventId,

    required String title,

    required String body,

  }) async {

    await showInboxNotification(

      id: 1000 + eventId,

      title: title,

      body: body,

      route: '/events/$eventId',

    );

  }



  Future<void> showInboxNotification({

    required int id,

    required String title,

    required String body,

    required String route,

  }) async {

    await initialize();

    const details = NotificationDetails(

      android: AndroidNotificationDetails(

        'marksmanmate_inbox',

        'Alerts',

        channelDescription: 'Messages, events, and account alerts',

        importance: Importance.high,

        priority: Priority.high,

      ),

      iOS: DarwinNotificationDetails(),

    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: route,
    );

  }

}

