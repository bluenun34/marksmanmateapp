/// Public user profile returned by GET /users/{id}.
library;

import 'friendship_models.dart';

class PublicUserProfileStats {
  const PublicUserProfileStats({
    this.friends = 0,
    this.clubs = 0,
    this.groups = 0,
    this.sessions = 0,
    this.rounds = 0,
  });

  final int friends;
  final int clubs;
  final int groups;
  final int sessions;
  final int rounds;

  factory PublicUserProfileStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PublicUserProfileStats();
    return PublicUserProfileStats(
      friends: json['friends'] as int? ?? 0,
      clubs: json['clubs'] as int? ?? 0,
      groups: json['groups'] as int? ?? 0,
      sessions: json['sessions'] as int? ?? 0,
      rounds: json['rounds'] as int? ?? 0,
    );
  }
}

class PublicUserProfileModel {
  const PublicUserProfileModel({
    required this.id,
    required this.name,
    this.username,
    this.avatarUrl,
    this.isOwnProfile = false,
    this.canViewFullProfile = false,
    this.profileVisibility,
    this.isVerified = false,
    this.isVerifiedSeller = false,
    this.isCoach = false,
    this.isBlockedRelationship = false,
    this.viewerHasBlocked = false,
    this.viewerIsBlocked = false,
    this.lastActiveAt,
    this.lastActiveLabel,
    this.isOnline,
    this.memberSince,
    this.plan,
    this.region,
    this.stats,
    this.friendship,
  });

  final int id;
  final String name;
  final String? username;
  final String? avatarUrl;
  final bool isOwnProfile;
  final bool canViewFullProfile;
  final String? profileVisibility;
  final bool isVerified;
  final bool isVerifiedSeller;
  final bool isCoach;
  final bool isBlockedRelationship;
  final bool viewerHasBlocked;
  final bool viewerIsBlocked;
  final DateTime? lastActiveAt;
  final String? lastActiveLabel;
  final bool? isOnline;
  final String? memberSince;
  final String? plan;
  final String? region;
  final PublicUserProfileStats? stats;
  final FriendshipModel? friendship;

  factory PublicUserProfileModel.fromJson(Map<String, dynamic> json) {
    final friendshipRaw = json['friendship'];
    final statsRaw = json['stats'];

    return PublicUserProfileModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'User',
      username: json['username'] as String?,
      avatarUrl: json['avatar_path'] as String? ?? json['avatar_url'] as String?,
      isOwnProfile: json['is_own_profile'] == true,
      canViewFullProfile: json['can_view_full_profile'] == true,
      profileVisibility: json['profile_visibility'] as String?,
      isVerified: json['is_verified'] == true,
      isVerifiedSeller: json['is_verified_seller'] == true,
      isCoach: json['is_coach'] == true,
      isBlockedRelationship: json['is_blocked_relationship'] == true,
      viewerHasBlocked: json['viewer_has_blocked'] == true,
      viewerIsBlocked: json['viewer_is_blocked'] == true,
      lastActiveAt: _parseDate(json['last_active_at']),
      lastActiveLabel: json['last_active'] as String?,
      isOnline: json['is_online'] as bool?,
      memberSince: json['member_since'] as String?,
      plan: json['plan_key'] as String?,
      region: json['region'] as String?,
      stats: statsRaw is Map
          ? PublicUserProfileStats.fromJson(
              Map<String, dynamic>.from(statsRaw),
            )
          : null,
      friendship: friendshipRaw is Map
          ? FriendshipModel.fromJson(Map<String, dynamic>.from(friendshipRaw))
          : null,
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
