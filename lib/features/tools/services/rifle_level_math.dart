import 'dart:math';

import 'package:flutter/material.dart';

/// Tolerance bands — green / amber / red (degrees from calibrated zero).
class LevelZoneConfig {
  const LevelZoneConfig({
    this.greenDeg = 0.5,
    this.yellowDeg = 2.0,
  }) : assert(greenDeg > 0),
       assert(yellowDeg > greenDeg);

  final double greenDeg;
  final double yellowDeg;

  static const presets = [0.25, 0.5, 1.0];

  LevelDeviationBand bandForDeviation(double deviationDeg) {
    final abs = deviationDeg.abs();
    if (abs <= greenDeg) return LevelDeviationBand.good;
    if (abs <= yellowDeg) return LevelDeviationBand.warn;
    return LevelDeviationBand.bad;
  }

  static double combinedDeviation(double rollDeg, double inclinationDeg) {
    return max(rollDeg.abs(), inclinationDeg.abs());
  }

  /// Roll-only deviation for colours, audio, and zones.
  static double rollDeviation(double rollDeg) => rollDeg.abs();

  /// Active deviation for colour/audio — roll-only unless inclination is enabled.
  static double readingDeviation({
    required double rollDeg,
    required double inclinationDeg,
    required bool includeInclination,
  }) =>
      includeInclination
          ? combinedDeviation(rollDeg, inclinationDeg)
          : rollDeg.abs();

  LevelZoneConfig copyWith({double? greenDeg, double? yellowDeg}) =>
      LevelZoneConfig(
        greenDeg: greenDeg ?? this.greenDeg,
        yellowDeg: yellowDeg ?? this.yellowDeg,
      );
}

/// Single phone mount — prone shooter, phone on left, screen toward you, back to target.
enum MountProfile {
  proneLeftScreenToTarget(
    label: 'Phone left · screen to you · back to target',
    hint: 'Prone behind the rifle: phone clamped on the left side in portrait. '
        'Screen faces you, back of the phone points downrange toward the muzzle.',
    barrel: Axis3(0, 0, -1),
    levelGravity: Axis3(0, -1, 0),
    screenToShooter: true,
  );

  const MountProfile({
    required this.label,
    required this.hint,
    required this.barrel,
    required this.levelGravity,
    this.rollSign = 1,
    this.screenToShooter = true,
  });

  final String label;
  final String hint;
  final Axis3 barrel;
  final Axis3 levelGravity;
  final int rollSign;
  final bool screenToShooter;

  static const MountProfile defaultMount = MountProfile.proneLeftScreenToTarget;

  static MountProfile fromLegacyIndex(int index) => defaultMount;
}

@immutable
class Axis3 {
  const Axis3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  double get length => sqrt(x * x + y * y + z * z);

  Axis3 normalized() {
    final n = length;
    if (n < 1e-6) return const Axis3(0, 0, -1);
    return Axis3(x / n, y / n, z / n);
  }

  double dot(Axis3 o) => x * o.x + y * o.y + z * o.z;

  Axis3 scale(double s) => Axis3(x * s, y * s, z * s);

  Axis3 operator -(Axis3 o) => Axis3(x - o.x, y - o.y, z - o.z);

  Axis3 cross(Axis3 o) =>
      Axis3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
}

/// Roll / inclination sample from sensors (degrees).
class RifleLevelReading {
  const RifleLevelReading({
    required this.rollDeg,
    required this.inclinationDeg,
    required this.azimuthDeg,
  });

  final double rollDeg;
  final double inclinationDeg;
  final double azimuthDeg;

  /// Back-compat aliases.
  double get cantDeg => rollDeg;
  double get pitchDeg => inclinationDeg;

  RifleLevelReading applyCalibration(LevelCalibration cal) {
    return RifleLevelReading(
      rollDeg: _wrapSigned(rollDeg - cal.rollOffset),
      inclinationDeg: inclinationDeg - cal.inclinationOffset,
      azimuthDeg: _wrap360(azimuthDeg - cal.azimuthOffset),
    );
  }

  RollDirection rollDirection({double deadZone = 0.05}) {
    if (rollDeg.abs() <= deadZone) return RollDirection.level;
    return rollDeg > 0 ? RollDirection.right : RollDirection.left;
  }

  static double _wrapSigned(double v) {
    var x = v;
    while (x > 180) x -= 360;
    while (x < -180) x += 360;
    return x;
  }

