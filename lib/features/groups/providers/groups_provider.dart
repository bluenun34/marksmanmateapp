import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/models/group_models.dart';

final myGroupsProvider =
    FutureProvider.autoDispose<List<GroupListItem>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getMyGroups();
  } catch (_) {
    return const [];
  }
});

final groupInvitesProvider =
    FutureProvider.autoDispose<List<GroupInviteModel>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getGroupInvites();
  } catch (_) {
    return const [];
  }
});

final groupDetailProvider =
    FutureProvider.autoDispose.family<GroupDetailModel, int>((ref, groupId) async {
  return ref.read(apiServiceProvider).getGroup(groupId);
});

final groupEventsProvider = FutureProvider.autoDispose
    .family<List<EventModel>, ({int groupId, String statusFilter})>(
  (ref, params) async {
    if (!ref.watch(isOnlineProvider)) return const [];
    try {
      return await ref.read(apiServiceProvider).getEvents(
            limit: 50,
            statusFilter: params.statusFilter,
            scope: 'group:${params.groupId}',
          );
    } catch (_) {
      return const [];
    }
  },
);

final groupMembersProvider = FutureProvider.autoDispose
    .family<List<GroupMemberModel>, ({int groupId, String status})>(
  (ref, params) async {
    return ref.read(apiServiceProvider).getGroupMembers(
          params.groupId,
          status: params.status,
        );
  },
);

final groupInviteableFriendsProvider = FutureProvider.autoDispose
    .family<List<InviteableFriend>, int>((ref, groupId) async {
  return ref.read(apiServiceProvider).getGroupInviteableFriends(groupId);
});

final groupPostsProvider = FutureProvider.autoDispose
    .family<List<GroupPostModel>, int>((ref, groupId) async {
  return ref.read(apiServiceProvider).getGroupPosts(groupId);
});
