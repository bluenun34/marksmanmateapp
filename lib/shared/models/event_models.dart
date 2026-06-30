/// Event list + detail models matching the Laravel mobile API.
library;

class EventModel {
  const EventModel({
    required this.id,
    required this.name,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.location,
    this.eventType,
    this.status,
    this.effectiveStatus,
    this.clubName,
    this.groupName,
    this.clubId,
    this.clubSlug,
  });

  final int id;
  final String name;
  final DateTime? eventDate;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? eventType;
  final String? status;
  final String? effectiveStatus;
  final String? clubName;
  final String? groupName;
  final int? clubId;
  final String? clubSlug;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Event',
      eventDate: json['event_date'] != null
          ? DateTime.tryParse(json['event_date'] as String)
          : null,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      location: json['location'] as String?,
      eventType: json['event_type'] as String?,
      status: json['status'] as String?,
      effectiveStatus: json['effective_status'] as String?,
      clubName: json['club_name'] as String?,
      groupName: json['group_name'] as String?,
      clubId: json['club_id'] as int?,
      clubSlug: json['club_slug'] as String?,
    );
  }

  String get logPath => '/shoot-log/new?event_id=$id';

  String get detailPath => '/events/$id';

  /// Calendar day strictly before today (local).
  bool get isOnPastCalendarDay {
    if (eventDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(
      eventDate!.year,
      eventDate!.month,
      eventDate!.day,
    );
    return eventDay.isBefore(today);
  }

  bool get isEnded =>
      effectiveStatus == 'ended' ||
      effectiveStatus == 'cancelled' ||
      isOnPastCalendarDay;

  bool get isLive {
    if (isEnded) return false;
    return effectiveStatus == 'live';
  }

  bool get isUpcoming =>
      !isEnded &&
      !isLive &&
      (effectiveStatus == 'published' || effectiveStatus == 'upcoming');
}

class EventClubRef {
  const EventClubRef({required this.id, required this.name, this.slug});

  final int id;
  final String name;
  final String? slug;

  factory EventClubRef.fromJson(Map<String, dynamic> json) => EventClubRef(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String?,
      );
}

class EventDisciplineRef {
  const EventDisciplineRef({
    required this.id,
    required this.key,
    required this.name,
  });

  final int id;
  final String key;
  final String name;

  factory EventDisciplineRef.fromJson(Map<String, dynamic> json) =>
      EventDisciplineRef(
        id: json['id'] as int,
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );
}

class EventLinkedShootRef {
  const EventLinkedShootRef({required this.id, this.status});

  final int id;
  final String? status;

  factory EventLinkedShootRef.fromJson(Map<String, dynamic> json) =>
      EventLinkedShootRef(
        id: json['id'] as int,
        status: json['status'] as String?,
      );
}

class EventLeagueRef {
  const EventLeagueRef({
    required this.id,
    required this.name,
    this.divisions = const [],
  });

  final int id;
  final String name;
  final List<String> divisions;

  factory EventLeagueRef.fromJson(Map<String, dynamic> json) => EventLeagueRef(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        divisions: (json['divisions'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}

class EventParticipation {
  const EventParticipation({
    this.isAttending = false,
    this.isInvited = false,
    this.isCheckedIn = false,
    this.checkedInAt,
    this.canRsvp = false,
    this.canSelfCheckIn = false,
    this.canManage = false,
    this.isOwner = false,
  });

  final bool isAttending;
  final bool isInvited;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final bool canRsvp;
  final bool canSelfCheckIn;
  final bool canManage;
  final bool isOwner;

  factory EventParticipation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EventParticipation();
    return EventParticipation(
      isAttending: json['is_attending'] == true,
      isInvited: json['is_invited'] == true,
      isCheckedIn: json['is_checked_in'] == true,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.tryParse(json['checked_in_at'] as String)
          : null,
      canRsvp: json['can_rsvp'] == true,
      canSelfCheckIn: json['can_self_check_in'] == true,
      canManage: json['can_manage'] == true,
      isOwner: json['is_owner'] == true,
    );
  }
}

class EventCapabilities {
  const EventCapabilities({
    this.isLocked = false,
    this.showsRunTab = false,
    this.showsShootTab = false,
    this.showsScoresTab = false,
    this.showsLiveScoreboardTab = false,
    this.canEndShootDay = false,
    this.canSelfScore = false,
    this.publicShareUrl,
  });

  final bool isLocked;
  final bool showsRunTab;
  final bool showsShootTab;
  final bool showsScoresTab;
  final bool showsLiveScoreboardTab;
  final bool canEndShootDay;
  final bool canSelfScore;
  final String? publicShareUrl;

  factory EventCapabilities.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EventCapabilities();
    return EventCapabilities(
      isLocked: json['is_locked'] == true,
      showsRunTab: json['shows_run_tab'] == true,
      showsShootTab: json['shows_shoot_tab'] == true,
      showsScoresTab: json['shows_scores_tab'] == true,
      showsLiveScoreboardTab: json['shows_live_scoreboard_tab'] == true,
      canEndShootDay: json['can_end_shoot_day'] == true,
      canSelfScore: json['can_self_score'] == true,
      publicShareUrl: json['public_share_url'] as String?,
    );
  }
}

class EventScoreModel {
  const EventScoreModel({
    required this.userId,
    this.name,
    this.score,
    this.division,
    this.notes,
    this.stageScores,
    this.updatedAt,
  });

