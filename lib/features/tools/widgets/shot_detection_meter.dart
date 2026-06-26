import 'dart:math';

import 'package:flutter/material.dart';

/// How likely the current mic buffer is to count as a shot.
enum ShotDetectionBand {
  unlikely,
  maybe,
  definite;

  /// Meter thresholds — shared by UI bands and peak marker coloring.
  static const maybeThreshold = 0.55;
  static const definiteThreshold = 0.85;

  static ShotDetectionBand fromMeter(double meter, {bool wouldDetect = false}) {
    if (wouldDetect || meter >= definiteThreshold) return definite;
    if (meter >= maybeThreshold) return maybe;
    return unlikely;
  }

  String get label => switch (this) {
        unlikely => 'Unlikely',
        maybe => 'Maybe',
        definite => 'Would count',
      };

  Color get color => switch (this) {
        unlikely => const Color(0xFF1E88E5),
        maybe => const Color(0xFFF9A825),
        definite => const Color(0xFF2E7D32),
      };
}

/// Color-coded shot-likeness bar with optional session peak marker line.
class ShotDetectionMeter extends StatelessWidget {
  const ShotDetectionMeter({
    super.key,
    required this.meter,
    this.wouldDetect = false,
    this.peakMarker,
    this.minHeight = 8,
    this.showLegend = true,
    this.showBandLabel = true,
    this.showPeakHint = false,
  });

  /// Live level (moves with each sound).
  final double meter;
  final bool wouldDetect;

  /// Highest peak this session — drawn as a vertical tick; only moves up.
  final double? peakMarker;
  final double minHeight;
  final bool showLegend;
  final bool showBandLabel;
  final bool showPeakHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final band = ShotDetectionBand.fromMeter(meter, wouldDetect: wouldDetect);
    final live = meter.clamp(0.0, 1.0);
    final marker = peakMarker?.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showBandLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  'Shot-likeness',
                  style: theme.textTheme.labelSmall,
                ),
                const Spacer(),
                if (marker != null && marker > 0.02) ...[
                  Text(
                    'Peak ${(marker * 100).round()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  band.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: band.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: minHeight,
            child: CustomPaint(
              painter: _ShotMeterPainter(
                live: live,
                peakMarker: marker,
                liveColor: band.color,
              ),
            ),
          ),
        ),
        if (showPeakHint && marker != null && marker > 0.02) ...[
          const SizedBox(height: 4),
          Text(
            'Tick shows where your loudest hit landed — colored by whether it would count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
        if (showLegend) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              _LegendChip(band: ShotDetectionBand.unlikely),
              const SizedBox(width: 8),
              _LegendChip(band: ShotDetectionBand.maybe),
              const SizedBox(width: 8),
              _LegendChip(band: ShotDetectionBand.definite),
            ],
          ),
        ],
      ],
    );
  }
}

class _ShotMeterPainter extends CustomPainter {
  _ShotMeterPainter({
    required this.live,
    required this.peakMarker,
    required this.liveColor,
  });

  final double live;
  final double? peakMarker;
  final Color liveColor;

  static const _zoneOpacity = 0.38;
  static const _liveOverlayOpacity = 0.72;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    canvas.clipRRect(track);

    _drawZone(
      canvas,
      size,
      start: 0,
      end: ShotDetectionBand.maybeThreshold,
      color: ShotDetectionBand.unlikely.color.withValues(alpha: _zoneOpacity),
    );
    _drawZone(
      canvas,
      size,
      start: ShotDetectionBand.maybeThreshold,
      end: ShotDetectionBand.definiteThreshold,
      color: ShotDetectionBand.maybe.color.withValues(alpha: _zoneOpacity),
    );
    _drawZone(
      canvas,
      size,
      start: ShotDetectionBand.definiteThreshold,
      end: 1,
      color: ShotDetectionBand.definite.color.withValues(alpha: _zoneOpacity),
    );

    _drawThresholdTick(
      canvas,
      size,
      at: ShotDetectionBand.maybeThreshold,
    );
    _drawThresholdTick(
      canvas,
      size,
      at: ShotDetectionBand.definiteThreshold,
    );

    if (live > 0) {
      final fillWidth = size.width * live;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        Paint()
          ..color = liveColor.withValues(alpha: _liveOverlayOpacity),
      );
      canvas.drawRect(
        Rect.fromLTWH(max(0, fillWidth - 2), 0, 2, size.height),
        Paint()..color = liveColor,
      );
    }

    final marker = peakMarker;
    if (marker != null && marker > 0.02) {
      final markerBand = ShotDetectionBand.fromMeter(marker);
      final x = size.width * marker;
      final linePaint = Paint()
        ..color = markerBand.color
        ..strokeWidth = 2.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      canvas.drawLine(
        Offset(x - 5, 0),
        Offset(x + 5, 0),
        linePaint..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(x - 5, size.height),
        Offset(x + 5, size.height),
        linePaint..strokeWidth = 3,
      );
    }
  }

  void _drawZone(
    Canvas canvas,
    Size size, {
    required double start,
    required double end,
    required Color color,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * start,
        0,
        size.width * (end - start),
        size.height,
      ),
      Paint()..color = color,
    );
  }

  void _drawThresholdTick(Canvas canvas, Size size, {required double at}) {
    final x = size.width * at;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _ShotMeterPainter oldDelegate) =>
      oldDelegate.live != live ||
      oldDelegate.peakMarker != peakMarker ||
      oldDelegate.liveColor != liveColor;
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.band});

  final ShotDetectionBand band;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: band.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              band.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tracks live meter + session peak marker across sound bursts (setup calibration).
class CalibrationPeakTracker {
  double live = 0;
  double peakMarker = 0;
  double _burstPeak = 0;
  var _inBurst = false;

  static const _soundOn = 0.12;
  static const _soundOff = 0.08;

  void reset() {
    live = 0;
    peakMarker = 0;
    _burstPeak = 0;
    _inBurst = false;
  }

  void ingest(double level, {bool wouldDetect = false}) {
    live = level;

    if (level >= _soundOn) {
      _inBurst = true;
      if (level > _burstPeak) _burstPeak = level;
    } else if (level <= _soundOff && _inBurst) {
      _commitBurst();
    }

    if (wouldDetect && level > peakMarker) {
      peakMarker = level;
    }
  }

  void _commitBurst() {
    if (_burstPeak > peakMarker) {
      peakMarker = _burstPeak;
    }
    _burstPeak = 0;
    _inBurst = false;
  }
}
