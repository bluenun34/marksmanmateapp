import 'dart:math';

import 'package:flutter/material.dart';

import '../services/rifle_level_math.dart';

/// Circular bubble level — dot shows roll/inclination; rings match zones.
class BubbleLevelOverlay extends StatelessWidget {
  const BubbleLevelOverlay({
    super.key,
    required this.rollDeg,
    required this.inclinationDeg,
    required this.zones,
    this.size = 220,
    this.showLabels = true,
    this.onColoredBackground = false,
  });

  final double rollDeg;
  final double inclinationDeg;
  final LevelZoneConfig zones;
  final double size;
  final bool showLabels;
  final bool onColoredBackground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BubbleLevelPainter(
          rollDeg: rollDeg,
          inclinationDeg: inclinationDeg,
          zones: zones,
          showLabels: showLabels,
          onColoredBackground: onColoredBackground,
        ),
      ),
    );
  }
}

class _BubbleLevelPainter extends CustomPainter {
  _BubbleLevelPainter({
    required this.rollDeg,
    required this.inclinationDeg,
    required this.zones,
    required this.showLabels,
    required this.onColoredBackground,
  });

  final double rollDeg;
  final double inclinationDeg;
  final LevelZoneConfig zones;
  final bool showLabels;
  final bool onColoredBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    final labelColor = onColoredBackground
        ? Colors.white.withAlpha(220)
        : const Color(0xFF424242);
    final lineColor = onColoredBackground
        ? Colors.white.withAlpha(160)
        : const Color(0xFFBDBDBD);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = onColoredBackground
            ? Colors.black.withAlpha(45)
            : const Color(0xFFECEFF1)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _zoneRing(canvas, center, radius, zones.greenDeg, LevelDeviationBand.good);
    _zoneRing(canvas, center, radius, zones.yellowDeg, LevelDeviationBand.warn);

    final cross = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(center.dx - radius + 6, center.dy),
      Offset(center.dx + radius - 6, center.dy),
      cross,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 6),
      Offset(center.dx, center.dy + radius - 6),
      cross,
    );

    canvas.drawCircle(
      center,
      6,
      Paint()
        ..color = RifleLevelMath.bandColor(LevelDeviationBand.good).withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    const pxPerDeg = 4.8;
    final dx = (rollDeg * pxPerDeg).clamp(-radius + 18, radius - 18);
    final dy = (-inclinationDeg * pxPerDeg).clamp(-radius + 18, radius - 18);
    final bubbleCenter = center + Offset(dx, dy);

    final deviation =
        LevelZoneConfig.combinedDeviation(rollDeg, inclinationDeg);
    final band = zones.bandForDeviation(deviation);

    canvas.drawCircle(
      bubbleCenter + const Offset(0, 2),
      16,
      Paint()..color = Colors.black.withAlpha(50),
    );
    canvas.drawCircle(
      bubbleCenter,
      16,
      Paint()
        ..color = RifleLevelMath.bandColor(band).withAlpha(240)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      bubbleCenter,
      16,
      Paint()
        ..color = Colors.white.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (showLabels) {
      _label(
        canvas,
        center + Offset(0, -radius + 16),
        'Inc ${_fmt(inclinationDeg)}',
        labelColor,
      );
      _label(
        canvas,
        center + Offset(-radius + 40, center.dy + 4),
        'Roll ${_fmt(rollDeg)}',
        labelColor,
      );
    }
  }

  void _zoneRing(
    Canvas canvas,
    Offset center,
    double radius,
    double zoneDeg,
    LevelDeviationBand band,
  ) {
    const pxPerDeg = 4.8;
    final r = (zoneDeg * pxPerDeg).clamp(12.0, radius - 8);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = RifleLevelMath.bandColor(band).withAlpha(
              band == LevelDeviationBand.good ? 120 : 70,
            )
        ..style = PaintingStyle.stroke
        ..strokeWidth = band == LevelDeviationBand.good ? 2.5 : 1.5,
    );
  }

  void _label(Canvas canvas, Offset at, String text, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  String _fmt(double deg) {
    final sign = deg >= 0 ? '+' : '';
    return '$sign${deg.toStringAsFixed(1)}°';
  }

  @override
  bool shouldRepaint(covariant _BubbleLevelPainter oldDelegate) =>
      oldDelegate.rollDeg != rollDeg ||
      oldDelegate.inclinationDeg != inclinationDeg ||
      oldDelegate.zones.greenDeg != zones.greenDeg ||
      oldDelegate.zones.yellowDeg != zones.yellowDeg ||
      oldDelegate.showLabels != showLabels ||
      oldDelegate.onColoredBackground != onColoredBackground;
}
