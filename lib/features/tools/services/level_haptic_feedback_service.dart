import 'dart:async';

import 'package:flutter/services.dart';

import 'rifle_level_math.dart';

/// Vibration feedback — fast off-level, slow when close, silent when level.
class LevelHapticFeedbackService {
  Timer? _timer;
  DateTime _lastPulse = DateTime.fromMillisecondsSinceEpoch(0);
  var _deviation = 0.0;
  var _enabled = false;
  var _calibrated = false;
  LevelZoneConfig _zones = const LevelZoneConfig();

  void update({
    required double deviationDeg,
    required LevelZoneConfig zones,
    required bool enabled,
    required bool calibrated,
  }) {
    _deviation = deviationDeg;
    _zones = zones;
    _enabled = enabled;
    _calibrated = calibrated;

    if (!enabled || !calibrated) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    _timer ??= Timer.periodic(const Duration(milliseconds: 100), (_) => _pulse());
  }

  void _pulse() {
    if (!_enabled || !_calibrated) return;

    if (_zones.bandForDeviation(_deviation) == LevelDeviationBand.good) return;

    final intervalMs = _deviation > 3
        ? 220
        : _deviation > 1
            ? 520
            : 900;

    final since = DateTime.now().difference(_lastPulse).inMilliseconds;
    if (since < intervalMs) return;

    _lastPulse = DateTime.now();
    if (_deviation > 3) {
      HapticFeedback.heavyImpact();
    } else if (_deviation > 1) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => stop();
}
