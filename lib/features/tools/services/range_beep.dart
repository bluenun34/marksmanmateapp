import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Loud range tones designed to cut through electronic ear defenders.
class RangeBeep {
  RangeBeep._();

  static final AudioPlayer _player = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static var _mediaContextReady = false;
  static var _alarmContextReady = false;

  static Future<void> _ensureMediaContext() async {
    if (_mediaContextReady) return;
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          audioMode: AndroidAudioMode.normal,
          usageType: AndroidUsageType.media,
          contentType: AndroidContentType.music,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playAndRecord,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
      ),
    );
    _mediaContextReady = true;
  }

  static Future<void> _ensureAlarmContext() async {
    if (_alarmContextReady) return;
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          audioMode: AndroidAudioMode.normal,
          usageType: AndroidUsageType.alarm,
          contentType: AndroidContentType.sonification,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    _alarmContextReady = true;
  }

  /// Double high-tone alert — start shooting.
  static Future<bool> playStart() => _playSequence([
        _Tone(frequencyHz: 1400, durationMs: 320, amplitude: 1),
        _Tone(frequencyHz: 2100, durationMs: 380, amplitude: 1),
      ]);

  /// Triple tone — par / time up.
  static Future<bool> playPar() => _playSequence([
        _Tone(frequencyHz: 1100, durationMs: 180, amplitude: 1),
        _Tone(frequencyHz: 1100, durationMs: 180, amplitude: 1),
        _Tone(frequencyHz: 1600, durationMs: 420, amplitude: 1),
      ]);

  /// Preview during setup. Returns true if audio likely played.
  static Future<bool> playTest() => playStart();

  /// Proximity tick — quiet/fast when close to zero, loud/slow when far off.
  static Future<bool> playLevelTick({
    double deviationDeg = 1,
    double maxDeviationDeg = 3,
    double volume = 1,
  }) {
    final t = (deviationDeg / maxDeviationDeg).clamp(0.0, 1.0);
    final freq = 1100 + t * 1900;
    return _playSingleTone(
      frequencyHz: freq,
      durationMs: (45 + t * 55).round(),
      amplitude: (0.15 + t * 0.85) * volume,
    );
  }

  /// Stereo tick — pan by roll sign (earbud mode MVP).
  static Future<bool> playLevelTickStereo({
    required double rollDeg,
    required double deviationDeg,
    double maxDeviationDeg = 3,
    double volume = 1,
  }) async {
    final t = (deviationDeg / maxDeviationDeg).clamp(0.0, 1.0);
    final freq = 1100 + t * 1900;
    final pan = (rollDeg / 3).clamp(-1.0, 1.0);
    return _playSingleTone(
      frequencyHz: freq,
      durationMs: (45 + t * 55).round(),
      amplitude: (0.15 + t * 0.85) * volume,
      pan: pan,
    );
  }

  /// Soft double chirp when returning to green zone.
  static Future<bool> playLevelSuccess({double volume = 1}) =>
      _playSequence([
        _Tone(frequencyHz: 1800, durationMs: 90, amplitude: 0.65 * volume),
        _Tone(frequencyHz: 2400, durationMs: 120, amplitude: 0.65 * volume),
      ]);

  static Future<bool> _playSingleTone({
    required double frequencyHz,
    required int durationMs,
    required double amplitude,
    double pan = 0,
  }) =>
      _playSequence([
        _Tone(
          frequencyHz: frequencyHz,
          durationMs: durationMs,
          amplitude: amplitude,
          pan: pan,
        ),
      ]);

  static Future<bool> _playSequence(List<_Tone> tones) async {
    if (tones.length > 1) {
      HapticFeedback.mediumImpact();
    }
    final played = await _playWithContext(_ensureMediaContext, tones);
    if (played) return true;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _playWithContext(_ensureAlarmContext, tones);
    }
    return false;
  }

  static Future<bool> _playWithContext(
    Future<void> Function() ensureContext,
    List<_Tone> tones,
  ) async {
    try {
      await ensureContext();
      await _player.stop();
      for (final tone in tones) {
        final wav = _wavTone(
          frequencyHz: tone.frequencyHz,
          durationMs: tone.durationMs,
          amplitude: tone.amplitude,
          pan: tone.pan,
        );
        await _player.play(
          BytesSource(wav, mimeType: 'audio/wav'),
          volume: 1,
          mode: PlayerMode.mediaPlayer,
        );
        await Future<void>.delayed(
          Duration(milliseconds: tone.durationMs + 120),
        );
        await _player.stop();
      }
      return true;
    } on Object {
      return false;
    }
  }

  static Uint8List _wavTone({
    required double frequencyHz,
    required int durationMs,
    double amplitude = 1,
    double pan = 0,
    int sampleRate = 44100,
  }) {
    final sampleCount = (sampleRate * durationMs / 1000).round();
    final dataSize = sampleCount * 4; // stereo 16-bit
    final bytes = ByteData(44 + dataSize);

    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 2, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 4, Endian.little);
    bytes.setUint16(32, 4, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    writeString(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    final amp = amplitude.clamp(0.0, 1.0);
    final panClamped = pan.clamp(-1.0, 1.0);
    final leftGain = amp * (panClamped <= 0 ? 1.0 : 1.0 - panClamped);
    final rightGain = amp * (panClamped >= 0 ? 1.0 : 1.0 + panClamped);

    for (var i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;
      final attack = min(1.0, t * 80);
      final release = min(1.0, (durationMs / 1000 - t) * 30);
      final envelope = attack * release;
      final fundamental = sin(2 * pi * frequencyHz * t);
      final harmonic = sin(2 * pi * frequencyHz * 2 * t) * 0.18;
      final sample = (fundamental + harmonic) * envelope * 32767;
      final left =
          (sample * leftGain).round().clamp(-32768, 32767);
      final right =
          (sample * rightGain).round().clamp(-32768, 32767);
      bytes.setInt16(44 + i * 4, left, Endian.little);
      bytes.setInt16(44 + i * 4 + 2, right, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }
}

class _Tone {
  const _Tone({
    required this.frequencyHz,
    required this.durationMs,
    required this.amplitude,
    this.pan = 0,
  });

  final double frequencyHz;
  final int durationMs;
  final double amplitude;
  final double pan;
}
