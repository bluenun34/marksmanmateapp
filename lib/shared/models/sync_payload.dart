class SyncPayload {
  const SyncPayload({
    required this.firearms,
    required this.ammoLoads,
    required this.equipment,
    required this.paperTargets,
    required this.shootLogs,
    required this.syncedAt,
  });

  final List<Map<String, dynamic>> firearms;
  final List<Map<String, dynamic>> ammoLoads;
  final List<Map<String, dynamic>> equipment;
  final List<Map<String, dynamic>> paperTargets;
  final List<Map<String, dynamic>> shootLogs;
  final DateTime syncedAt;

  static List<Map<String, dynamic>> _parseList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  factory SyncPayload.fromJson(Map<String, dynamic> json) => SyncPayload(
        firearms: _parseList(json['firearms']),
        ammoLoads: _parseList(json['ammo_loads']),
        equipment: _parseList(json['equipment']),
        paperTargets: _parseList(json['paper_targets']),
        shootLogs: _parseList(json['shoot_logs']),
        syncedAt: DateTime.parse(json['synced_at'] as String),
      );
}
