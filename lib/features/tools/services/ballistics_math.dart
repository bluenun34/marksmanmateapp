import 'dart:math' as math;

/// Ballistics calculator formulas ported from marksmanmate.com tools.

const moaPerMil = 3.43775;
const inchesPerCm = 0.393701;
const cmPerInch = 2.54;
const yardsPerMetre = 1.09361;
const metresPerYard = 0.9144;
const mmToInches = 0.0393701;
const fpsPerMps = 3.28084;
const footPoundsToJoules = 1.35582;
const powderGasVelocityFps = 4700.0;

double? moaFromMil(double mil) => mil * moaPerMil;
double? milFromMoa(double moa) => moa / moaPerMil;

double? yardsFromMetres(double m) => m * yardsPerMetre;
double? metresFromYards(double yd) => yd * metresPerYard;

/// MOA = (group inches × 100) / (distance yards × 1.047)
double? groupSizeToMoa({
  required double groupSize,
  required bool groupInMm,
  required double distance,
  required bool distanceInMetres,
}) {
  if (groupSize <= 0 || distance <= 0) return null;
  final inches = groupInMm ? groupSize * mmToInches : groupSize;
  final yards = distanceInMetres ? distance * yardsPerMetre : distance;
  return (inches * 100) / (yards * 1.047);
}

/// Per-click shift at distance.
({double inches, double cm})? clickValueShift({
  required double distance,
  required bool distanceInMetres,
  required bool scopeInMoa,
  required double clickValue,
}) {
  if (distance <= 0 || clickValue <= 0) return null;
  final yards = distanceInMetres ? distance * yardsPerMetre : distance;
  final inches = scopeInMoa
      ? (yards * 1.047 * clickValue) / 100
      : (yards * 3.6 * clickValue) / 100;
  return (inches: inches, cm: inches * cmPerInch);
}

/// Offset to clicks correction.
({double angle, String angleUnit, double clicks})? correctionClicks({
  required double offset,
  required bool offsetInCm,
  required double distance,
  required bool distanceInMetres,
  required bool scopeInMoa,
  required double clickValue,
}) {
  if (offset <= 0 || distance <= 0 || clickValue <= 0) return null;
  final inches = offsetInCm ? offset * inchesPerCm : offset;
  final yards = distanceInMetres ? distance * yardsPerMetre : distance;
  final angle = scopeInMoa
      ? (inches * 100) / (yards * 1.047)
      : (inches * 100) / (yards * 3.6);
  final clicks = angle / clickValue;
  return (
    angle: angle,
    angleUnit: scopeInMoa ? 'MOA' : 'MIL',
    clicks: clicks,
  );
}

double? powerFactor({
  required double grains,
  required double velocity,
  required bool velocityInMps,
}) {
  if (grains <= 0 || velocity <= 0) return null;
  final fps = velocityInMps ? velocity * fpsPerMps : velocity;
  return (grains * fps) / 1000;
}

({double ftLb, double joules})? muzzleEnergy({
  required double grains,
  required double velocity,
  required bool velocityInMps,
}) {
  if (grains <= 0 || velocity <= 0) return null;
  final fps = velocityInMps ? velocity * fpsPerMps : velocity;
  final ftLb = (grains * fps * fps) / 450240;
  return (ftLb: ftLb, joules: ftLb * footPoundsToJoules);
}

({double recoilVelocity, double ftLb, double joules})? recoilEnergy({
  required double gunWeightLb,
  required double bulletGrains,
  required double powderGrains,
  required double muzzleVelocityFps,
}) {
  if (gunWeightLb <= 0 ||
      bulletGrains <= 0 ||
      powderGrains < 0 ||
      muzzleVelocityFps <= 0) {
    return null;
  }
  final gunMass = gunWeightLb * 7000;
  final bulletMomentum = bulletGrains * muzzleVelocityFps;
  final gasMomentum = powderGrains * powderGasVelocityFps;
  final totalMomentum = bulletMomentum + gasMomentum;
  final recoilVelocity = totalMomentum / gunMass;
  final ftLb = (gunMass * recoilVelocity * recoilVelocity) / (64.348 * 450240);
  return (
    recoilVelocity: recoilVelocity,
    ftLb: ftLb,
    joules: ftLb * footPoundsToJoules,
  );
}

({double inches, double cm, double moa})? zeroOffset({
  required double oldZeroYards,
  required double newZeroYards,
  required double dropPer100Inches,
}) {
  if (oldZeroYards <= 0 || newZeroYards <= 0 || dropPer100Inches < 0) {
    return null;
  }
  final deltaHundreds = (newZeroYards - oldZeroYards) / 100;
  final inches = deltaHundreds * dropPer100Inches;
  final moa = newZeroYards > 0
      ? (inches.abs() * 100) / (newZeroYards * 1.047)
      : 0.0;
  return (inches: inches, cm: inches * cmPerInch, moa: moa);
}

