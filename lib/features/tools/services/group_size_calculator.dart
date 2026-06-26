import 'dart:ui';

/// Computes group statistics from hit positions in image space using a scale
/// derived from a known target diameter and a calibration line across it.
class GroupSizeCalculator {
  GroupSizeCalculator._();

  /// Pixels per millimetre from a calibration line and known diameter.
  static double pixelsPerMm({
    required Offset calibrationStart,
    required Offset calibrationEnd,
    required double diameterMm,
  }) {
    if (diameterMm <= 0) return 0;
    final linePx = (calibrationEnd - calibrationStart).distance;
    if (linePx <= 0) return 0;
    return linePx / diameterMm;
  }

  static double mmToInches(double mm) => mm / 25.4;

  static double inchesToMm(double inches) => inches * 25.4;

  /// Converts a real-world diameter to millimetres for internal math.
  static double diameterToMm(double diameter, String unit) {
    switch (unit) {
      case 'inches':
        return inchesToMm(diameter);
      case 'mm':
      default:
        return diameter;
    }
  }

  /// Extreme spread — distance between the two farthest hits.
  static GroupSizeResult compute({
    required List<Offset> hits,
    required double pixelsPerMm,
  }) {
    if (hits.isEmpty || pixelsPerMm <= 0) {
      return const GroupSizeResult(
        hitCount: 0,
        extremeSpreadMm: 0,
        meanRadiusMm: 0,
      );
    }

    if (hits.length == 1) {
      return GroupSizeResult(
        hitCount: 1,
        extremeSpreadMm: 0,
        meanRadiusMm: 0,
        center: hits.first,
        extremePair: (hits.first, hits.first),
      );
    }

    var maxPx = 0.0;
    Offset? pairA;
    Offset? pairB;

    for (var i = 0; i < hits.length; i++) {
      for (var j = i + 1; j < hits.length; j++) {
        final d = (hits[j] - hits[i]).distance;
        if (d > maxPx) {
          maxPx = d;
          pairA = hits[i];
          pairB = hits[j];
        }
      }
    }

    final center = _centroid(hits);
    var sumRadius = 0.0;
    for (final hit in hits) {
      sumRadius += (hit - center).distance;
    }
    final meanRadiusPx = sumRadius / hits.length;

    return GroupSizeResult(
      hitCount: hits.length,
      extremeSpreadMm: maxPx / pixelsPerMm,
      meanRadiusMm: meanRadiusPx / pixelsPerMm,
      center: center,
      extremePair: (pairA!, pairB!),
    );
  }

  /// MOA at a given distance (distance in metres).
  static double? moaAtDistance({
    required double groupSizeMm,
    required double distanceMetres,
  }) {
    if (distanceMetres <= 0) return null;
    final groupInches = mmToInches(groupSizeMm);
    final distanceYards = distanceMetres * 1.09361;
    if (distanceYards <= 0) return null;
    return groupInches * 100 / (distanceYards * 1.047);
  }

  static Offset _centroid(List<Offset> points) {
    var x = 0.0;
    var y = 0.0;
    for (final p in points) {
      x += p.dx;
      y += p.dy;
    }
    return Offset(x / points.length, y / points.length);
  }
}

class GroupSizeResult {
  const GroupSizeResult({
    required this.hitCount,
    required this.extremeSpreadMm,
    required this.meanRadiusMm,
    this.center,
    this.extremePair,
  });

  final int hitCount;
  final double extremeSpreadMm;
  final double meanRadiusMm;
  final Offset? center;
  final (Offset, Offset)? extremePair;

  double get extremeSpreadInches => GroupSizeCalculator.mmToInches(extremeSpreadMm);

  double get meanRadiusInches => GroupSizeCalculator.mmToInches(meanRadiusMm);
}
