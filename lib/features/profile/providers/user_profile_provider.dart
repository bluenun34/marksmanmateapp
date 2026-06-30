import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/public_user_profile_model.dart';

final userProfileProvider =
    FutureProvider.autoDispose.family<PublicUserProfileModel, int>(
  (ref, userId) async {
    if (!ref.watch(isOnlineProvider)) {
      throw const UserProfileOfflineException();
    }
    return ref.read(apiServiceProvider).getUserProfile(userId);
  },
);

class UserProfileOfflineException implements Exception {
  const UserProfileOfflineException();
}
