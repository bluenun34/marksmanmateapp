import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/features/tools/services/rifle_level_math.dart';

void main() {
  group('RifleLevelMath', () {
    const mount = MountProfile.proneLeftScreenToTarget;

    test('prone left mount reads level when accelerometer Y is up', () {
      final r = RifleLevelMath.fromSensors(
        ax: 0,
        ay: 9.8,
        az: 0,
        mx: 20,
        my: 0,
        mz: -40,
        mount: mount,
      );
      expect(r.rollDeg, closeTo(0, 1));
      expect(r.inclinationDeg, closeTo(0, 1));
    });

    test('level also reads 0 when gravity vector uses -Y', () {
      final r = RifleLevelMath.fromSensors(
        ax: 0,
        ay: -9.8,
        az: 0,
        mx: 20,
        my: 0,
        mz: -40,
        mount: mount,
      );
      expect(r.rollDeg, closeTo(0, 1));
    });

    test('slight cant reads small roll not 90', () {
      final r = RifleLevelMath.fromSensors(
        ax: 0.3,
        ay: 9.8,
        az: 0,
        mx: 0,
        my: 1,
        mz: 0,
        mount: mount,
      );
      expect(r.rollDeg.abs(), lessThan(10));
      expect(r.rollDeg.abs(), greaterThan(0.5));
    });

    test('phone flat on table is NOT level', () {
      final r = RifleLevelMath.fromSensors(
        ax: 0,
        ay: 0,
        az: 9.8,
        mx: 0,
        my: 1,
        mz: 0,
        mount: mount,
      );
      expect(r.inclinationDeg.abs(), greaterThan(45));
    });

    test('calibration subtracts offsets', () {
      const raw = RifleLevelReading(
        rollDeg: 2.5,
        inclinationDeg: -1.0,
        azimuthDeg: 90,
      );
      const cal = LevelCalibration(
        rollOffset: 2.5,
        inclinationOffset: -1.0,
        azimuthOffset: 90,
      );
      final adjusted = raw.applyCalibration(cal);
      expect(adjusted.rollDeg, closeTo(0, 0.01));
      expect(adjusted.inclinationDeg, closeTo(0, 0.01));
      expect(adjusted.azimuthDeg, closeTo(0, 0.01));
    });

    test('roll direction detects cant left/right', () {
      expect(
        const RifleLevelReading(rollDeg: -1.2, inclinationDeg: 0, azimuthDeg: 0)
            .rollDirection(),
        RollDirection.left,
      );
      expect(
        const RifleLevelReading(rollDeg: 1.2, inclinationDeg: 0, azimuthDeg: 0)
            .rollDirection(),
        RollDirection.right,
      );
    });

    test('zone bands use green and yellow thresholds', () {
      const zones = LevelZoneConfig(greenDeg: 0.5, yellowDeg: 2.0);

      expect(zones.bandForDeviation(0.3), LevelDeviationBand.good);
      expect(zones.bandForDeviation(0.5), LevelDeviationBand.good);
      expect(zones.bandForDeviation(1.5), LevelDeviationBand.warn);
      expect(zones.bandForDeviation(2.5), LevelDeviationBand.bad);
    });

    test('roll deviation uses roll only', () {
      expect(LevelZoneConfig.rollDeviation(-3.2), closeTo(3.2, 0.01));
    });

    test('reading deviation respects inclination toggle', () {
      expect(
        LevelZoneConfig.readingDeviation(
          rollDeg: 0.3,
          inclinationDeg: 2.0,
          includeInclination: false,
        ),
        closeTo(0.3, 0.01),
      );
      expect(
        LevelZoneConfig.readingDeviation(
          rollDeg: 0.3,
          inclinationDeg: 2.0,
          includeInclination: true,
        ),
        closeTo(2.0, 0.01),
      );
    });

    test('combined deviation uses worst axis', () {
      expect(
        LevelZoneConfig.combinedDeviation(0.3, 1.2),
        closeTo(1.2, 0.01),
      );
    });
  });
}
