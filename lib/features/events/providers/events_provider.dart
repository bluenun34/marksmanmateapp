import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/event_model.dart';

final upcomingEventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getUpcomingEvents();
  } catch (_) {
    return const [];
  }
});
