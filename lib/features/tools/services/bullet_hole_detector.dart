import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

import 'target_scale_estimator.dart';

/// Finds bullet holes on paper targets — dark punches and reactive orange tears.
class BulletHoleDetector {
  BulletHoleDetector({
    this.minRadiusPx = 3,
    this.maxRadiusPx = 36,
    this.minBlobPixels = 8,
    this.maxBlobPixels = 2500,
    this.maxAspectRatio = 1.8,
    this.minCircularity = 0.28,
    this.minLocalContrast = 10,
    this.minOuterLuminance = 80,
    this.maxSuggestions = 12,
    this.minDistancePx = 18,
    this.targetInset = 0.05,
    this.reactivePeakWindowPx = 22,
    this.reactiveMinPeakScore = 22,
  });

  final int minRadiusPx;
  final int maxRadiusPx;
  final int minBlobPixels;
  final int maxBlobPixels;
  final double maxAspectRatio;
  final double minCircularity;
  final int minLocalContrast;
  final int minOuterLuminance;
  final int maxSuggestions;
  final double minDistancePx;
  final double targetInset;
  final int reactivePeakWindowPx;
  final double reactiveMinPeakScore;

  List<Offset> detect(
    Uint8List bytes, {
    Iterable<Offset> existingHits = const [],
    TargetDetectionRegion? region,
    Offset? calibrationStart,
    Offset? calibrationEnd,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return const [];

    final width = decoded.width;
    final height = decoded.height;
    final searchRegion = region ??
        _regionFromCalibration(
          width: width,
          height: height,
          start: calibrationStart,
          end: calibrationEnd,
        );

    final gray = img.grayscale(img.Image.from(decoded));
    final darkCandidates = _detectDarkBlobs(
      gray,
      searchRegion,
      width,
      height,
    );
    final reactiveCandidates = _detectReactivePeaks(
      decoded,
      gray,
      searchRegion,
      width,
      height,
    );

    final candidates = [...darkCandidates, ...reactiveCandidates]
      ..sort((a, b) => b.score.compareTo(a.score));

    final picked = <Offset>[];
    for (final candidate in candidates) {
      if (picked.length >= maxSuggestions) break;
      if (_tooClose(candidate.center, existingHits, minDistancePx)) continue;
      if (_tooClose(candidate.center, picked, minDistancePx)) continue;
      picked.add(candidate.center);
    }
    return picked;
  }

  TargetDetectionRegion _regionFromCalibration({
    required int width,
    required int height,
    Offset? start,
    Offset? end,
  }) {
    if (start != null && end != null && (end - start).distance > 20) {
      return TargetDetectionRegion(
        center: Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2),
        radiusPx: (end - start).distance / 2,
      );
    }
    final cx = width / 2.0;
    final cy = height / 2.0;
    return TargetDetectionRegion(
      center: Offset(cx, cy),
      radiusPx: math.min(width, height) * 0.35,
    );
  }

