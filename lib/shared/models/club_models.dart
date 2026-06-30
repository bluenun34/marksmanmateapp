/// Club models for the mobile API.
library;

class ClubAdminSummary {
  const ClubAdminSummary({
    this.activeMembersCount = 0,
    this.pendingMembersCount = 0,
    this.probationMembersCount = 0,
  });

  final int activeMembersCount;
  final int pendingMembersCount;
  final int probationMembersCount;

  factory ClubAdminSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ClubAdminSummary();
    return ClubAdminSummary(
      activeMembersCount: json['active_members_count'] as int? ?? 0,
      pendingMembersCount: json['pending_members_count'] as int? ?? 0,
      probationMembersCount: json['probation_members_count'] as int? ?? 0,
    );
  }
}

class ClubMembershipRef {
  const ClubMembershipRef({
    required this.role,
    required this.status,
    this.joinedAt,
  });

  final String role;
  final String status;
  final DateTime? joinedAt;

  factory ClubMembershipRef.fromJson(Map<String, dynamic> json) {
    return ClubMembershipRef(
      role: json['role']?.toString() ?? 'member',
      status: json['status']?.toString() ?? 'active',
      joinedAt: _parseDate(json['joined_at']),
    );
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
}

class ClubMemberModel {
  const ClubMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.roleLabel,
    required this.status,
    required this.statusLabel,
    this.membershipCategoryLabel,
    this.requestedAt,
    this.joinedAt,
    this.canManage = false,
    this.assignableRoles = const [],
  });

  final int id;
  final int userId;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String role;
  final String roleLabel;
  final String status;
  final String statusLabel;
  final String? membershipCategoryLabel;
  final DateTime? requestedAt;
  final DateTime? joinedAt;
  final bool canManage;
  final List<String> assignableRoles;

  factory ClubMemberModel.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['assignable_roles'];
    return ClubMemberModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name']?.toString() ?? 'Member',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role']?.toString() ?? 'member',
      roleLabel: json['role_label']?.toString() ?? 'Member',
      status: json['status']?.toString() ?? 'active',
      statusLabel: json['status_label']?.toString() ?? 'Active',
      membershipCategoryLabel: json['membership_category_label']?.toString(),
      requestedAt: _parseDate(json['requested_at']),
      joinedAt: _parseDate(json['joined_at']),
      canManage: json['can_manage'] == true,
      assignableRoles: rolesRaw is List
          ? rolesRaw.map((e) => e.toString()).toList()
          : const [],
    );
  }

  bool get isPending => status == 'pending';
}

class ClubListItem {
  const ClubListItem({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.role,
    this.status,
  });

  final int id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? role;
  final String? status;

  factory ClubListItem.fromJson(Map<String, dynamic> json) {
    return ClubListItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Club',
      slug: json['slug'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
    );
  }

  String get detailPath => '/clubs/$slug';
}

class ClubDetailModel {
  const ClubDetailModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.location,
    this.region,
    this.logoUrl,
    this.websiteUrl,
    this.upcomingEventsCount,
    this.myMembership,
    this.canModerate = false,
    this.adminSummary,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? location;
  final String? region;
  final String? logoUrl;
  final String? websiteUrl;
  final int? upcomingEventsCount;
  final ClubMembershipRef? myMembership;
  final bool canModerate;
  final ClubAdminSummary? adminSummary;

  factory ClubDetailModel.fromJson(Map<String, dynamic> json) {
    final membershipRaw = json['my_membership'];
    return ClubDetailModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Club',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      region: json['region'] as String?,
      logoUrl: json['logo_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      upcomingEventsCount: json['upcoming_events_count'] as int?,
      myMembership: membershipRaw is Map
          ? ClubMembershipRef.fromJson(Map<String, dynamic>.from(membershipRaw))
          : null,
      canModerate: json['can_moderate'] == true,
      adminSummary: ClubAdminSummary.fromJson(
        json['admin_summary'] is Map
            ? Map<String, dynamic>.from(json['admin_summary'] as Map)
            : null,
      ),
    );
  }
}

class ClubLeagueModel {
  const ClubLeagueModel({
    required this.id,
    required this.name,
    this.disciplineName,
    this.isActive = false,
    this.currentSeasonId,
    this.currentSeasonName,
  });

