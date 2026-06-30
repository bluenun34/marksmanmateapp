import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/models/structured_log_reminder_models.dart';

final upcomingEventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getUpcomingEvents(limit: 10);
  } catch (_) {
    return const [];
  }
});

final eventsListProvider = FutureProvider.autoDispose
    .family<List<EventModel>, String>((ref, statusFilter) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref
        .read(apiServiceProvider)
        .getEvents(limit: 50, statusFilter: statusFilter);
  } catch (_) {
    return const [];
  }
});

final eventDetailProvider =
    FutureProvider.autoDispose.family<EventDetailModel, int>((ref, id) async {
  return ref.read(apiServiceProvider).getEvent(id);
});

final eventCheckinProvider =
    FutureProvider.autoDispose.family<EventCheckinStatus, int>((ref, id) async {
  return ref.read(apiServiceProvider).getEventCheckin(id);
});

final eventScoresProvider =
    FutureProvider.autoDispose.family<List<EventScoreModel>, int>((ref, id) async {
  return ref.read(apiServiceProvider).getEventScores(id);
});

final liveEventScoresProvider =
    FutureProvider.autoDispose.family<List<EventLiveScoreRow>, int>((ref, id) async {
  return ref.read(apiServiceProvider).getLiveEventScores(id);
});

final checkinDeskProvider =
    FutureProvider.autoDispose.family<CheckinDeskState, int>((ref, id) async {
  return ref.read(apiServiceProvider).getCheckinDesk(id);
});

final shootLiveStateProvider =
    FutureProvider.autoDispose.family<ShootLiveState, int>((ref, shootId) async {
  return ref.read(apiServiceProvider).getShootState(shootId);
});

final shootDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, int>(
        (ref, shootId) async {
  return ref.read(apiServiceProvider).getShootDetail(shootId);
});

/// Structured shoot log reminders from the server API.
final structuredLogRemindersProvider =
    FutureProvider.autoDispose<List<StructuredLogReminder>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getStructuredLogReminders();
  } catch (_) {
    return const [];
  }
});
