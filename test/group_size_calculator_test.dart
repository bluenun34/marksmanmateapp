import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/features/tools/services/group_size_calculator.dart';

void main() {
  group('GroupSizeCalculator', () {
    test('pixelsPerMm from 200px line and 100mm diameter', () {
      expect(
        GroupSizeCalculator.pixelsPerMm(
          calibrationStart: const Offset(0, 0),
          calibrationEnd: const Offset(200, 0),
          diameterMm: 100,
        ),
        2,
      );
    });

    test('extreme spread across two hits 100px apart at 2 px/mm', () {
      final result = GroupSizeCalculator.compute(
        hits: const [Offset(0, 0), Offset(100, 0)],
        pixelsPerMm: 2,
      );
      expect(result.hitCount, 2);
      expect(result.extremeSpreadMm, 50);
      expect(result.extremeSpreadInches, closeTo(1.9685, 0.001));
    });

    test('finds farthest pair among three hits', () {
      final result = GroupSizeCalculator.compute(
        hits: const [
          Offset(0, 0),
          Offset(30, 0),
          Offset(120, 0),
        ],
        pixelsPerMm: 2,
      );
      expect(result.extremeSpreadMm, 60);
      expect(result.extremePair?.$1, const Offset(0, 0));
      expect(result.extremePair?.$2, const Offset(120, 0));
    });

    test('diameterToMm converts inches', () {
      expect(
        GroupSizeCalculator.diameterToMm(1, 'inches'),
        closeTo(25.4, 0.001),
      );
    });

    test('single hit returns zero spread', () {
      final result = GroupSizeCalculator.compute(
        hits: const [Offset(10, 10)],
        pixelsPerMm: 2,
      );
      expect(result.hitCount, 1);
      expect(result.extremeSpreadMm, 0);
    });
  });
}
