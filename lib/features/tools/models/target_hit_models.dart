import 'package:flutter/material.dart';

import '../services/group_size_calculator.dart';

/// A shot group marked on the target photo (e.g. a 5-round string).
class TargetHitGroup {
  const TargetHitGroup({
    required this.id,
    required this.name,
    required this.color,
  });

  final int id;
  final String name;
  final Color color;

  static const defaultPalette = <Color>[
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
  ];

  static TargetHitGroup named(int index) {
    final palette = defaultPalette;
    return TargetHitGroup(
      id: index,
      name: 'Group ${String.fromCharCode(65 + index)}',
      color: palette[index % palette.length],
    );
  }
}

class MarkedHit {
  const MarkedHit({
    required this.position,
    required this.groupId,
  });

  final Offset position;
  final int groupId;
}

class TargetGroupAnalysis {
  const TargetGroupAnalysis({
    required this.group,
    required this.result,
  });

  final TargetHitGroup group;
  final GroupSizeResult result;
}