  List<_BlobCandidate> _detectDarkBlobs(
    img.Image gray,
    TargetDetectionRegion region,
    int width,
    int height,
  ) {
    final threshold = _adaptiveDarkThreshold(gray, region);
    final visited = Uint8List(width * height);
    final candidates = <_BlobCandidate>[];

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final point = Offset(x.toDouble(), y.toDouble());
        if (!region.contains(point, inset: targetInset)) continue;

        final idx = y * width + x;
        if (visited[idx] != 0) continue;
        if (gray.getPixel(x, y).r.toInt() > threshold) continue;

        final blob = _floodFillMono(
          gray,
          gray,
          visited,
          x,
          y,
          width,
          height,
          region,
          (px, py) => gray.getPixel(px, py).r.toInt() <= threshold,
        );
        _maybeAddCandidate(blob, region, gray, width, height, candidates,
            scoreBias: 0);
      }
    }
    return candidates;
  }

  List<_BlobCandidate> _detectReactivePeaks(
    img.Image color,
    img.Image gray,
    TargetDetectionRegion region,
    int width,
    int height,
  ) {
    final scores = Float32List(width * height);
    final minX = math.max(0, (region.center.dx - region.radiusPx).floor());
    final maxX =
        math.min(width - 1, (region.center.dx + region.radiusPx).ceil());
    final minY = math.max(0, (region.center.dy - region.radiusPx).floor());
    final maxY =
        math.min(height - 1, (region.center.dy + region.radiusPx).ceil());

    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        final point = Offset(x.toDouble(), y.toDouble());
        if (!region.contains(point, inset: targetInset)) continue;
        scores[y * width + x] = _reactiveScore(color.getPixel(x, y));
      }
    }

    final window = reactivePeakWindowPx;
    final candidates = <_BlobCandidate>[];
    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        final point = Offset(x.toDouble(), y.toDouble());
        if (!region.contains(point, inset: targetInset)) continue;

        final idx = y * width + x;
        final score = scores[idx];
        if (score < reactiveMinPeakScore) continue;
        if (!_isLocalScoreMax(scores, x, y, width, height, window, score)) {
          continue;
        }

        final center = Offset(x.toDouble(), y.toDouble());
        final contrast = _localContrast(gray, center, 8, width, height);
        candidates.add(
          _BlobCandidate(
            center: center,
            score: score * 2 + contrast + 50,
          ),
        );
      }
    }
    return candidates;
  }

  double _reactiveScore(img.Pixel p) {
    final r = p.r.toInt();
    final g = p.g.toInt();
    final b = p.b.toInt();
    if (r < 95) return 0;
    final orange = r - math.max(g, b);
    if (orange < 12) return 0;
    if (g < 28) return orange * 0.6;
    return orange.toDouble() + (r - g) * 0.35;
  }

  bool _isLocalScoreMax(
    Float32List scores,
    int cx,
    int cy,
    int width,
    int height,
    int window,
    double value,
  ) {
    final minX = math.max(0, cx - window);
    final maxX = math.min(width - 1, cx + window);
    final minY = math.max(0, cy - window);
    final maxY = math.min(height - 1, cy + window);

    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        if (scores[y * width + x] > value + 0.5) return false;
      }
    }
    return true;
  }

  void _maybeAddCandidate(
    _FloodResult blob,
    TargetDetectionRegion region,
    img.Image gray,
    int width,
    int height,
    List<_BlobCandidate> candidates, {
    required double scoreBias,
  }) {
    if (blob.pixels.length < minBlobPixels || blob.pixels.length > maxBlobPixels) {
      return;
    }

    final bounds = _bounds(blob.pixels);
    final bw = bounds.maxX - bounds.minX + 1;
    final bh = bounds.maxY - bounds.minY + 1;
    final aspect = math.max(bw, bh) / math.max(1, math.min(bw, bh));
    if (aspect > maxAspectRatio) return;

    final radius = math.sqrt(blob.pixels.length / math.pi);
    if (radius < minRadiusPx || radius > maxRadiusPx) return;

    final circularity = _circularity(blob.pixels, bounds);
    if (circularity < minCircularity) return;

    final center = Offset(
      blob.cx / blob.pixels.length,
      blob.cy / blob.pixels.length,
    );
    if (!region.contains(center, inset: targetInset)) return;

    final contrast = _localContrast(gray, center, radius, width, height);
    if (contrast < minLocalContrast && scoreBias == 0) return;

    final outerLum = _outerMeanLuminance(gray, center, radius, width, height);
    if (outerLum < minOuterLuminance && scoreBias == 0) return;

    candidates.add(
      _BlobCandidate(
        center: center,
        score: blob.sumScore + contrast * 1.2 + circularity * 25 + scoreBias,
      ),
    );
  }

  int _adaptiveDarkThreshold(img.Image gray, TargetDetectionRegion region) {
    final samples = <int>[];
    final minX = math.max(0, (region.center.dx - region.radiusPx).floor());
    final maxX =
        math.min(gray.width - 1, (region.center.dx + region.radiusPx).ceil());
    final minY = math.max(0, (region.center.dy - region.radiusPx).floor());
    final maxY =
        math.min(gray.height - 1, (region.center.dy + region.radiusPx).ceil());

    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        if (!region.contains(Offset(x.toDouble(), y.toDouble()))) continue;
        samples.add(gray.getPixel(x, y).r.toInt());
      }
    }

    if (samples.isEmpty) return 70;
    samples.sort();
    final median = samples[samples.length ~/ 2];
    return (median - 80).clamp(35, 75);
  }

  bool _tooClose(Offset point, Iterable<Offset> others, double minDist) {
    for (final other in others) {
      if ((other - point).distance < minDist) return true;
    }
    return false;
  }

  double _circularity(List<(int, int)> pixels, _Bounds bounds) {
    final w = bounds.maxX - bounds.minX + 1;
    final h = bounds.maxY - bounds.minY + 1;
    final boxArea = w * h;
    if (boxArea <= 0) return 0;
    return pixels.length / boxArea;
  }

  int _localContrast(
    img.Image gray,
    Offset center,
    double radius,
    int width,
    int height,
  ) {
    final innerR = math.max(2, radius * 0.85);
    final outerR = radius * 2.0;

    var innerSum = 0;
    var innerCount = 0;
    var outerSum = 0;
    var outerCount = 0;

    final minX = math.max(0, (center.dx - outerR).floor());
    final maxX = math.min(width - 1, (center.dx + outerR).ceil());
    final minY = math.max(0, (center.dy - outerR).floor());
    final maxY = math.min(height - 1, (center.dy + outerR).ceil());

    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        final dx = x - center.dx;
        final dy = y - center.dy;
        final d = math.sqrt(dx * dx + dy * dy);
        final lum = gray.getPixel(x, y).r.toInt();
        if (d <= innerR) {
          innerSum += lum;
          innerCount++;
        } else if (d <= outerR) {
          outerSum += lum;
          outerCount++;
        }
      }
    }

    if (innerCount == 0 || outerCount == 0) return 0;
    return (outerSum / outerCount - innerSum / innerCount).abs().round();
  }

  double _outerMeanLuminance(
    img.Image gray,
    Offset center,
    double radius,
    int width,
    int height,
  ) {
    final innerR = radius * 1.4;
    final outerR = radius * 2.8;
    var sum = 0;
    var count = 0;

    final minX = math.max(0, (center.dx - outerR).floor());
    final maxX = math.min(width - 1, (center.dx + outerR).ceil());
    final minY = math.max(0, (center.dy - outerR).floor());
    final maxY = math.min(height - 1, (center.dy + outerR).ceil());

    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        final dx = x - center.dx;
        final dy = y - center.dy;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d < innerR || d > outerR) continue;
        sum += gray.getPixel(x, y).r.toInt();
        count++;
      }
    }
    if (count == 0) return 0;
    return sum / count;
  }

  _Bounds _bounds(List<(int, int)> pixels) {
    var minX = pixels.first.$1;
    var maxX = minX;
    var minY = pixels.first.$2;
    var maxY = minY;
    for (final (x, y) in pixels) {
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
    return _Bounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY);
  }

  _FloodResult _floodFillMono(
    img.Image image,
    img.Image gray,
    Uint8List visited,
    int startX,
    int startY,
    int width,
    int height,
    TargetDetectionRegion region,
    bool Function(int x, int y) matches,
  ) {
    final stack = <(int, int)>[(startX, startY)];
    final pixels = <(int, int)>[];
    var sumScore = 0.0;
    var cx = 0.0;
    var cy = 0.0;

    while (stack.isNotEmpty) {
      final (x, y) = stack.removeLast();
      if (x < 0 || y < 0 || x >= width || y >= height) continue;
      if (!region.contains(Offset(x.toDouble(), y.toDouble()), inset: 0)) {
        continue;
      }
      final idx = y * width + x;
      if (visited[idx] != 0) continue;
      if (!matches(x, y)) continue;

      visited[idx] = 1;
      pixels.add((x, y));
      final lum = gray.getPixel(x, y).r.toInt();
      sumScore += (255 - lum).toDouble();
      cx += x;
      cy += y;

      stack.add((x + 1, y));
      stack.add((x - 1, y));
      stack.add((x, y + 1));
      stack.add((x, y - 1));
    }

    return _FloodResult(
      pixels: pixels,
      sumScore: sumScore,
      cx: cx,
      cy: cy,
    );
  }
}

class _BlobCandidate {
  const _BlobCandidate({required this.center, required this.score});

  final Offset center;
  final double score;
}

class _Bounds {
  const _Bounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  final int minX;
  final int maxX;
  final int minY;
  final int maxY;
}

class _FloodResult {
  const _FloodResult({
    required this.pixels,
    required this.sumScore,
    required this.cx,
    required this.cy,
  });

  final List<(int, int)> pixels;
  final double sumScore;
  final double cx;
  final double cy;
}