  final int userId;
  final String? name;
  final double? score;
  final String? division;
  final String? notes;
  final dynamic stageScores;
  final DateTime? updatedAt;

  factory EventScoreModel.fromJson(Map<String, dynamic> json) => EventScoreModel(
        userId: json['user_id'] as int,
        name: json['name'] as String?,
        score: _asDouble(json['score']),
        division: json['division'] as String?,
        notes: json['notes'] as String?,
        stageScores: json['stage_scores'],
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );
}

class EventDetailModel {
  const EventDetailModel({
    required this.id,
    required this.name,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.location,
    this.description,
    this.eventType,
    this.status,
    this.effectiveStatus,
    this.visibility,
    this.visibilityLabel,
    this.activityType,
    this.shootLinkType,
    this.requireCheckin = false,
    this.checkinOpen = false,
    this.allowMemberSelfScoring = false,
    this.club,
    this.discipline,
    this.linkedShoot,
    this.league,
    this.attendeeCount = 0,
    this.scores = const [],
    this.participation = const EventParticipation(),
    this.capabilities = const EventCapabilities(),
  });

  final int id;
  final String name;
  final DateTime? eventDate;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? description;
  final String? eventType;
  final String? status;
  final String? effectiveStatus;
  final String? visibility;
  final String? visibilityLabel;
  final String? activityType;
  final String? shootLinkType;
  final bool requireCheckin;
  final bool checkinOpen;
  final bool allowMemberSelfScoring;
  final EventClubRef? club;
  final EventDisciplineRef? discipline;
  final EventLinkedShootRef? linkedShoot;
  final EventLeagueRef? league;
  final int attendeeCount;
  final List<EventScoreModel> scores;
  final EventParticipation participation;
  final EventCapabilities capabilities;

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    final clubRaw = json['club'];
    final disciplineRaw = json['discipline'];
    final shootRaw = json['linked_shoot'];
    final leagueRaw = json['league'];
    final scoresRaw = json['scores'];

    return EventDetailModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Event',
      eventDate: json['event_date'] != null
          ? DateTime.tryParse(json['event_date'] as String)
          : null,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      eventType: json['event_type'] as String?,
      status: json['status'] as String?,
      effectiveStatus: json['effective_status'] as String?,
      visibility: json['visibility'] as String?,
      visibilityLabel: json['visibility_label'] as String?,
      activityType: json['activity_type'] as String?,
      shootLinkType: json['shoot_link_type'] as String?,
      requireCheckin: json['require_checkin'] == true,
      checkinOpen: json['checkin_open'] == true,
      allowMemberSelfScoring: json['allow_member_self_scoring'] == true,
      club: clubRaw is Map
          ? EventClubRef.fromJson(Map<String, dynamic>.from(clubRaw))
          : null,
      discipline: disciplineRaw is Map
          ? EventDisciplineRef.fromJson(Map<String, dynamic>.from(disciplineRaw))
          : null,
      linkedShoot: shootRaw is Map
          ? EventLinkedShootRef.fromJson(Map<String, dynamic>.from(shootRaw))
          : null,
      league: leagueRaw is Map
          ? EventLeagueRef.fromJson(Map<String, dynamic>.from(leagueRaw))
          : null,
      attendeeCount: json['attendee_count'] as int? ?? 0,
      scores: scoresRaw is List
          ? scoresRaw
              .whereType<Map>()
              .map((e) => EventScoreModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      participation: EventParticipation.fromJson(
        json['participation'] is Map
            ? Map<String, dynamic>.from(json['participation'] as Map)
            : null,
      ),
      capabilities: EventCapabilities.fromJson(
        json['capabilities'] is Map
            ? Map<String, dynamic>.from(json['capabilities'] as Map)
            : null,
      ),
    );
  }

  bool get isLive => effectiveStatus == 'live';
  bool get isEnded =>
      effectiveStatus == 'ended' || effectiveStatus == 'cancelled';

  bool get isStructuredShoot =>
      shootLinkType == 'structured' && activityType == 'shoot';

  String? get disciplineKeyForLog => discipline?.key;
}

class EventCheckinStatus {
  const EventCheckinStatus({
    this.checkinOpen = false,
    this.requiresCheckin = false,
    this.canSelfCheckIn = false,
    this.isCheckedIn = false,
    this.checkedInAt,
    this.setupBlocked,
  });

  final bool checkinOpen;
  final bool requiresCheckin;
  final bool canSelfCheckIn;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final String? setupBlocked;

  factory EventCheckinStatus.fromJson(Map<String, dynamic> json) =>
      EventCheckinStatus(
        checkinOpen: json['checkin_open'] == true,
        requiresCheckin: json['requires_checkin'] == true,
        canSelfCheckIn: json['can_self_check_in'] == true,
        isCheckedIn: json['is_checked_in'] == true,
        checkedInAt: json['checked_in_at'] != null
            ? DateTime.tryParse(json['checked_in_at'] as String)
            : null,
        setupBlocked: json['setup_blocked'] as String?,
      );
}

