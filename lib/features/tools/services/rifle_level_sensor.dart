import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import 'rifle_level_math.dart';

/// Streams smoothed rifle level readings from phone sensors.
class RifleLevelSensor {
  RifleLevelSensor({this.smoothing = 0.07});

  final double smoothing;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  final _controller = StreamController<RifleLevelReading>.broadcast();

  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  double _mx = 0;
  double _my = 0;
  double _mz = 0;
  var _hasMag = false;

  MountProfile mount = MountProfile.defaultMount;

  Stream<RifleLevelReading> get readings => _controller.stream;

  void start() {
    _accelSub ??= accelerometerEventStream().listen((e) {
      _ax = _lerp(_ax, e.x, smoothing);
      _ay = _lerp(_ay, e.y, smoothing);
      _az = _lerp(_az, e.z, smoothing);
      _emit();
    });
    _magSub ??= magnetometerEventStream().listen((e) {
      _mx = _lerp(_mx, e.x, smoothing);
      _my = _lerp(_my, e.y, smoothing);
      _mz = _lerp(_mz, e.z, smoothing);
      _hasMag = true;
      _emit();
    });
  }

  void stop() {
    try {
      _accelSub?.cancel();
    } on Object {
      // Hot restart can leave the plugin channel unavailable.
    }
    _accelSub = null;
    try {
      _magSub?.cancel();
    } on Object {
      // Hot restart can leave the plugin channel unavailable.
    }
    _magSub = null;
  }

  Future<void> dispose() async {
    stop();
    await _controller.close();
  }

  RifleLevelReading get snapshot => RifleLevelMath.fromSensors(
        ax: _ax,
        ay: _ay,
        az: _az,
        mx: _hasMag ? _mx : 0,
        my: _hasMag ? _my : 1,
        mz: _hasMag ? _mz : 0,
        mount: mount,
      );

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(snapshot);
  }

  double _lerp(double from, double to, double t) => from + (to - from) * t;
}

/// Averages readings over [duration] for calibration capture.
Future<RifleLevelReading> averageReading(
  RifleLevelSensor sensor, {
  Duration duration = const Duration(milliseconds: 600),
}) async {
  final samples = <RifleLevelReading>[];
  final sub = sensor.readings.listen(samples.add);
  await Future<void>.delayed(duration);
  await sub.cancel();

  if (samples.isEmpty) return sensor.snapshot;

  double roll = 0;
  double pitch = 0;
  double sinSum = 0;
  double cosSum = 0;

  for (final s in samples) {
    roll += s.rollDeg;
    pitch += s.inclinationDeg;
    final rad = s.azimuthDeg * pi / 180;
    sinSum += sin(rad);
    cosSum += cos(rad);
  }

  final n = samples.length;
  final az = atan2(sinSum / n, cosSum / n) * 180 / pi;

  return RifleLevelReading(
    rollDeg: roll / n,
    inclinationDeg: pitch / n,
    azimuthDeg: az < 0 ? az + 360 : az,
  );
}
