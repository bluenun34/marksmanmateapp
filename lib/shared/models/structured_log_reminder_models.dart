/// Structured shoot log reminders from the mobile API.
library;

class LinkableShootLogRef {
  const LinkableShootLogRef({
    required this.id,
    this.occurredAt,
    this.disciplineLabel,
  });

  final int id;
  final DateTime? occurredAt;
  final String? disciplineLabel;

  factory LinkableShootLogRef.fromJson(Map<String, dynamic> json) {
    return LinkableShootLogRef(
      id: json['id'] as int,
      occurredAt: json['occurred_at'] != null
          ? DateTime.tryParse(json['occurred_at'].toString())
          : null,
      disciplineLabel: json['discipline_label']?.toString(),
    );
  }

  String get linkLabel {
    final date = occurredAt != null
        ? '${occurredAt!.day}/${occurredAt!.month}'
        : 'Log';
    final discipline = disciplineLabel?.trim();
    if (discipline != null && discipline.isNotEmpty) {
      return '$date · $discipline';
    }
    return date;
  }
}

class StructuredLogReminder {
  const StructuredLogReminder({
    required this.eventId,
    required this.eventName,
    this.eventDate,
    this.clubName,
    this.disciplineName,
    this.shootStatus,
    this.linkableLogs = const [],
  });

  final int eventId;
  final String eventName;
  final DateTime? eventDate;
  final String? clubName;
  final String? disciplineName;
  final String? shootStatus;
  final List<LinkableShootLogRef> linkableLogs;

  factory StructuredLogReminder.fromJson(Map<String, dynamic> json) {
    final linkableRaw = json['linkable_logs'];
    return StructuredLogReminder(
      eventId: json['event_id'] as int,
      eventName: json['event_name']?.toString() ?? 'Event',
      eventDate: json['event_date'] != null
          ? DateTime.tryParse(json['event_date'].toString())
          : null,
      clubName: json['club_name']?.toString(),
      disciplineName: json['discipline_name']?.toString(),
      shootStatus: json['shoot_status']?.toString(),
      linkableLogs: linkableRaw is List
          ? linkableRaw
              .whereType<Map>()
              .map(
                (entry) => LinkableShootLogRef.fromJson(
                  Map<String, dynamic>.from(entry),
                ),
              )
              .toList()
          : const [],
    );
  }

  String? get shootStatusLabel {
    switch (shootStatus) {
      case 'completed':
        return 'Completed';
      case 'live':
        return 'Live';
      default:
        return null;
    }
  }

  String get eventDetailPath => '/events/$eventId';

  String get createLogPath => '/shoot-log/new?event_id=$eventId';
}
