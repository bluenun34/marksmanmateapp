import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

/// Circular region of the target face in image pixel space.
class TargetDetectionRegion {
  const TargetDetectionRegion({
    required this.center,
    required this.radiusPx,
  });

  final Offset center;
  final double radiusPx;

  double get diameterPx => radiusPx * 2;

  bool contains(Offset point, {double inset = 0}) {
    final allowed = radiusPx * (1 - inset);
    return (point - center).distance <= allowed;
  }

  (Offset, Offset) get horizontalDiameterLine => (
        Offset(center.dx - radiusPx, center.dy),
        Offset(center.dx + radiusPx, center.dy),
      );
}

/// Result of finding the target face in a photograph.
class TargetScaleEstimate {
  const TargetScaleEstimate({
    required this.region,
    required this.pixelsPerMm,
    required this.confidence,
  });

  final TargetDetectionRegion region;
  final double pixelsPerMm;
  final double confidence;

  Offset get center => region.center;
  double get radiusPx => region.radiusPx;
}

/// Finds the target scoring circle in a photo and derives pixels-per-mm.
class TargetScaleEstimator {
  /// Returns null if the target face could not be found reliably.
  TargetScaleEstimate? estimate({
    required Uint8List imageBytes,
    required double faceDiameterMm,
  }) {
    if (faceDiameterMm <= 0) return null;

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return null;

    final scale = math.min(1.0, 900 / math.max(decoded.width, decoded.height));
    final work = scale < 1.0
        ? img.copyResize(
            decoded,
            width: (decoded.width * scale).round(),
            height: (decoded.height * scale).round(),
          )
        : decoded;

    final gray = img.grayscale(work);
    final w = gray.width;
    final h = gray.height;
    final minDim = math.min(w, h);

    final centerWindowX = w * 0.18;
    final centerWindowY = h * 0.18;
    final cx0 = w / 2.0;
    final cy0 = h / 2.0;

    var bestScore = 0.0;
    var bestCx = cx0;
    var bestCy = cy0;
    var bestR = minDim * 0.3;

    for (var dy = -centerWindowY; dy <= centerWindowY; dy += 8) {
      for (var dx = -centerWindowX; dx <= centerWindowX; dx += 8) {
        final cx = cx0 + dx;
        final cy = cy0 + dy;
        for (var r = minDim * 0.18; r <= minDim * 0.46; r += 3) {
          final score = _circleEdgeScore(gray, cx, cy, r);
          if (score > bestScore) {
            bestScore = score;
            bestCx = cx;
            bestCy = cy;
            bestR = r;
          }
        }
      }
    }

    if (bestScore < 25) return null;

    final inv = 1 / scale;
    final center = Offset(bestCx * inv, bestCy * inv);
    final radiusPx = bestR * inv;
    final region = TargetDetectionRegion(center: center, radiusPx: radiusPx);
    final pixelsPerMm = region.diameterPx / faceDiameterMm;
    final confidence = (bestScore / 120).clamp(0.0, 1.0);

    return TargetScaleEstimate(
      region: region,
      pixelsPerMm: pixelsPerMm,
      confidence: confidence,
    );
  }

  double _circleEdgeScore(img.Image gray, double cx, double cy, double r) {
    const samples = 72;
    var sum = 0.0;
    for (var i = 0; i < samples; i++) {
      final angle = 2 * math.pi * i / samples;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      sum += _gradientMagnitude(gray, x, y);
    }
    return sum / samples;
  }

  double _gradientMagnitude(img.Image gray, double x, double y) {
    final x0 = x.floor().clamp(1, gray.width - 2);
    final y0 = y.floor().clamp(1, gray.height - 2);
    final gx = _lum(gray, x0 + 1, y0) - _lum(gray, x0 - 1, y0);
    final gy = _lum(gray, x0, y0 + 1) - _lum(gray, x0, y0 - 1);
    return math.sqrt(gx * gx + gy * gy);
  }

  int _lum(img.Image gray, int x, int y) => gray.getPixel(x, y).r.toInt();
}
