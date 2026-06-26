import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:record/record.dart';

enum ShotInputMode { manual, audio, both }

/// One analysed mic buffer — used for live UI and calibration.
class ShotAudioSample {
  const ShotAudioSample({
    required this.peak,
    required this.rms,
    required this.crest,
    required this.attackSharpness,
    required this.transientPeak,
    required this.wouldDetect,
    required this.wouldCount,
    required this.countsAsShot,
    required this.detectionMeter,
  });

  /// Raw PCM peak (0–1). Loud speech can still be ~1.0 — not used for UI meter.
  final double peak;
  final double rms;
  final double crest;
  final double attackSharpness;

  /// Max sample-to-sample jump — claps/gunshots score high; speech scores lower.
  final double transientPeak;

  /// Would this buffer register as a shot at the current strictness?
  final bool wouldDetect;

  /// Would this buffer count as a shot (includes calibrated near-miss at low strictness).
  final bool wouldCount;

  /// Same rule as the meter “Would count” band — used for splits and UI.
  final bool countsAsShot;

  /// 0–1 “shot-likeness” for UI — based on impulse shape, not raw loudness.
  final double detectionMeter;
}

/// Detection profile derived from strictness slider (0 = permissive, 1 = strict).
class ShotDetectionProfile {
  const ShotDetectionProfile({
    required this.peakThreshold,
    required this.minPeakToRms,
    required this.minPeakAboveNoise,
    required this.minAttackRatio,
    required this.minAbsolutePeak,
    required this.minAttackSharpness,
    required this.maxRmsForShot,
    required this.permissive,
    required this.minTransientPeak,
    required this.minTransientToRms,
    required this.minRiseRatio,
    required this.sustainedSpeechRms,
    required this.sustainedSpeechCrest,
  });

  final double peakThreshold;
  final double minPeakToRms;
  final double minPeakAboveNoise;
  final double minAttackRatio;
  final double minAbsolutePeak;
  final double minAttackSharpness;
  final double maxRmsForShot;
  final bool permissive;
  final double minTransientPeak;
  final double minTransientToRms;
  final double minRiseRatio;
  final double sustainedSpeechRms;
  final double sustainedSpeechCrest;

  static ShotDetectionProfile fromStrictness(double strictness) {
    final s = strictness.clamp(0.0, 1.0);
    return ShotDetectionProfile(
      peakThreshold: 0.12 + s * 0.58,
      minPeakToRms: 1.8 + s * 8.2,
      minPeakAboveNoise: 2.0 + s * 10.0,
      minAttackRatio: 1.25 + s * 3.1,
      minAbsolutePeak: 0.10 + s * 0.30,
      minAttackSharpness: 1.1 + s * 4.1,
      maxRmsForShot: 0.24 - s * 0.12,
      permissive: s < 0.40,
      minTransientPeak: 0.025 + s * 0.06,
      minTransientToRms: 1.4 + s * 4.6,
      minRiseRatio: 1.55 + s * 2.45,
      sustainedSpeechRms: 0.09 + s * 0.15,
      sustainedSpeechCrest: 1.8 + s * 7.2,
    );
  }
}

/// Listens for very sharp loud transients (gunshots), not speech.
class ShotAudioDetector {
  ShotAudioDetector({
    double strictness = 0.85,
    this.cooldown = const Duration(milliseconds: 450),
    this.onShot,
    this.onSample,
  }) : _strictness = strictness {
    _profile = ShotDetectionProfile.fromStrictness(strictness);
  }

  final Duration cooldown;
  final void Function(double peak)? onShot;
  final void Function(ShotAudioSample sample)? onSample;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;
  DateTime? _lastChunkAt;
  DateTime? _streamStartedAt;
  DateTime? _lastShotAt;
  var _listening = false;
  var _acceptsEvents = true;
  double _strictness;
  late ShotDetectionProfile _profile;
  double _noiseFloor = 0.012;
  final List<double> _recentPeaks = [];

