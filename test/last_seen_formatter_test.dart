import 'package:flutter_test/flutter_test.dart';

import 'package:marksmanmate/shared/utils/last_seen_formatter.dart';

void main() {
  test('formatLastSeen returns online now when flagged', () {
    expect(
      formatLastSeen(isOnline: true),
      'Online now',
    );
  });

  test('formatLastSeen prefixes server label', () {
    expect(
      formatLastSeen(lastActiveLabel: '2 hours ago'),
      'Last seen 2 hours ago',
    );
  });

  test('formatLastSeen formats recent timestamps', () {
    final at = DateTime.now().subtract(const Duration(minutes: 20));
    expect(
      formatLastSeen(lastActiveAt: at),
      'Last seen 20m ago',
    );
  });
}
