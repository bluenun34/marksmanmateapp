import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/core/database/app_database.dart';
import 'package:marksmanmate/features/shoot_log/providers/shoot_log_provider.dart';

void main() {
  final sampleDate = DateTime(2024, 6, 1);

  group('SessionItem', () {
    test('uses remote detail path when synced to server', () {
      final item = SessionItem(
        local: ShootSession(
          id: 99,
          serverId: 99,
          date: sampleDate,
          discipline: 'rifle',
          sessionType: 'practice',
          syncStatus: 'synced',
          locallyModified: false,
          createdAt: sampleDate,
        ),
      );

      expect(item.detailPath, '/shoot-log/99?source=remote');
      expect(item.serverId, 99);
    });

    test('uses local detail path for pending offline sessions', () {
      final item = SessionItem(
        local: ShootSession(
          id: -123,
          date: sampleDate,
          discipline: 'rifle',
          sessionType: 'practice',
          syncStatus: 'pending',
          locallyModified: false,
          createdAt: sampleDate,
        ),
      );

      expect(item.detailPath, '/shoot-log/-123?source=local');
      expect(item.serverId, isNull);
    });
  });
}
