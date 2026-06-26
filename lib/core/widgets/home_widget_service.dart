import 'package:home_widget/home_widget.dart';

import '../../features/shoot_log/providers/shoot_log_provider.dart';

/// Updates the Android home screen widget with latest shoot-log stats.
class HomeWidgetService {
  static const _androidName = 'MarksmanMateWidgetProvider';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId('group.com.marksmanmate.marksmanmate');
    await HomeWidget.registerInteractivityCallback(_backgroundCallback);
  }

  static Future<void> updateFromSessions(List<SessionItem> sessions) async {
    final now = DateTime.now();
    final roundsThisMonth = sessions
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .fold<int>(0, (acc, s) => acc + (s.totalRounds ?? 0));
    final pending =
        sessions.where((s) => s.syncStatus == 'pending').length;

    await HomeWidget.saveWidgetData<int>('session_count', sessions.length);
    await HomeWidget.saveWidgetData<int>('rounds_month', roundsThisMonth);
    await HomeWidget.saveWidgetData<int>('pending_sync', pending);
    await HomeWidget.updateWidget(
      androidName: _androidName,
      iOSName: 'MarksmanMateWidget',
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundCallback(Uri? uri) async {}
}
