import 'package:flutter_test/flutter_test.dart';

import 'package:marksmanmate/shared/models/public_user_profile_model.dart';

void main() {
  test('PublicUserProfileModel parses profile payload', () {
    final profile = PublicUserProfileModel.fromJson({
      'id': 7,
      'name': 'Alex Shooter',
      'username': 'alex',
      'avatar_path': '/storage/avatars/alex.jpg',
      'is_own_profile': false,
      'can_view_full_profile': true,
      'is_verified': true,
      'last_active_at': '2026-06-30T10:00:00.000000Z',
      'last_active': '1 hour ago',
      'is_online': false,
      'plan_key': 'pro_user',
      'stats': {
        'friends': 3,
        'clubs': 1,
        'groups': 2,
        'sessions': 12,
        'rounds': 240,
      },
      'friendship': {
        'id': 4,
        'status': 'accepted',
        'direction': 'incoming',
        'user_id': 7,
        'user_name': 'Alex Shooter',
      },
    });

    expect(profile.id, 7);
    expect(profile.name, 'Alex Shooter');
    expect(profile.canViewFullProfile, isTrue);
    expect(profile.stats?.sessions, 12);
    expect(profile.friendship?.status, 'accepted');
    expect(profile.lastActiveLabel, '1 hour ago');
  });
}
