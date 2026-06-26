import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/core/sync/session_local_mapper.dart';
import 'package:marksmanmate/features/shoot_log/providers/shoot_log_provider.dart';
import 'package:marksmanmate/shared/models/shoot_session_model.dart';
import 'package:marksmanmate/shared/models/sync_payload.dart';

void main() {
  const sampleLog = {
    'id': 5,
    'occurred_at': '2026-06-09T08:44:41+00:00',
    'location': 'rvrfvrfv',
    'range_name': 'rvrfvrfv',
    'latitude': 52.6181017,
    'longitude': -2.095954,
    'discipline': 'rifle',
    'discipline_label': 'Rifle',
    'session_type': 'practice',
    'venue_type': 'outdoor',
    'weather': {
      'temp': 11,
      'condition': 'Partly cloudy',
      'wind_speed': 10.7,
      'wind_dir': 270,
      'wind_direction_label': 'W',
      'humidity': 80,
      'pressure': 995,
    },
    'totals': {
      'hits': 100,
      'misses': null,
      'score': null,
      'rounds': '500',
    },
    'rating': 3,
    'notes': 'rfvvrfvrfvfrv',
    'discipline_data': null,
    'entries_count': 1,
    'entries': [
      {
        'id': 5,
        'firearm_id': 16,
        'rounds_fired': 500,
        'hits': 100,
        'firearm': {'id': 16, 'display_name': 'Unnamed Firearm'},
      },
    ],
  };

  test('ShootSessionModel parses Laravel sync log shape', () {
    final model = ShootSessionModel.fromApiJson(sampleLog);
    expect(model.id, 5);
    expect(model.totalRounds, 500);
    expect(model.totalHits, 100);
  });

  test('SyncPayload parses shoot_logs list from Laravel', () {
    final payload = SyncPayload.fromJson({
      'firearms': [],
      'ammo_loads': [],
      'equipment': [],
      'shoot_logs': [sampleLog],
      'synced_at': '2026-06-09T12:00:00+00:00',
    });
    expect(payload.shootLogs, hasLength(1));
  });

  test('shootSessionFromRemote produces session item fields', () {
    final model = ShootSessionModel.fromApiJson(sampleLog);
    final session = shootSessionFromRemote(model);
    final item = SessionItem(local: session);
    expect(item.serverId, 5);
    expect(item.detailPath, '/shoot-log/5?source=remote');
  });
}