  bool get isListening => _listening;

  /// False when the PCM stream stopped but [isListening] was not cleared yet.
  bool get isStreamAlive {
    if (!_listening) return false;
    final last = _lastChunkAt;
    if (last != null) {
      return DateTime.now().difference(last) <
          const Duration(milliseconds: 900);
    }
    final started = _streamStartedAt;
    if (started == null) return false;
    return DateTime.now().difference(started) < const Duration(seconds: 2);
  }
  double get strictness => _strictness;

  Duration get _effectiveCooldown {
    final ms = (cooldown.inMilliseconds * (0.55 + _strictness * 0.45)).round();
    return Duration(milliseconds: ms.clamp(180, cooldown.inMilliseconds));
  }

  set acceptsEvents(bool value) => _acceptsEvents = value;

  void applyStrictness(double strictness) {
    _strictness = strictness.clamp(0, 1);
    _profile = ShotDetectionProfile.fromStrictness(_strictness);
  }

  Future<bool> get hasPermission => _recorder.hasPermission();

  Future<void> start() async {
    if (_listening) return;
    if (!await _recorder.hasPermission()) {
      throw StateError('Microphone permission denied');
    }

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
      ),
    );

    _subscription = stream.listen(
      _handleChunk,
      onError: (_) => _markStreamEnded(),
      onDone: _markStreamEnded,
    );
    _listening = true;
    _streamStartedAt = DateTime.now();
    _lastChunkAt = null;
  }

  void _markStreamEnded() {
    _listening = false;
    _subscription = null;
    _streamStartedAt = null;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    _listening = false;
    _streamStartedAt = null;
    _lastChunkAt = null;
    _recentPeaks.clear();
  }

  void resetCalibration() {
    _noiseFloor = 0.012;
    _recentPeaks.clear();
    _lastShotAt = null;
  }

  /// Call after loud start beep so the next transients are not drowned out.
  void prepareForShotCapture() {
    resetCalibration();
  }

  Future<void> restart() async {
    await stop();
    resetCalibration();
    await _startWithRetry();
  }

  Future<void> _startWithRetry({int attempts = 3}) async {
    Object? lastError;
    for (var i = 0; i < attempts; i++) {
      if (i > 0) {
        await Future<void>.delayed(Duration(milliseconds: 120 + i * 80));
      }
      try {
        await start();
        return;
      } on Object catch (e) {
        lastError = e;
        await stop();
      }
    }
    if (lastError != null) {
      throw lastError!;
    }
  }

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }

  void _handleChunk(Uint8List chunk) {
    _lastChunkAt = DateTime.now();
    final peak = peakAmplitudePcm16(chunk);
    final finePeak = finePeakAmplitudePcm16(chunk);
    final analysisPeak = max(peak, finePeak);
    final rms = rmsAmplitudePcm16(chunk);
    final attackSharpness = attackSharpnessInChunk(chunk);
    final transientPeak = transientPeakPcm16(chunk);

    if (analysisPeak < _profile.peakThreshold * 0.55) {
      final rate = _profile.permissive ? 0.015 : 0.05;
      _noiseFloor = (_noiseFloor * (1 - rate)) + (rms * rate);
      if (_profile.permissive) {
        _noiseFloor = min(_noiseFloor, 0.045);
      }
    }

    final riseRatio = _riseRatio(analysisPeak);
    final priorPeaks = List<double>.from(_recentPeaks);
    _recentPeaks.add(analysisPeak);
    if (_recentPeaks.length > 20) {
      _recentPeaks.removeAt(0);
    }

    final sample = analyseChunk(
      peak: analysisPeak,
      rms: rms,
      attackSharpness: attackSharpness,
      transientPeak: transientPeak,
      riseRatio: riseRatio,
      noiseFloor: _noiseFloor,
      profile: _profile,
      recentPeaks: _recentPeaks,
      priorPeaks: priorPeaks,
    );
    onSample?.call(sample);

    if (!_acceptsEvents) return;
    if (!sample.countsAsShot) return;

    final now = DateTime.now();
    if (_lastShotAt != null && now.difference(_lastShotAt!) < _effectiveCooldown) {
      return;
    }
    _lastShotAt = now;
    onShot?.call(analysisPeak);
  }

  double _riseRatio(double peak) {
    if (_recentPeaks.isEmpty) {
      return peak / max(_noiseFloor, 0.008);
    }
    final recentMax = _recentPeaks.reduce(max);
    final recentAvg =
        _recentPeaks.reduce((a, b) => a + b) / _recentPeaks.length;
    return peak / max(max(recentMax, recentAvg * 1.1), max(_noiseFloor, 0.008));
  }

  /// Analyse one PCM buffer — mirrors dedicated timers: threshold + impulse shape.
  static ShotAudioSample analyseChunk({
    required double peak,
    required double rms,
    required double attackSharpness,
    required double transientPeak,
    required double riseRatio,
    required double noiseFloor,
    required ShotDetectionProfile profile,
    List<double> recentPeaks = const [],
    List<double> priorPeaks = const [],
  }) {
    final crest = peak / max(rms, 0.0001);
    final transientToRms = transientPeak / max(rms, 0.0001);
    final wouldDetect = isShotTransient(
      peak: peak,
      rms: rms,
      noiseFloor: noiseFloor,
      profile: profile,
      recentPeaks: recentPeaks,
      priorPeaks: priorPeaks,
      attackSharpness: attackSharpness,
      transientPeak: transientPeak,
      riseRatio: riseRatio,
      transientToRms: transientToRms,
    );
    final detectionMeter = wouldDetect
        ? 1.0
        : _detectionMeter(
            peak: peak,
            rms: rms,
            crest: crest,
            attackSharpness: attackSharpness,
            transientPeak: transientPeak,
            riseRatio: riseRatio,
            transientToRms: transientToRms,
            noiseFloor: noiseFloor,
            profile: profile,
          );
    final wouldCount = wouldDetect ||
        _qualifiesForCount(
          detectionMeter: detectionMeter,
          transientPeak: transientPeak,
          riseRatio: riseRatio,
          transientToRms: transientToRms,
          profile: profile,
        );
    final countsAsShot = wouldDetect ||
        wouldCount ||
        _countsFromMeter(
          detectionMeter: detectionMeter,
          transientPeak: transientPeak,
          riseRatio: riseRatio,
          profile: profile,
        );

    return ShotAudioSample(
      peak: peak,
      rms: rms,
      crest: crest,
      attackSharpness: attackSharpness,
      transientPeak: transientPeak,
      wouldDetect: wouldDetect,
      wouldCount: wouldCount,
      countsAsShot: countsAsShot,
      detectionMeter: detectionMeter,
    );
  }

  /// Aligns split registration with the green “Would count” meter band.
  static bool _countsFromMeter({
    required double detectionMeter,
    required double transientPeak,
    required double riseRatio,
    required ShotDetectionProfile profile,
  }) {
    if (detectionMeter < 0.55) return false;
    if (transientPeak < profile.minTransientPeak * 0.32) return false;

    if (detectionMeter >= 0.85) {
      return riseRatio >= profile.minRiseRatio * 0.5;
    }

    if (profile.permissive) {
      return riseRatio >= profile.minRiseRatio * 0.6 ||
          transientPeak >= profile.minTransientPeak * 0.5;
    }

    return detectionMeter >= 0.65 &&
        riseRatio >= profile.minRiseRatio * 0.72 &&
        transientPeak >= profile.minTransientPeak * 0.45;
  }

  /// Near-miss — bar shows yellow/green but strict path failed (common after start beep).
  static bool _qualifiesForCount({
    required double detectionMeter,
    required double transientPeak,
    required double riseRatio,
    required double transientToRms,
    required ShotDetectionProfile profile,
  }) {
    if (detectionMeter < 0.55) return false;
    if (transientPeak < profile.minTransientPeak * 0.5) return false;
    if (riseRatio < profile.minRiseRatio * 0.72) return false;

    if (profile.permissive) {
      return detectionMeter >= 0.58 &&
          (transientToRms >= profile.minTransientToRms * 0.45 ||
              riseRatio >= profile.minRiseRatio * 0.85);
    }

    return detectionMeter >= 0.78 &&
        transientToRms >= profile.minTransientToRms * 0.65 &&
        riseRatio >= profile.minRiseRatio * 0.9;
  }

  static double _detectionMeter({
    required double peak,
    required double rms,
    required double crest,
    required double attackSharpness,
    required double transientPeak,
    required double riseRatio,
    required double transientToRms,
    required double noiseFloor,
    required ShotDetectionProfile profile,
  }) {
    final crestScore = (crest / profile.minPeakToRms).clamp(0.0, 1.0);
    final attackScore =
        (attackSharpness / profile.minAttackSharpness).clamp(0.0, 1.0);
    final peakScore = (peak / profile.peakThreshold).clamp(0.0, 1.0);
    final transientScore =
        (transientPeak / profile.minTransientPeak).clamp(0.0, 1.0);
    final riseScore =
        (riseRatio / profile.minRiseRatio).clamp(0.0, 1.0);
    final aboveNoise = peak / max(noiseFloor * profile.minPeakAboveNoise, 0.0001);
    final noiseScore = aboveNoise.clamp(0.0, 1.0);

    var shape = sqrt(max(crestScore * attackScore, transientScore * riseScore));
    if (rms > profile.maxRmsForShot &&
        crest < profile.minPeakToRms * 0.85 &&
        transientToRms < profile.minTransientToRms * 0.9) {
      shape *= 0.35;
    }
    if (rms > profile.sustainedSpeechRms &&
        crest < profile.sustainedSpeechCrest &&
        transientPeak < profile.minTransientPeak * 1.2) {
      shape *= 0.3;
    }

    return (shape * sqrt(peakScore * noiseScore)).clamp(0.0, 0.92);
  }

  static bool isShotTransient({
    required double peak,
    required double rms,
    required double noiseFloor,
    required ShotDetectionProfile profile,
    List<double> recentPeaks = const [],
    List<double> priorPeaks = const [],
    double attackSharpness = 1,
    double transientPeak = 0,
    double riseRatio = 1,
    double transientToRms = 0,
  }) {
    if (profile.permissive &&
        _isPermissiveImpulse(
          peak: peak,
          rms: rms,
          noiseFloor: noiseFloor,
          profile: profile,
          priorPeaks: priorPeaks,
          attackSharpness: attackSharpness,
          transientPeak: transientPeak,
          riseRatio: riseRatio,
          transientToRms: transientToRms,
        )) {
      return true;
    }

    if (_isTransientHit(
      peak: peak,
      transientPeak: transientPeak,
      riseRatio: riseRatio,
      transientToRms: transientToRms,
      noiseFloor: noiseFloor,
      profile: profile,
    )) {
      return _passesStrictShape(
        peak: peak,
        rms: rms,
        attackSharpness: attackSharpness,
        profile: profile,
        recentPeaks: recentPeaks,
        noiseFloor: noiseFloor,
      );
    }

    if (peak < profile.minAbsolutePeak) return false;
    if (peak < profile.peakThreshold) return false;
    if (peak < noiseFloor * profile.minPeakAboveNoise) return false;

    final crest = peak / max(rms, 0.0001);
    if (crest < profile.minPeakToRms) return false;

    if (rms > profile.maxRmsForShot && crest < profile.minPeakToRms * 1.15) {
      return false;
    }
    if (rms > profile.sustainedSpeechRms &&
        crest < profile.sustainedSpeechCrest) {
      return false;
    }

    if (attackSharpness < profile.minAttackSharpness) return false;

    if (recentPeaks.length >= 4) {
      final prior = recentPeaks.sublist(0, recentPeaks.length - 1);
      final recentMax = prior.reduce(max);
      if (recentMax > 0.02 && peak < recentMax * profile.minAttackRatio) {
        return false;
      }
    }

    return true;
  }

  /// Fast sample-to-sample edge — reliable for claps on phone mics.
  static bool _isTransientHit({
    required double peak,
    required double transientPeak,
    required double riseRatio,
    required double transientToRms,
    required double noiseFloor,
    required ShotDetectionProfile profile,
  }) {
    if (peak < profile.minAbsolutePeak * 0.85) return false;
    if (peak < noiseFloor * 1.6) return false;
    if (transientPeak < profile.minTransientPeak) return false;
    if (riseRatio < profile.minRiseRatio * 0.85) return false;
    return transientToRms >= profile.minTransientToRms * 0.75 ||
        riseRatio >= profile.minRiseRatio;
  }

  static bool _passesStrictShape({
    required double peak,
    required double rms,
    required double attackSharpness,
    required ShotDetectionProfile profile,
    required List<double> recentPeaks,
    required double noiseFloor,
  }) {
    if (peak < profile.peakThreshold * 0.9) return false;
    if (peak < noiseFloor * profile.minPeakAboveNoise * 0.85) return false;
    if (rms > profile.maxRmsForShot) {
      final crest = peak / max(rms, 0.0001);
      if (crest < profile.minPeakToRms * 0.75) return false;
    }
    if (attackSharpness < profile.minAttackSharpness * 0.7 &&
        peak < profile.peakThreshold * 1.2) {
      return false;
    }
    if (recentPeaks.length >= 3) {
      final prior = recentPeaks.sublist(0, recentPeaks.length - 1);
      final recentMax = prior.reduce(max);
      if (recentMax > 0.02 && peak < recentMax * (profile.minAttackRatio * 0.9)) {
        return false;
      }
    }
    return true;
  }

  /// Low strictness: claps, speaker playback, quiet guns.
  static bool _isPermissiveImpulse({
    required double peak,
    required double rms,
    required double noiseFloor,
    required ShotDetectionProfile profile,
    required List<double> priorPeaks,
    required double attackSharpness,
    required double transientPeak,
    required double riseRatio,
    required double transientToRms,
  }) {
    if (peak < profile.minAbsolutePeak * 0.75) return false;
    if (peak < noiseFloor * 1.45) return false;

    final crest = peak / max(rms, 0.0001);
    final hasEdge = transientPeak >= profile.minTransientPeak * 0.65;
    final hasJump = riseRatio >= profile.minRiseRatio * 0.82;
    final hasShape =
        crest >= 1.35 ||
        attackSharpness >= 1.15 ||
        transientToRms >= profile.minTransientToRms * 0.55;

    if (!hasEdge && !hasJump) return false;
    if (!hasShape && transientPeak < profile.minTransientPeak) return false;

    if (rms > 0.22 && crest < 1.4 && transientPeak < profile.minTransientPeak) {
      return false;
    }

    if (priorPeaks.isNotEmpty) {
      final recentMax = priorPeaks.reduce(max);
      final recentAvg = priorPeaks.reduce((a, b) => a + b) / priorPeaks.length;
      final jumpFrom = max(max(recentMax * 1.18, recentAvg * 1.32), 0.10);
      if (peak < jumpFrom && riseRatio < profile.minRiseRatio * 0.9) {
        return false;
      }
    } else if (peak < 0.14 && transientPeak < profile.minTransientPeak * 0.8) {
      return false;
    }

    return true;
  }

  /// Fine windows (~5 ms) — catches impulses smeared across large Android buffers.
  static double finePeakAmplitudePcm16(Uint8List bytes) {
    if (bytes.length < 32) return peakAmplitudePcm16(bytes);
    const windows = 32;
    final windowBytes = max(4, (bytes.length ~/ windows) & ~1);
    var peak = 0.0;
    for (var i = 0; i + windowBytes <= bytes.length; i += windowBytes) {
      peak = max(
        peak,
        peakAmplitudePcm16(bytes.sublist(i, min(i + windowBytes, bytes.length))),
      );
    }
    return peak;
  }

  /// High-pass proxy: large sample-to-sample jumps = gunshot/clap transients.
  static double transientPeakPcm16(Uint8List bytes) {
    if (bytes.length < 4) return 0;
    var prev = 0;
    var peakDiff = 0;
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      final unsigned = bytes[i] | (bytes[i + 1] << 8);
      final signed = unsigned > 32767 ? unsigned - 65536 : unsigned;
      peakDiff = max(peakDiff, (signed - prev).abs());
      prev = signed;
    }
    return peakDiff / 32768.0;
  }

  static double attackSharpnessInChunk(Uint8List bytes) {
    if (bytes.length < 32) return 1;
    const slices = 32;
    final sliceBytes = max(4, (bytes.length ~/ slices) & ~1);
    if (sliceBytes < 2) return 1;

    final peaks = <double>[];
    for (var i = 0; i + sliceBytes <= bytes.length; i += sliceBytes) {
      peaks.add(peakAmplitudePcm16(bytes.sublist(i, i + sliceBytes)));
    }
    if (peaks.isEmpty) return 1;
    peaks.sort((a, b) => b.compareTo(a));
    final top = peaks[0];
    final second = peaks.length > 1 ? peaks[1] : 0;
    if (second < 0.006) return top > 0.015 ? 14 : 1;
    return top / second;
  }

  static double peakAmplitudePcm16(Uint8List bytes) {
    if (bytes.length < 2) return 0;
    var peak = 0;
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      final unsigned = bytes[i] | (bytes[i + 1] << 8);
      final signed = unsigned > 32767 ? unsigned - 65536 : unsigned;
      peak = max(peak, signed.abs());
    }
    return peak / 32768.0;
  }

  static double rmsAmplitudePcm16(Uint8List bytes) {
    if (bytes.length < 2) return 0;
    var sumSquares = 0.0;
    var count = 0;
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      final unsigned = bytes[i] | (bytes[i + 1] << 8);
      final signed = unsigned > 32767 ? unsigned - 65536 : unsigned;
      final normal = signed / 32768.0;
      sumSquares += normal * normal;
      count++;
    }
    return sqrt(sumSquares / count);
  }
}

