import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/shared/format/session_date_format.dart';

void main() {
  group('formatSessionDateHuman', () {
    test('formats same-day session as Today', () {
      final now = DateTime.now();
      final session = DateTime(now.year, now.month, now.day, 14, 30);
      expect(formatSessionDateHuman(session), 'Today');
    });

    test('formats previous-day session as Yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final session = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
      expect(formatSessionDateHuman(session), 'Yesterday');
    });

    test('formats older session with date', () {
      final older = DateTime(2020, 5, 3);
      expect(formatSessionDateHuman(older), '3 May 2020');
    });
  });

  group('formatSessionDateShort', () {
    test('formats as dd/mm/yyyy', () {
      expect(formatSessionDateShort(DateTime(2026, 6, 9)), '09/06/2026');
    });
  });

  group('formatSessionDateLabel', () {
    test('combines human and short formats', () {
      final older = DateTime(2020, 5, 3);
      expect(formatSessionDateLabel(older), '3 May 2020 · 03/05/2020');
    });
  });
}
