import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../services/rifle_level_math.dart';

/// Classic liquid-in-glass bubble level — sloshing fill + lazy bubble (iBeer / HSCN style).
class LiquidBubbleLevel extends StatefulWidget {
  const LiquidBubbleLevel({
    super.key,
    required this.rollDeg,
    required this.inclinationDeg,
    required this.zones,
    this.size = 260,
    this.rollOnly = true,
    this.showTenths = false,
    this.onColoredBackground = false,
  });

  final double rollDeg;
  final double inclinationDeg;
  final LevelZoneConfig zones;
  final double size;
  final bool rollOnly;
  final bool showTenths;
  final bool onColoredBackground;

  @override
  State<LiquidBubbleLevel> createState() => _LiquidBubbleLevelState();
}

class _LiquidBubbleLevelState extends State<LiquidBubbleLevel>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastTick = Duration.zero;

  final _bubbleX = _SpringChannel();
  final _bubbleY = _SpringChannel();
  final _liquidAngle = _SpringChannel();
  final _liquidLevel = _SpringChannel(initial: 0.52);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.001, 0.05);
    _lastTick = elapsed;

    const pxPerDeg = 0.028;
    final targetX = (widget.rollDeg * pxPerDeg).clamp(-0.42, 0.42);
    final incl = widget.rollOnly ? 0.0 : widget.inclinationDeg;
    final targetY = (-incl * pxPerDeg).clamp(-0.42, 0.42);
    final targetAngle = widget.rollOnly
        ? 0.0
        : atan2(-widget.inclinationDeg, widget.rollDeg == 0 ? 0.001 : widget.rollDeg);

    _bubbleX.step(targetX, dt, stiffness: 28, damping: 8);
    _bubbleY.step(targetY, dt, stiffness: 28, damping: 8);
    _liquidAngle.step(targetAngle, dt, stiffness: 16, damping: 6);
    _liquidLevel.step(0.52, dt, stiffness: 16, damping: 4);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviation = widget.rollOnly
        ? widget.rollDeg.abs()
        : LevelZoneConfig.combinedDeviation(
            widget.rollDeg,
            widget.inclinationDeg,
          );
    final band = widget.zones.bandForDeviation(deviation);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _LiquidBubblePainter(
          bubbleNorm: Offset(_bubbleX.value, _bubbleY.value),
          liquidAngle: _liquidAngle.value,
          liquidLevel: _liquidLevel.value,
          band: band,
          zones: widget.zones,
          rollOnly: widget.rollOnly,
          onColoredBackground: widget.onColoredBackground,
        ),
      ),
    );
  }
}

class _SpringChannel {
  _SpringChannel({double initial = 0}) : value = initial;

  double value;
  double _velocity = 0;

  void step(
    double target,
    double dt, {
    required double stiffness,
    required double damping,
  }) {
    final displacement = target - value;
    _velocity += displacement * stiffness * dt;
    _velocity *= exp(-damping * dt);
    value += _velocity * dt;
  }
}

class _LiquidBubblePainter extends CustomPainter {
  _LiquidBubblePainter({
    required this.bubbleNorm,
    required this.liquidAngle,
    required this.liquidLevel,
    required this.band,
    required this.zones,
    required this.rollOnly,
    required this.onColoredBackground,
  });

  final Offset bubbleNorm;
  final double liquidAngle;
  final double liquidLevel;
  final LevelDeviationBand band;
  final LevelZoneConfig zones;
  final bool rollOnly;
  final bool onColoredBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    _drawGlass(canvas, center, radius);
    _drawLiquid(canvas, center, radius);
    _drawTargetRings(canvas, center, radius);
    _drawBubble(canvas, center, radius);
  }

  void _drawGlass(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius + 3,
      Paint()
        ..color = Colors.black.withAlpha(35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            onColoredBackground
                ? Colors.white.withAlpha(30)
                : const Color(0xFFF5F5F5),
            onColoredBackground
                ? Colors.black.withAlpha(55)
                : const Color(0xFFB0BEC5),
          ],
          stops: const [0.55, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = onColoredBackground
            ? Colors.white.withAlpha(180)
            : const Color(0xFF78909C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // Glass highlight
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -2.4,
      1.2,
      false,
      Paint()
        ..color = Colors.white.withAlpha(90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLiquid(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    canvas.translate(center.dx, center.dy);
    canvas.rotate(liquidAngle);

    final fillHeight = radius * 2 * liquidLevel;
    final surfaceY = radius - fillHeight;
    final liquidRect = Rect.fromLTRB(-radius, surfaceY, radius, radius);

    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          RifleLevelMath.bandColor(LevelDeviationBand.good).withAlpha(210),
          RifleLevelMath.bandColor(LevelDeviationBand.good).withAlpha(255),
        ],
      ).createShader(liquidRect);

    canvas.drawRect(liquidRect, liquidPaint);

    // Meniscus shimmer on surface
    canvas.drawLine(
      Offset(-radius + 4, surfaceY),
      Offset(radius - 4, surfaceY),
      Paint()
        ..color = Colors.white.withAlpha(120)
        ..strokeWidth = 2.5,
    );

    canvas.restore();
  }

  void _drawTargetRings(Canvas canvas, Offset center, double radius) {
    final pxPerDeg = rollOnly ? 5.2 : 4.6;
    for (final (deg, band) in [
      (zones.greenDeg, LevelDeviationBand.good),
      (zones.yellowDeg, LevelDeviationBand.warn),
    ]) {
      final r = (deg * pxPerDeg).clamp(10.0, radius - 12);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = RifleLevelMath.bandColor(band).withAlpha(90)
          ..style = PaintingStyle.stroke
          ..strokeWidth = band == LevelDeviationBand.good ? 2 : 1.2,
      );
    }
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = RifleLevelMath.bandColor(LevelDeviationBand.good).withAlpha(160)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawBubble(Canvas canvas, Offset center, double radius) {
    final bubbleR = radius * 0.11;
    final pos = center + Offset(bubbleNorm.dx * radius, bubbleNorm.dy * radius);

    canvas.drawCircle(
      pos + const Offset(0, 2),
      bubbleR,
      Paint()..color = Colors.black.withAlpha(45),
    );

    final bubbleColor = RifleLevelMath.bandColor(band);
    canvas.drawCircle(
      pos,
      bubbleR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withAlpha(230),
            bubbleColor.withAlpha(240),
            bubbleColor,
          ],
          stops: const [0.0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: pos, radius: bubbleR)),
    );
    canvas.drawCircle(
      pos,
      bubbleR,
      Paint()
        ..color = Colors.white.withAlpha(140)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      pos + Offset(-bubbleR * 0.35, -bubbleR * 0.35),
      bubbleR * 0.22,
      Paint()..color = Colors.white.withAlpha(200),
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidBubblePainter oldDelegate) => true;
}