  final int id;
  final String name;
  final String? disciplineName;
  final bool isActive;
  final int? currentSeasonId;
  final String? currentSeasonName;

  factory ClubLeagueModel.fromJson(Map<String, dynamic> json) {
    final seasonRaw = json['current_season'];
    return ClubLeagueModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'League',
      disciplineName: json['discipline_name'] as String?,
      isActive: json['is_active'] == true,
      currentSeasonId: seasonRaw is Map ? seasonRaw['id'] as int? : null,
      currentSeasonName: seasonRaw is Map
          ? seasonRaw['name']?.toString()
          : null,
    );
  }

  String standingsPath(String clubSlug) =>
      '/clubs/$clubSlug/leagues/$id';
}

class ClubLeagueSeasonOption {
  const ClubLeagueSeasonOption({
    required this.id,
    required this.name,
    this.isCurrent = false,
  });

  final int id;
  final String name;
  final bool isCurrent;

  factory ClubLeagueSeasonOption.fromJson(Map<String, dynamic> json) {
    return ClubLeagueSeasonOption(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Season',
      isCurrent: json['is_current'] == true,
    );
  }
}

class ClubStandingRow {
  const ClubStandingRow({
    required this.userId,
    required this.userName,
    this.eventsEntered,
    this.countedRounds,
    this.countedScore,
    this.totalScore,
    this.averageScore,
  });

  final int userId;
  final String userName;
  final int? eventsEntered;
  final int? countedRounds;
  final double? countedScore;
  final double? totalScore;
  final double? averageScore;

  factory ClubStandingRow.fromJson(Map<String, dynamic> json) {
    return ClubStandingRow(
      userId: json['user_id'] as int,
      userName: json['user_name']?.toString() ?? 'Shooter',
      eventsEntered: json['events_entered'] as int?,
      countedRounds: json['counted_rounds'] as int?,
      countedScore: _asDouble(json['counted_score']),
      totalScore: _asDouble(json['total_score']),
      averageScore: _asDouble(json['average_score']),
    );
  }
}

class ClubLeagueStandingsModel {
  const ClubLeagueStandingsModel({
    required this.leagueName,
    this.leagueId,
    this.disciplineName,
    this.seasonId,
    this.seasonName,
    this.isCurrentSeason = false,
    this.seasons = const [],
    this.division,
    this.divisionOptions = const [],
    this.bestN,
    required this.standings,
  });

  final String leagueName;
  final int? leagueId;
  final String? disciplineName;
  final int? seasonId;
  final String? seasonName;
  final bool isCurrentSeason;
  final List<ClubLeagueSeasonOption> seasons;
  final String? division;
  final List<String> divisionOptions;
  final int? bestN;
  final List<ClubStandingRow> standings;

  factory ClubLeagueStandingsModel.fromJson(Map<String, dynamic> json) {
    final league = json['league'];
    final season = json['season'];
    final seasonsRaw = json['seasons'];
    final divisionOptionsRaw = json['division_options'];
    final standingsRaw = json['standings'];

    return ClubLeagueStandingsModel(
      leagueName: league is Map
          ? league['name']?.toString() ?? 'League'
          : 'League',
      leagueId: league is Map ? league['id'] as int? : null,
      disciplineName: league is Map
          ? league['discipline_name']?.toString()
          : null,
      seasonId: season is Map ? season['id'] as int? : null,
      seasonName: season is Map ? season['name']?.toString() : null,
      isCurrentSeason: season is Map && season['is_current'] == true,
      seasons: seasonsRaw is List
          ? seasonsRaw
              .whereType<Map>()
              .map(
                (row) => ClubLeagueSeasonOption.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList()
          : const [],
      division: json['division']?.toString(),
      divisionOptions: divisionOptionsRaw is List
          ? divisionOptionsRaw.map((e) => e.toString()).toList()
          : const [],
      bestN: json['best_n'] as int?,
      standings: standingsRaw is List
          ? standingsRaw
              .whereType<Map>()
              .map(
                (row) => ClubStandingRow.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList()
          : const [],
    );
  }
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
