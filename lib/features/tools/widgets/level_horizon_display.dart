import 'dart:math';

import 'package:flutter/material.dart';

import '../services/rifle_level_math.dart';

/// Clinometer horizon — green/amber/red fill; fixed dark number colour.
class LevelHorizonDisplay extends StatelessWidget {
  const LevelHorizonDisplay({
    super.key,
    required this.rollDeg,
    required this.inclinationDeg,
    required this.band,
    required this.calibrated,
    required this.settings,
  });

  /// Number and tick colour — fixed (amber-zone style), never changes with band.
  static const horizonText = Color(0xDE000000);
  static const horizonAccent = Color(0xFF5D4037);

  /// Back-compat aliases for corner controls.
  static const horizonFill = Color(0xFFFFB300);
  static const accentBlue = horizonAccent;

  final double rollDeg;
  final double inclinationDeg;
  final LevelDeviationBand band;
  final bool calibrated;
  final LevelSettings settings;

  Color get _fillColor => RifleLevelMath.bandSurface(band, calibrated: calibrated);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _HorizonLevelPainter(
                rollDeg: rollDeg,
                fillColor: _fillColor,
                accentColor: horizonAccent,
              ),
              size: size,
            ),
            Center(
              child: Text(
                LevelFormat.rollDisplay(rollDeg, tenths: settings.showTenths),
                style: const TextStyle(
                  fontSize: 96,
                  height: 1,
                  fontWeight: FontWeight.w200,
                  color: horizonText,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (settings.showInclination)
              Positioned(
                left: 0,
                right: 0,
                bottom: max(88, size.height * 0.14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Inc ${LevelFormat.rollDisplay(inclinationDeg, tenths: settings.showTenths)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: horizonText,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HorizonLevelPainter extends CustomPainter {
  _HorizonLevelPainter({
    required this.rollDeg,
    required this.fillColor,
    required this.accentColor,
  });

  final double rollDeg;
  final Color fillColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rollDeg * pi / 180);
    canvas.translate(-center.dx, -center.dy);

    final lower = Path()
      ..moveTo(-size.width * 2, center.dy)
      ..lineTo(size.width * 3, center.dy)
      ..lineTo(size.width * 3, size.height * 3)
      ..lineTo(-size.width * 2, size.height * 3)
      ..close();
    canvas.drawPath(lower, Paint()..color = fillColor);
    canvas.restore();

    _drawEdgeTicks(canvas, size);
  }

  void _drawEdgeTicks(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const tick = 18.0;
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawLine(Offset(cx, 0), Offset(cx, tick), paint);
    canvas.drawLine(Offset(cx, size.height - tick), Offset(cx, size.height), paint);
    canvas.drawLine(Offset(0, cy), Offset(tick, cy), paint);
    canvas.drawLine(Offset(size.width - tick, cy), Offset(size.width, cy), paint);
  }

  @override
  bool shouldRepaint(covariant _HorizonLevelPainter oldDelegate) =>
      oldDelegate.rollDeg != rollDeg || oldDelegate.fillColor != fillColor;
}