String shotInputModeLabel(ShotInputMode mode) => switch (mode) {
      ShotInputMode.manual => 'Manual',
      ShotInputMode.audio => 'Audio',
      ShotInputMode.both => 'Both',
    };

String shotInputModeHint(ShotInputMode mode) => switch (mode) {
      ShotInputMode.manual =>
        'Tap the screen for each shot. Best on busy ranges — no mic needed.',
      ShotInputMode.audio =>
        'Mic counts sharp cracks automatically. Calibrate strictness on quiet bays. '
        'At 0% strictness the mic is very sensitive — raise it on busy ranges.',
      ShotInputMode.both =>
        'Mic plus tap backup if a shot is missed.',
    };

String shotInputModeGuideBody(ShotInputMode mode) => switch (mode) {
      ShotInputMode.manual =>
        'What it is: You tap the screen each time you fire to record splits.\n\n'
        'Why use it: No microphone needed, so it works on busy public ranges, '
        'with electronic ear defenders, or when shot detection is unreliable. '
        'Recommended default for most UK range visits.',
      ShotInputMode.audio =>
        'What it is: The phone mic listens for sharp gunshot-like cracks and '
        'records splits automatically.\n\n'
        'Why use it: Hands-free when you are shooting alone or on a quiet bay '
        'and can calibrate the mic. Raise strictness if voices trigger false shots.',
      ShotInputMode.both =>
        'What it is: The mic records shots automatically, and you can tap the '
        'screen if a shot is missed.\n\n'
        'Why use it: Best when audio detection mostly works but you want a safety '
        'net — e.g. semi-busy range or one-sided ear pro.',
    };
