import 'package:flutter/material.dart';

import '../models/paper_target_type.dart';

/// Schematic preview of a paper target (rings / bull) for the catalog.
class TargetTypePreview extends StatelessWidget {
  const TargetTypePreview({
    super.key,
    required this.target,
    this.size = 72,
    this.borderRadius = 8,
  });

  final PaperTargetType target;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _TargetFacePainter(target: target),
        ),
      ),
    );
  }
}

class _TargetFacePainter extends CustomPainter {
  const _TargetFacePainter({required this.target});

  final PaperTargetType target;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFFF5F5F0));

    final center = Offset(size.width / 2, size.height / 2);
    final maxD = target.previewRingDiametersMm.first;
    final scale = (size.shortestSide * 0.92) / maxD;

    for (final diameterMm in target.previewRingDiametersMm) {
      final radius = diameterMm * scale / 2;
      final isOuter = diameterMm == maxD;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = isOuter ? const Color(0xFF1A1A1A) : const Color(0xFF2E2E2E)
          ..style = isOuter ? PaintingStyle.stroke : PaintingStyle.fill
          ..strokeWidth = isOuter ? 1.5 : 0,
      );
    }

    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TargetFacePainter oldDelegate) =>
      oldDelegate.target.id != target.id;
}
