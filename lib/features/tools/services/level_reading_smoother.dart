import 'rifle_level_math.dart';

/// Extra low-pass on roll/inclination so on-screen numbers settle slowly.
class LevelReadingSmoother {
  LevelReadingSmoother({this.alpha = 0.055});

  final double alpha;
  var _initialised = false;
  double _roll = 0;
  double _inclination = 0;

  RifleLevelReading smooth(RifleLevelReading raw) {
    if (!_initialised) {
      _roll = raw.rollDeg;
      _inclination = raw.inclinationDeg;
      _initialised = true;
      return raw;
    }

    _roll += (raw.rollDeg - _roll) * alpha;
    _inclination += (raw.inclinationDeg - _inclination) * alpha;

    return RifleLevelReading(
      rollDeg: _roll,
      inclinationDeg: _inclination,
      azimuthDeg: raw.azimuthDeg,
    );
  }

  void reset() {
    _initialised = false;
    _roll = 0;
    _inclination = 0;
  }
}
