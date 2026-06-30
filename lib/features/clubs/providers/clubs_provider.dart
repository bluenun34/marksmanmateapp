import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/club_models.dart';
import '../../../shared/models/event_model.dart';

final myClubsProvider =
    FutureProvider.autoDispose<List<ClubListItem>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getMyClubs();
  } catch (_) {
    return const [];
  }
});

final clubDetailProvider =
    FutureProvider.autoDispose.family<ClubDetailModel, String>((ref, slug) async {
  return ref.read(apiServiceProvider).getClub(slug);
});

final clubLeaguesProvider =
    FutureProvider.autoDispose.family<List<ClubLeagueModel>, String>(
        (ref, slug) async {
  return ref.read(apiServiceProvider).getClubLeagues(slug);
});

final clubEventsProvider = FutureProvider.autoDispose
    .family<List<EventModel>, ({String slug, int clubId, String statusFilter})>(
        (ref, params) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getEvents(
          limit: 50,
          statusFilter: params.statusFilter,
          scope: 'club:${params.clubId}',
        );
  } catch (_) {
    return const [];
  }
});

final clubLeagueStandingsProvider = FutureProvider.autoDispose.family<
    ClubLeagueStandingsModel,
    ({String clubSlug, int leagueId, int? season, String? division})>(
  (ref, params) async {
    return ref.read(apiServiceProvider).getClubLeagueStandings(
          params.clubSlug,
          params.leagueId,
          season: params.season,
          division: params.division,
        );
  },
);

final clubMembersProvider = FutureProvider.autoDispose
    .family<List<ClubMemberModel>, ({String slug, String status})>(
  (ref, params) async {
    return ref.read(apiServiceProvider).getClubMembers(
          params.slug,
          status: params.status,
        );
  },
);
