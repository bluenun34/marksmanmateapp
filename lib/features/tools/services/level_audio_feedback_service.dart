import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

import 'range_beep.dart';
import 'rifle_level_math.dart';

/// Speaker / earbud proximity feedback — fast/quiet near zero, slow/loud far off.
class LevelAudioFeedbackService {
  Timer? _pollTimer;
  LevelDeviationBand? _lastBand;
  DateTime _lastBeepAt = DateTime.fromMillisecondsSinceEpoch(0);
  var _tickInFlight = false;
  var _smoothedIntervalMs = 800.0;

  double _deviation = 0;
  double _rollDeg = 0;
  LevelZoneConfig _zones = const LevelZoneConfig();
  LevelSettings _settings = const LevelSettings();
  var _calibrated = false;

  void update({
    required double deviationDeg,
    required double rollDeg,
    required LevelZoneConfig zones,
    required LevelSettings settings,
    required bool calibrated,
  }) {
    _deviation = deviationDeg;
    _rollDeg = rollDeg;
    _zones = zones;
    _settings = settings;
    _calibrated = calibrated;

    if (!settings.audioEnabled || !calibrated) {
      _lastBand = null;
      return;
    }

    _pollTimer ??= Timer.periodic(const Duration(milliseconds: 80), (_) {
      unawaited(_poll());
    });
  }

  Future<void> _poll() async {
    if (!_settings.audioEnabled || !_calibrated) return;

    final band = _zones.bandForDeviation(_deviation);

    if (band == LevelDeviationBand.good) {
      if (_settings.chirpOnLevel &&
          _lastBand != null &&
          _lastBand != LevelDeviationBand.good) {
        await RangeBeep.playLevelSuccess(volume: _settings.audioVolume);
        HapticFeedback.lightImpact();
      }
      _lastBand = band;
      return;
    }

    _lastBand = band;

    final targetMs = _targetIntervalMs(_deviation);
    _smoothedIntervalMs = _smoothedIntervalMs * 0.75 + targetMs * 0.25;

    final since = DateTime.now().difference(_lastBeepAt).inMilliseconds;
    if (since < _smoothedIntervalMs.round() || _tickInFlight) return;

    _tickInFlight = true;
    _lastBeepAt = DateTime.now();

    final maxDev = max(_zones.yellowDeg, _zones.greenDeg + 0.5);

    if (_settings.audioMode == LevelAudioMode.stereoEarbuds) {
      await RangeBeep.playLevelTickStereo(
        rollDeg: _rollDeg,
        deviationDeg: _deviation,
        maxDeviationDeg: maxDev,
        volume: _settings.audioVolume,
      );
    } else {
      await RangeBeep.playLevelTick(
        deviationDeg: _deviation,
        maxDeviationDeg: maxDev,
        volume: _settings.audioVolume,
      );
    }

    _tickInFlight = false;
  }

  /// Near zero → short interval (fast). Far off → long interval (slow).
  double _targetIntervalMs(double deviation) {
    final maxDev = max(_zones.yellowDeg, _zones.greenDeg + 0.5);
    final t = (deviation / maxDev).clamp(0.0, 1.0);
    return 110 + t * t * 990;
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _lastBand = null;
    _tickInFlight = false;
    _smoothedIntervalMs = 800;
  }

  void dispose() => stop();
}
