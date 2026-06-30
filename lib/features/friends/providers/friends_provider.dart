import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/friendship_models.dart';

final friendsProvider =
    FutureProvider.autoDispose<List<FriendshipModel>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getFriends();
  } catch (_) {
    return const [];
  }
});

final receivedFriendRequestsProvider =
    FutureProvider.autoDispose<List<FriendshipModel>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getReceivedFriendRequests();
  } catch (_) {
    return const [];
  }
});

final sentFriendRequestsProvider =
    FutureProvider.autoDispose<List<FriendshipModel>>((ref) async {
  if (!ref.watch(isOnlineProvider)) return const [];
  try {
    return await ref.read(apiServiceProvider).getSentFriendRequests();
  } catch (_) {
    return const [];
  }
});

final friendSearchProvider = FutureProvider.autoDispose
    .family<List<FriendUserModel>, String>((ref, query) async {
  if (!ref.watch(isOnlineProvider) || query.trim().length < 2) {
    return const [];
  }
  try {
    return await ref.read(apiServiceProvider).searchFriends(query.trim());
  } catch (_) {
    return const [];
  }
});
