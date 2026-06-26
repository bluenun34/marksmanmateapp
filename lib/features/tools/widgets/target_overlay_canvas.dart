import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/target_hit_models.dart';

enum TargetOverlayMode { markHits, results }

/// Pinch-zoomable target photo with coloured hit markers.
class TargetOverlayView extends StatefulWidget {
  const TargetOverlayView({
    super.key,
    required this.imageBytes,
    required this.markedHits,
    required this.groups,
    required this.onTapImage,
    this.onRemoveHit,
    this.activeGroupId,
    this.extremePairsByGroup = const {},
    this.mode = TargetOverlayMode.markHits,
    this.readOnly = false,
    this.enableZoom = true,
  });

  final Uint8List imageBytes;
  final List<MarkedHit> markedHits;
  final List<TargetHitGroup> groups;
  final Map<int, (Offset, Offset)> extremePairsByGroup;
  final int? activeGroupId;
  final TargetOverlayMode mode;
  final bool readOnly;
  final bool enableZoom;
  final void Function(Offset imageSpacePoint) onTapImage;
  final void Function(int hitIndex)? onRemoveHit;

  @override
  State<TargetOverlayView> createState() => _TargetOverlayViewState();
}

class _TargetOverlayViewState extends State<TargetOverlayView> {
  ui.Image? _image;
  Size? _imageSize;
  final _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TargetOverlayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageBytes != widget.imageBytes) _decodeImage();
  }

  Future<void> _decodeImage() async {
    final image = await decodeImageFromList(widget.imageBytes);
    if (!mounted) return;
    setState(() {
      _image = image;
      _imageSize = Size(image.width.toDouble(), image.height.toDouble());
    });
  }

  Color _colorForGroup(int groupId) {
    return widget.groups
            .firstWhere(
              (g) => g.id == groupId,
              orElse: () => TargetHitGroup.named(groupId),
            )
            .color;
  }

  void _handleTapDown(TapDownDetails details, Size viewportSize) {
    if (widget.readOnly || _imageSize == null) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(details.globalPosition);
    final inverse = Matrix4.inverted(_transformController.value);
    final transformed = MatrixUtils.transformPoint(inverse, local);

    final imagePoint = _mapDisplayToImage(
      transformed,
      viewportSize,
      _imageSize!,
    );
    if (imagePoint == null) return;

    if (widget.onRemoveHit != null && widget.markedHits.isNotEmpty) {
      final scale = _transformController.value.getMaxScaleOnAxis();
      final removeRadius = _displayRadiusToImagePx(
        displayRadius: 22 / scale,
        viewportSize: viewportSize,
        imageSize: _imageSize!,
      );
      var nearestIndex = -1;
      var nearestDist = double.infinity;
      for (var i = 0; i < widget.markedHits.length; i++) {
        final d = (widget.markedHits[i].position - imagePoint).distance;
        if (d < removeRadius && d < nearestDist) {
          nearestDist = d;
          nearestIndex = i;
        }
      }
      if (nearestIndex >= 0) {
        widget.onRemoveHit!(nearestIndex);
        return;
      }
    }

    widget.onTapImage(imagePoint);
  }

  static Offset? _mapDisplayToImage(
    Offset displayPoint,
    Size displaySize,
    Size imageSize,
  ) {
    final fitted = applyBoxFit(BoxFit.contain, imageSize, displaySize);
    final dest = fitted.destination;
    final dx = (displaySize.width - dest.width) / 2;
    final dy = (displaySize.height - dest.height) / 2;
    final x = displayPoint.dx - dx;
    final y = displayPoint.dy - dy;
    if (x < 0 || y < 0 || x > dest.width || y > dest.height) return null;
    return Offset(
      x / dest.width * imageSize.width,
      y / dest.height * imageSize.height,
    );
  }

  static double _displayRadiusToImagePx({
    required double displayRadius,
    required Size viewportSize,
    required Size imageSize,
  }) {
    final fitted = applyBoxFit(BoxFit.contain, imageSize, viewportSize);
    return displayRadius / fitted.destination.width * imageSize.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final painter = _TargetOverlayPainter(
          image: _image,
          imageSize: _imageSize,
          markedHits: widget.markedHits,
          colorForGroup: _colorForGroup,
          extremePairsByGroup: widget.extremePairsByGroup,
          activeGroupId: widget.activeGroupId,
        );

        final canvas = GestureDetector(
          onTapDown: widget.readOnly
              ? null
              : (details) => _handleTapDown(details, size),
          child: CustomPaint(
            painter: painter,
            child: SizedBox(width: size.width, height: size.height),
          ),
        );

        if (!widget.enableZoom) return canvas;

        return InteractiveViewer(
          transformationController: _transformController,
          minScale: 1,
          maxScale: 6,
          panEnabled: true,
          scaleEnabled: true,
          boundaryMargin: const EdgeInsets.all(80),
          child: canvas,
        );
      },
    );
  }
}

class _TargetOverlayPainter extends CustomPainter {
  _TargetOverlayPainter({
    required this.image,
    required this.imageSize,
    required this.markedHits,
    required this.colorForGroup,
    required this.extremePairsByGroup,
    this.activeGroupId,
  });

  final ui.Image? image;
  final Size? imageSize;
  final List<MarkedHit> markedHits;
  final Color Function(int groupId) colorForGroup;
  final Map<int, (Offset, Offset)> extremePairsByGroup;
  final int? activeGroupId;

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null || imageSize == null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black26);
      return;
    }

    final fitted = applyBoxFit(BoxFit.contain, imageSize!, size);
    final dest = fitted.destination;
    final dx = (size.width - dest.width) / 2;
    final dy = (size.height - dest.height) / 2;
    final destRect = Rect.fromLTWH(dx, dy, dest.width, dest.height);

    canvas.drawImageRect(
      image!,
      Rect.fromLTWH(0, 0, imageSize!.width, imageSize!.height),
      destRect,
      Paint(),
    );

    Offset map(Offset p) => Offset(
          dx + p.dx / imageSize!.width * dest.width,
          dy + p.dy / imageSize!.height * dest.height,
        );

    for (final hit in markedHits) {
      final color = colorForGroup(hit.groupId);
      final isActive = hit.groupId == activeGroupId;
      _drawHit(canvas, map(hit.position), color, emphasized: isActive);
    }

    for (final entry in extremePairsByGroup.entries) {
      final color = colorForGroup(entry.key);
      final a = map(entry.value.$1);
      final b = map(entry.value.$2);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color.withValues(alpha: 0.9)
          ..strokeWidth = 2.5,
      );
    }
  }

  void _drawHit(
    Canvas canvas,
    Offset center,
    Color color, {
    bool emphasized = false,
  }) {
    final radius = emphasized ? 16.0 : 14.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = emphasized ? 3 : 2.5,
    );
    canvas.drawCircle(center, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TargetOverlayPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.markedHits != markedHits ||
        oldDelegate.extremePairsByGroup != extremePairsByGroup ||
        oldDelegate.activeGroupId != activeGroupId;
  }
}
