import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/core/sync/shoot_session_payload.dart';
import 'package:marksmanmate/shared/models/shoot_session_model.dart';

void main() {
  test('buildShootSessionPayload uses Laravel mobile API field names', () {
    final payload = buildShootSessionPayload(
      date: DateTime.parse('2024-06-01T10:00:00.000'),
      discipline: 'rifle',
      sessionType: 'practice',
      rangeName: 'Bisley',
      venueType: 'outdoor',
      latitude: 51.2,
      longitude: -1.3,
      totalRounds: 50,
      totalHits: 45,
      rating: 4,
      temperature: 18.5,
      windSpeed: 8.0,
      windDirection: 'SW',
    );

    expect(payload['occurred_at'], isNotNull);
    expect(payload.containsKey('date'), isFalse);
    expect(payload['weather_temp'], 18.5);
    expect(payload['weather_wind_dir'], 225);
    expect(payload['latitude'], 51.2);
    expect(payload['entries'], isA<List>());
  });

  test('buildShootSessionPayload includes locker ids in entries', () {
    final payload = buildShootSessionPayload(
      date: DateTime.parse('2024-06-01T10:00:00.000'),
      discipline: 'rifle',
      sessionType: 'practice',
      firearmId: 3,
      ammoLoadId: 7,
      equipmentIds: const [11, 12],
      totalRounds: 10,
    );

    final entries = payload['entries'] as List;
    expect(entries, hasLength(1));
    expect(entries.first, {
      'firearm_id': 3,
      'ammo_load_id': 7,
      'equipment_ids': [11, 12],
      'rounds_fired': 10,
    });
  });

  test('ShootSessionModel parses Laravel shoot log resource shape', () {
    final model = ShootSessionModel.fromApiJson({
      'id': 12,
      'occurred_at': '2024-06-01T10:00:00.000Z',
      'discipline': 'rifle',
      'session_type': 'practice',
      'range_name': 'Century',
      'weather': {
        'temp': 17.5,
        'condition': 'Overcast',
        'wind_speed': 6.0,
        'wind_dir': 225,
        'wind_direction_label': 'SW',
        'humidity': 55,
        'pressure': 1012,
      },
      'totals': {
        'hits': 9,
        'misses': 1,
        'score': 95.5,
        'rounds': 10,
      },
    });

    expect(model.id, 12);
    expect(model.totalRounds, 10);
    expect(model.totalHits, 9);
    expect(model.temperature, 17.5);
    expect(model.windDirection, 'SW');
  });
}
