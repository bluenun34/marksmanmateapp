class EventModel {
  const EventModel({
    required this.id,
    required this.name,
    this.eventDate,
    this.startTime,
    this.location,
    this.eventType,
    this.status,
  });

  final int id;
  final String name;
  final DateTime? eventDate;
  final String? startTime;
  final String? location;
  final String? eventType;
  final String? status;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Event',
      eventDate: json['event_date'] != null
          ? DateTime.tryParse(json['event_date'] as String)
          : null,
      startTime: json['start_time'] as String?,
      location: json['location'] as String?,
      eventType: json['event_type'] as String?,
      status: json['status'] as String?,
    );
  }

  String get logPath => '/shoot-log/new?event_id=$id';
}