  static double _wrap360(double v) {
    var x = v % 360;
    if (x < 0) x += 360;
    return x;
  }
}

enum RollDirection {
  left('Canted left'),
  level('Level'),
  right('Canted right');

  const RollDirection(this.label);
  final String label;
}

class LevelCalibration {
  const LevelCalibration({
    this.rollOffset = 0,
    this.inclinationOffset = 0,
    this.azimuthOffset = 0,
  });

  final double rollOffset;
  final double inclinationOffset;
  final double azimuthOffset;

  double get cantOffset => rollOffset;
  double get pitchOffset => inclinationOffset;

  bool get isEmpty =>
      rollOffset == 0 && inclinationOffset == 0 && azimuthOffset == 0;
}

abstract class RifleLevelMath {
  static RifleLevelReading fromSensors({
    required double ax,
    required double ay,
    required double az,
    required double mx,
    required double my,
    required double mz,
    required MountProfile mount,
  }) {
    final g = Axis3(ax, ay, az).normalized();

    final roll = mount.screenToShooter
        ? _screenToShooterRoll(g, mount.rollSign)
        : _rollDeg(g, mount);
    final inclination = mount.screenToShooter
        ? _screenToShooterInclination(g)
        : _inclinationDeg(g, mount.barrel);

    return RifleLevelReading(
      rollDeg: roll,
      inclinationDeg: inclination,
      azimuthDeg: _tiltCompensatedHeading(ax, ay, az, mx, my, mz),
    );
  }

  /// Roll about barrel (−Z) when screen faces shooter and back points downrange.
  /// Uses accelerometer convention (+Y when level in portrait); folds ±180° → 0.
  static double _screenToShooterRoll(Axis3 g, int rollSign) {
    return _normalizeCantRoll(_deg(atan2(g.x, g.y)) * rollSign);
  }

  /// Cant is measured near 0° — fold 180° ambiguity so level reads 0 not ±180.
  static double _normalizeCantRoll(double rollDeg) {
    var r = rollDeg;
    while (r > 180) r -= 360;
    while (r < -180) r += 360;
    if (r > 90) r -= 180;
    if (r < -90) r += 180;
    return r;
  }

  /// Inclination of barrel (−Z) above horizontal — positive muzzle up.
  static double _screenToShooterInclination(Axis3 g) {
    return _deg(asin((-g.z).clamp(-1.0, 1.0)));
  }

  /// Roll / cant about barrel axis. Zero when rifle is level for this mount.
  static double _rollDeg(Axis3 g, MountProfile mount) {
    final b = mount.barrel.normalized();
    final ref = _perp(mount.levelGravity.normalized(), b);
    final gPerp = _perp(g, b);
    final rl = ref.length;
    final gl = gPerp.length;
    if (rl < 1e-4 || gl < 1e-4) return 0;

    final rn = ref.scale(1 / rl);
    final gn = gPerp.scale(1 / gl);
    final sin = b.cross(rn).dot(gn);
    final cos = rn.dot(gn);
    return _deg(atan2(sin, cos)) * mount.rollSign;
  }

  static Axis3 _perp(Axis3 v, Axis3 axis) {
    final n = axis.normalized();
    final d = v.dot(n);
    return v - n.scale(d);
  }

  /// Inclination above horizontal — positive = muzzle up (for ballistic apps).
  static double _inclinationDeg(Axis3 g, Axis3 barrel) {
    final gn = g.normalized();
    final bn = barrel.normalized();
    return _deg(asin((-gn.dot(bn)).clamp(-1.0, 1.0)));
  }

  static double _deg(double rad) => rad * 180 / pi;

  static double _tiltCompensatedHeading(
    double ax,
    double ay,
    double az,
    double mx,
    double my,
    double mz,
  ) {
    final norm = sqrt(ax * ax + ay * ay + az * az);
    if (norm < 0.5) return 0;

    final nx = ax / norm;
    final ny = ay / norm;
    final nz = az / norm;
    final dot = mx * nx + my * ny + mz * nz;
    final hx = mx - dot * nx;
    final hy = my - dot * ny;

    if (sqrt(hx * hx + hy * hy) < 0.1) return 0;
    return _wrap360(_deg(atan2(hy, hx)));
  }

  static double _wrap360(double v) {
    var x = v % 360;
    if (x < 0) x += 360;
    return x;
  }

