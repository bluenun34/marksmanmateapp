import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../shoot_log/widgets/session_photo_picker.dart';
import '../models/target_hit_models.dart';

/// Renders hit markers (and group spread lines) onto the target photo.
class TargetAnnotatedImage {
  TargetAnnotatedImage._();

  static Future<SessionPhotoDraft?> render({
    required Uint8List imageBytes,
    required List<MarkedHit> markedHits,
    required List<TargetHitGroup> groups,
    Map<int, (Offset, Offset)> extremePairsByGroup = const {},
  }) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final width = image.width;
    final height = image.height;
    final strokeScale = width / 400.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());

    Color colorForGroup(int groupId) {
      return groups
          .firstWhere(
            (g) => g.id == groupId,
            orElse: () => TargetHitGroup.named(groupId),
          )
          .color;
    }

    for (final entry in extremePairsByGroup.entries) {
      final color = colorForGroup(entry.key);
      canvas.drawLine(
        entry.value.$1,
        entry.value.$2,
        Paint()
          ..color = color.withValues(alpha: 0.9)
          ..strokeWidth = 2.5 * strokeScale,
      );
    }

    for (final hit in markedHits) {
      _drawHit(canvas, hit.position, colorForGroup(hit.groupId), strokeScale);
    }

    final picture = recorder.endRecording();
    final output = await picture.toImage(width, height);
    final byteData =
        await output.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    output.dispose();
    if (byteData == null) return null;

    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/target_group_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(bytes);
    return SessionPhotoDraft(file: XFile(path), previewBytes: bytes);
  }

  static void _drawHit(
    Canvas canvas,
    Offset center,
    Color color,
    double strokeScale,
  ) {
    final radius = 14.0 * strokeScale;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * strokeScale,
    );
    canvas.drawCircle(center, 3.5 * strokeScale, Paint()..color = color);
  }
}
