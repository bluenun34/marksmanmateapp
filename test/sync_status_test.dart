import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/core/sync/sync_status_provider.dart';

void main() {
  group('formatLastSync', () {
    test('formats same-day sync as Today', () {
      final now = DateTime.now();
      final sync = DateTime(now.year, now.month, now.day, 14, 30);
      expect(formatLastSync(sync), 'Today at 14:30');
    });

    test('formats previous-day sync as Yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final sync = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        9,
        5,
      );
      expect(formatLastSync(sync), 'Yesterday at 09:05');
    });

    test('formats older sync with date', () {
      final older = DateTime(2020, 5, 3, 18, 45);
      expect(formatLastSync(older), '3 May 2020 at 18:45');
    });
  });
}