class EventLiveScoreRow {
  const EventLiveScoreRow({
    required this.userId,
    required this.score,
    required this.stage,
  });

  final int userId;
  final double score;
  final int stage;

  factory EventLiveScoreRow.fromJson(Map<String, dynamic> json) =>
      EventLiveScoreRow(
        userId: json['user_id'] as int,
        score: (json['score'] as num).toDouble(),
        stage: json['stage'] as int? ?? 1,
      );
}

class CheckinDeskAttendee {
  const CheckinDeskAttendee({
    required this.userId,
    required this.name,
    this.checkedInAt,
  });

  final int userId;
  final String name;
  final DateTime? checkedInAt;

  factory CheckinDeskAttendee.fromJson(Map<String, dynamic> json) =>
      CheckinDeskAttendee(
        userId: json['user_id'] as int,
        name: json['name'] as String? ?? 'Member',
        checkedInAt: json['checked_in_at'] != null
            ? DateTime.tryParse(json['checked_in_at'] as String)
            : null,
      );
}

class CheckinDeskState {
  const CheckinDeskState({
    this.checkinOpen = false,
    this.requiresCheckin = false,
    this.canOpenCheckin = false,
    this.canEndShootDay = false,
    this.setupBlocked,
    this.checkinUrl,
    this.checkinPin,
    this.checkedIn = const [],
  });

  final bool checkinOpen;
  final bool requiresCheckin;
  final bool canOpenCheckin;
  final bool canEndShootDay;
  final String? setupBlocked;
  final String? checkinUrl;
  final String? checkinPin;
  final List<CheckinDeskAttendee> checkedIn;

  factory CheckinDeskState.fromJson(Map<String, dynamic> json) {
    final list = json['checked_in'];
    return CheckinDeskState(
      checkinOpen: json['checkin_open'] == true,
      requiresCheckin: json['requires_checkin'] == true,
      canOpenCheckin: json['can_open_checkin'] == true,
      canEndShootDay: json['can_end_shoot_day'] == true,
      setupBlocked: json['setup_blocked'] as String?,
      checkinUrl: json['checkin_url'] as String?,
      checkinPin: json['checkin_pin'] as String?,
      checkedIn: list is List
          ? list
              .whereType<Map>()
              .map((e) =>
                  CheckinDeskAttendee.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class ShootLiveState {
  const ShootLiveState({required this.raw});

  final Map<String, dynamic> raw;

  factory ShootLiveState.fromJson(Map<String, dynamic> json) =>
      ShootLiveState(raw: json);

  int? get shootId => raw['shoot']?['id'] as int?;
  String? get shootName => raw['shoot']?['name'] as String?;
  String? get shootStatus => raw['shoot']?['status'] as String?;
  String? get setupMode => raw['shoot']?['setup_mode'] as String?;

  List<Map<String, dynamic>> get participants {
    final list = raw['participants'];
    if (list is! List) return const [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  List<Map<String, dynamic>> get leaderboard {
    final list = raw['leaderboard'];
    if (list is! List) return const [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Map<String, dynamic>? get rotation =>
      raw['rotation'] is Map ? Map<String, dynamic>.from(raw['rotation'] as Map) : null;

  Map<String, dynamic>? get live =>
      raw['live'] is Map ? Map<String, dynamic>.from(raw['live'] as Map) : null;

  Map<String, dynamic>? get scoringUi =>
      raw['scoring_ui'] is Map
          ? Map<String, dynamic>.from(raw['scoring_ui'] as Map)
          : null;

  Map<String, dynamic>? get currentCapture =>
      raw['current_capture'] is Map
          ? Map<String, dynamic>.from(raw['current_capture'] as Map)
          : null;

  int? get currentParticipantId =>
      live?['current_shoot_participant_id'] as int?;

  int? get currentStageId => live?['current_shoot_stage_id'] as int?;

  int? get currentStandId => live?['current_shoot_stand_id'] as int?;

  List<Map<String, dynamic>> get scoringActions {
    final actions = scoringUi?['actions'];
    if (actions is! List) return const [];
    return actions
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  List<Map<String, dynamic>> get scoringFields {
    final fields = scoringUi?['fields'];
    if (fields is! List) return const [];
    return fields
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String? get scoringPattern => scoringUi?['pattern']?.toString();

  bool get supportsUndo => scoringUi?['supports_undo'] == true;

  List<String> get advanceActions {
    final footer = scoringUi?['footer_actions'];
    if (footer is List && footer.isNotEmpty) {
      return footer.map((e) => e.toString()).toList();
    }
    final actions = <String>[];
    if (setupMode == 'stands') {
      actions.addAll(['next_participant', 'next_stand', 'next_run']);
    } else if (setupMode == 'stages') {
      actions.addAll(['next_participant', 'next_stage', 'next_run']);
    } else {
      actions.add('next_participant');
    }
    return actions;
  }
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