  static Color bandColor(LevelDeviationBand band) => switch (band) {
        LevelDeviationBand.good => const Color(0xFF2E7D32),
        LevelDeviationBand.warn => const Color(0xFFF9A825),
        LevelDeviationBand.bad => const Color(0xFFC62828),
      };

  static Color bandSurface(LevelDeviationBand band, {bool calibrated = true}) {
    return switch (band) {
      LevelDeviationBand.good => calibrated
          ? const Color(0xFF43A047)
          : const Color(0xFF66BB6A),
      LevelDeviationBand.warn => calibrated
          ? const Color(0xFFFFB300)
          : const Color(0xFFFFCA28),
      LevelDeviationBand.bad => calibrated
          ? const Color(0xFFD32F2F)
          : const Color(0xFFEF5350),
    };
  }
}

enum LevelDeviationBand { good, warn, bad }

enum LevelDisplayMode { setup, shooting }

enum LevelAudioMode { speaker, stereoEarbuds }

/// Formats angle readouts — whole degrees by default, optional tenths.
abstract class LevelFormat {
  /// Large roll readout — `8°`, `-4°` (no leading +).
  static String rollDisplay(double deg, {required bool tenths}) {
    if (tenths) {
      final text = deg.toStringAsFixed(1);
      return '$text°';
    }
    return '${deg.round()}°';
  }

  static String degrees(double deg, {required bool tenths, bool signed = false}) {
    if (tenths) {
      final text = deg.toStringAsFixed(1);
      if (!signed) return '$text°';
      return deg >= 0 ? '+$text°' : '$text°';
    }
    final rounded = deg.round();
    if (!signed) return '$rounded°';
    return rounded >= 0 ? '+$rounded°' : '$rounded°';
  }
}

/// User preferences for rifle level tool.
class LevelSettings {
  const LevelSettings({
    this.mode = LevelDisplayMode.setup,
    this.zones = const LevelZoneConfig(),
    this.customGreen = false,
    this.showRoll = true,
    this.showInclination = true,
    this.showBubble = false,
    this.showColorBars = false,
    this.showCalibrationStatus = true,
    this.showTenths = false,
    this.audioEnabled = false,
    this.audioMode = LevelAudioMode.speaker,
    this.audioVolume = 1.0,
    this.chirpOnLevel = true,
    this.hapticEnabled = false,
    this.keepScreenAwake = true,
  });

  final LevelDisplayMode mode;
  final LevelZoneConfig zones;
  final bool customGreen;
  final bool showRoll;
  final bool showInclination;
  final bool showBubble;
  final bool showColorBars;
  final bool showCalibrationStatus;
  final bool showTenths;
  final bool audioEnabled;
  final LevelAudioMode audioMode;
  final double audioVolume;
  final bool chirpOnLevel;
  final bool hapticEnabled;
  final bool keepScreenAwake;

  LevelSettings copyWith({
    LevelDisplayMode? mode,
    LevelZoneConfig? zones,
    bool? customGreen,
    bool? showRoll,
    bool? showInclination,
    bool? showBubble,
    bool? showColorBars,
    bool? showCalibrationStatus,
    bool? showTenths,
    bool? audioEnabled,
    LevelAudioMode? audioMode,
    double? audioVolume,
    bool? chirpOnLevel,
    bool? hapticEnabled,
    bool? keepScreenAwake,
  }) =>
      LevelSettings(
        mode: mode ?? this.mode,
        zones: zones ?? this.zones,
        customGreen: customGreen ?? this.customGreen,
        showRoll: showRoll ?? this.showRoll,
        showInclination: showInclination ?? this.showInclination,
        showBubble: showBubble ?? this.showBubble,
        showColorBars: showColorBars ?? this.showColorBars,
        showCalibrationStatus: showCalibrationStatus ?? this.showCalibrationStatus,
        showTenths: showTenths ?? this.showTenths,
        audioEnabled: audioEnabled ?? this.audioEnabled,
        audioMode: audioMode ?? this.audioMode,
        audioVolume: audioVolume ?? this.audioVolume,
        chirpOnLevel: chirpOnLevel ?? this.chirpOnLevel,
        hapticEnabled: hapticEnabled ?? this.hapticEnabled,
        keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      );
}

// Legacy alias.
typedef RifleMountOrientation = MountProfile;
