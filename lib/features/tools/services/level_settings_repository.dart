import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'rifle_level_math.dart';
import 'rifle_level_sensor.dart';

/// Persists calibration offsets and user settings.
class LevelSettingsRepository {
  static const _calKey = 'rifle_level_calibration';
  static const _greenKey = 'rifle_level_green_deg';
  static const _yellowKey = 'rifle_level_yellow_deg';
  static const _customGreenKey = 'rifle_level_custom_green';
  static const _modeKey = 'rifle_level_mode';
  static const _rollKey = 'rifle_level_show_roll';
  static const _inclKey = 'rifle_level_show_inclination';
  static const _bubbleKey = 'rifle_level_show_bubble';
  static const _colorKey = 'rifle_level_show_color';
  static const _calStatusKey = 'rifle_level_show_cal_status';
  static const _audioKey = 'rifle_level_audio';
  static const _audioModeKey = 'rifle_level_audio_mode';
  static const _volumeKey = 'rifle_level_volume';
  static const _chirpKey = 'rifle_level_chirp';
  static const _hapticKey = 'rifle_level_haptic';
  static const _wakelockKey = 'rifle_level_wakelock';
  static const _tenthsKey = 'rifle_level_show_tenths';

  Future<LevelCalibration> loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    final calJson = prefs.getString(_calKey);
    if (calJson == null) return const LevelCalibration();
    final parts = calJson.split('|');
    if (parts.length != 3) return const LevelCalibration();
    return LevelCalibration(
      rollOffset: double.tryParse(parts[0]) ?? 0,
      inclinationOffset: double.tryParse(parts[1]) ?? 0,
      azimuthOffset: double.tryParse(parts[2]) ?? 0,
    );
  }

  Future<bool> hasCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_calKey);
  }

  Future<void> saveCalibration(LevelCalibration cal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _calKey,
      '${cal.rollOffset}|${cal.inclinationOffset}|${cal.azimuthOffset}',
    );
  }

  Future<void> clearCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_calKey);
  }

  Future<LevelSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final green = prefs.getDouble(_greenKey) ?? 0.5;
    var yellow = prefs.getDouble(_yellowKey) ?? 2.0;
    if (yellow <= green) yellow = green + 1.0;

    final modeIdx = prefs.getInt(_modeKey) ?? 0;

    return LevelSettings(
      mode: LevelDisplayMode.values[modeIdx.clamp(0, 1)],
      zones: LevelZoneConfig(greenDeg: green, yellowDeg: yellow),
      customGreen: prefs.getBool(_customGreenKey) ?? false,
      showRoll: prefs.getBool(_rollKey) ?? true,
      showInclination: prefs.getBool(_inclKey) ?? true,
      showBubble: prefs.getBool(_bubbleKey) ?? false,
      showColorBars: prefs.getBool(_colorKey) ?? false,
      showCalibrationStatus: prefs.getBool(_calStatusKey) ?? true,
      showTenths: prefs.getBool(_tenthsKey) ?? false,
      audioEnabled: prefs.getBool(_audioKey) ?? false,
      audioMode: LevelAudioMode.values[
          (prefs.getInt(_audioModeKey) ?? 0).clamp(0, LevelAudioMode.values.length - 1)],
      audioVolume: prefs.getDouble(_volumeKey) ?? 1.0,
      chirpOnLevel: prefs.getBool(_chirpKey) ?? true,
      hapticEnabled: prefs.getBool(_hapticKey) ?? false,
      keepScreenAwake: prefs.getBool(_wakelockKey) ?? true,
    );
  }

  Future<void> saveSettings(LevelSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_greenKey, settings.zones.greenDeg);
    await prefs.setDouble(_yellowKey, settings.zones.yellowDeg);
    await prefs.setBool(_customGreenKey, settings.customGreen);
    await prefs.setInt(_modeKey, settings.mode.index);
    await prefs.setBool(_rollKey, settings.showRoll);
    await prefs.setBool(_inclKey, settings.showInclination);
    await prefs.setBool(_bubbleKey, settings.showBubble);
    await prefs.setBool(_colorKey, settings.showColorBars);
    await prefs.setBool(_calStatusKey, settings.showCalibrationStatus);
    await prefs.setBool(_tenthsKey, settings.showTenths);
    await prefs.setBool(_audioKey, settings.audioEnabled);
    await prefs.setInt(_audioModeKey, settings.audioMode.index);
    await prefs.setDouble(_volumeKey, settings.audioVolume);
    await prefs.setBool(_chirpKey, settings.chirpOnLevel);
    await prefs.setBool(_hapticKey, settings.hapticEnabled);
    await prefs.setBool(_wakelockKey, settings.keepScreenAwake);
  }
}

/// Captures averaged sensor reading as calibration zero.
class LevelCalibrationService {
  LevelCalibrationService(this._repo);

  final LevelSettingsRepository _repo;

  Future<LevelCalibration> captureZero(RifleLevelSensor sensor) async {
    final avg = await averageReading(sensor);
    final cal = LevelCalibration(
      rollOffset: avg.rollDeg,
      inclinationOffset: avg.inclinationDeg,
      azimuthOffset: avg.azimuthDeg,
    );
    await _repo.saveCalibration(cal);
    return cal;
  }

  Future<void> clear() => _repo.clearCalibration();
}