({double inches, double cm, double moa, double mil})? windDrift({
  required double windSpeedMph,
  required double windAngleDeg,
  required double distanceYards,
  required double driftFactor,
}) {
  if (windSpeedMph < 0 ||
      windAngleDeg < 0 ||
      windAngleDeg > 180 ||
      distanceYards <= 0 ||
      driftFactor < 0) {
    return null;
  }
  final angleFactor = math.sin(windAngleDeg * math.pi / 180);
  final inches =
      windSpeedMph * angleFactor.abs() * driftFactor * (distanceYards / 100);
  return (
    inches: inches,
    cm: inches * cmPerInch,
    moa: (inches * 100) / (distanceYards * 1.047),
    mil: (inches * 100) / (distanceYards * 3.6),
  );
}

class DropTableRow {
  const DropTableRow({
    required this.distanceYards,
    required this.dropInches,
    required this.dropCm,
    required this.comeUpMoa,
  });

  final int distanceYards;
  final double dropInches;
  final double dropCm;
  final double comeUpMoa;
}

List<DropTableRow> dropComeUpTable({
  required double zeroYards,
  required double dropAt100Inches,
  required int startYards,
  required int endYards,
  required int stepYards,
}) {
  if (zeroYards <= 0 ||
      dropAt100Inches < 0 ||
      startYards <= 0 ||
      endYards <= 0 ||
      stepYards <= 0 ||
      endYards < startYards) {
    return const [];
  }
  final rows = <DropTableRow>[];
  for (var d = startYards; d <= endYards; d += stepYards) {
    final beyondZero = math.max(d - zeroYards, 0);
    final dropInches = dropAt100Inches * math.pow(beyondZero / 100, 2);
    rows.add(
      DropTableRow(
        distanceYards: d,
        dropInches: dropInches,
        dropCm: dropInches * cmPerInch,
        comeUpMoa: d > 0 ? (dropInches * 100) / (d * 1.047) : 0,
      ),
    );
  }
  return rows;
}

({double perRound, double perSession, double perWeek, double perMonth})?
    roundCountCost({
  required double boxPrice,
  required int roundsPerBox,
  required int roundsPerSession,
  required double sessionsPerWeek,
}) {
  if (boxPrice < 0 ||
      roundsPerBox <= 0 ||
      roundsPerSession < 0 ||
      sessionsPerWeek < 0) {
    return null;
  }
  final perRound = boxPrice / roundsPerBox;
  final perSession = perRound * roundsPerSession;
  final perWeek = perSession * sessionsPerWeek;
  return (
    perRound: perRound,
    perSession: perSession,
    perWeek: perWeek,
    perMonth: perWeek * 4.33,
  );
}

/// Approximate scope ring height from objective diameter.
double? scopeRingHeightMm({
  required double objectiveMm,
  required double barrelDiameterMm,
  required double clearanceMm,
}) {
  if (objectiveMm <= 0 || barrelDiameterMm <= 0) return null;
  final needed = (objectiveMm / 2) + clearanceMm - (barrelDiameterMm / 2);
  return needed > 0 ? needed : 0;
}

/// Angular size: target size at distance → MOA/MIL.
({double moa, double mil})? angleSize({
  required double targetSize,
  required bool sizeInCm,
  required double distance,
  required bool distanceInMetres,
}) {
  if (targetSize <= 0 || distance <= 0) return null;
  final inches = sizeInCm ? targetSize * inchesPerCm : targetSize;
  final yards = distanceInMetres ? distance * yardsPerMetre : distance;
  final moa = (inches * 100) / (yards * 1.047);
  return (moa: moa, mil: moa / moaPerMil);
}

/// Split times from shot timer string (comma-separated seconds).
List<double>? parseSplitTimes(String input) {
  final parts = input.split(RegExp(r'[,\s]+')).where((p) => p.isNotEmpty);
  final splits = <double>[];
  for (final part in parts) {
    final v = double.tryParse(part);
    if (v == null || v < 0) return null;
    splits.add(v);
  }
  return splits.isEmpty ? null : splits;
}

String formatMoneyGbp(double value) => '£${value.toStringAsFixed(2)}';

String formatNum(double value, {int decimals = 2}) {
  final fixed = value.toStringAsFixed(decimals);
  return fixed.replaceAll(RegExp(r'\.?0+$'), '');
}
