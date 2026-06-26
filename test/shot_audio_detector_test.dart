import 'dart:math';

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/features/tools/services/shot_audio_detector.dart';
import 'package:marksmanmate/features/tools/widgets/shot_detection_meter.dart';

void main() {
  group('ShotDetectionProfile', () {
    test('higher strictness raises thresholds', () {
      final loose = ShotDetectionProfile.fromStrictness(0);
      final strict = ShotDetectionProfile.fromStrictness(1);
      expect(strict.peakThreshold, greaterThan(loose.peakThreshold));
      expect(strict.minPeakToRms, greaterThan(loose.minPeakToRms));
      expect(strict.minAttackSharpness, greaterThan(loose.minAttackSharpness));
    });
  });

  group('ShotAudioDetector.isShotTransient', () {
    test('accepts sharp impulse well above noise floor', () {
      final profile = ShotDetectionProfile.fromStrictness(0.5);
      expect(
        ShotAudioDetector.isShotTransient(
          peak: 0.72,
          rms: 0.06,
          noiseFloor: 0.02,
          profile: profile,
          recentPeaks: [0.03, 0.04, 0.05, 0.72],
          attackSharpness: 8,
        ),
        isTrue,
      );
    });

    test('rejects sustained speech-like audio', () {
      final profile = ShotDetectionProfile.fromStrictness(0.85);
      expect(
        ShotAudioDetector.isShotTransient(
          peak: 0.42,
          rms: 0.2,
          noiseFloor: 0.05,
          profile: profile,
          recentPeaks: [0.18, 0.2, 0.19, 0.42],
          attackSharpness: 1.5,
        ),
        isFalse,
      );
    });

    test('rejects gradual loudness without attack spike', () {
      final profile = ShotDetectionProfile.fromStrictness(0.85);
      expect(
        ShotAudioDetector.isShotTransient(
          peak: 0.55,
          rms: 0.08,
          noiseFloor: 0.03,
          profile: profile,
          recentPeaks: [0.48, 0.5, 0.52, 0.55],
          attackSharpness: 1.2,
        ),
        isFalse,
      );
    });

    test('rejects loud speech even with moderate peak', () {
      final profile = ShotDetectionProfile.fromStrictness(0.85);
      expect(
        ShotAudioDetector.isShotTransient(
          peak: 0.5,
          rms: 0.12,
          noiseFloor: 0.04,
          profile: profile,
          recentPeaks: [0.12, 0.14, 0.13, 0.5],
          attackSharpness: 2,
        ),
        isFalse,
      );
    });

    test('at 0% accepts speaker-reproduced gunshot-like jump', () {
      final profile = ShotDetectionProfile.fromStrictness(0);
      expect(profile.permissive, isTrue);
      expect(
        ShotAudioDetector.isShotTransient(
          peak: 0.52,
          rms: 0.17,
          noiseFloor: 0.06,
          profile: profile,
          recentPeaks: [0.14, 0.15, 0.13, 0.52],
          attackSharpness: 2.4,
        ),
        isTrue,
      );
    });

    test('at 0% accepts soft clap smeared across buffer via transient edge', () {
      final profile = ShotDetectionProfile.fromStrictness(0);
      final bytes = _syntheticClapChunk(spikeAmplitude: 12000, spreadSamples: 8);
      final peak = ShotAudioDetector.finePeakAmplitudePcm16(bytes);
      final rms = ShotAudioDetector.rmsAmplitudePcm16(bytes);
      final attack = ShotAudioDetector.attackSharpnessInChunk(bytes);
      final transient = ShotAudioDetector.transientPeakPcm16(bytes);
      expect(
        ShotAudioDetector.isShotTransient(
          peak: peak,
          rms: rms,
          noiseFloor: 0.015,
          profile: profile,
          priorPeaks: [0.02, 0.025, 0.018],
          recentPeaks: [0.02, 0.025, 0.018, peak],
          attackSharpness: attack,
          transientPeak: transient,
          riseRatio: peak / 0.025,
          transientToRms: transient / max(rms, 0.0001),
        ),
        isTrue,
      );
    });

    test('at 0% rejects flat loud background without jump', () {
      final profile = ShotDetectionProfile.fromStrictness(0);
      expect(
        ShotAudioDetector.isShotTransient(
          peak: 0.22,
          rms: 0.19,
          noiseFloor: 0.08,
          profile: profile,
          recentPeaks: [0.20, 0.21, 0.19, 0.22],
          attackSharpness: 1.1,
        ),
        isFalse,
      );
    });
  });

  group('ShotAudioDetector.analyseChunk', () {
    test('speech-like audio stays low on detection meter at high strictness', () {
      final profile = ShotDetectionProfile.fromStrictness(1);
      final sample = ShotAudioDetector.analyseChunk(
        peak: 0.88,
        rms: 0.19,
        attackSharpness: 1.6,
        transientPeak: 0.02,
        riseRatio: 1.2,
        noiseFloor: 0.04,
        profile: profile,
        recentPeaks: [0.15, 0.17, 0.16, 0.88],
      );
      expect(sample.wouldDetect, isFalse);
      expect(sample.wouldCount, isFalse);
      expect(sample.detectionMeter, lessThan(0.5));
    });

    test('sharp impulse scores high and detects at moderate strictness', () {
      final profile = ShotDetectionProfile.fromStrictness(0.5);
      final sample = ShotAudioDetector.analyseChunk(
        peak: 0.72,
        rms: 0.06,
        attackSharpness: 8,
        transientPeak: 0.08,
        riseRatio: 4.5,
        noiseFloor: 0.02,
        profile: profile,
        recentPeaks: [0.03, 0.04, 0.05, 0.72],
      );
      expect(sample.wouldDetect, isTrue);
      expect(sample.wouldCount, isTrue);
      expect(sample.countsAsShot, isTrue);
      expect(sample.detectionMeter, 1.0);
    });

    test('sharp clap-like hit counts during strict drill even without full detect', () {
      final profile = ShotDetectionProfile.fromStrictness(0.85);
      final sample = ShotAudioDetector.analyseChunk(
        peak: 0.68,
        rms: 0.09,
        attackSharpness: 3.2,
        transientPeak: 0.05,
        riseRatio: 3.1,
        noiseFloor: 0.02,
        profile: profile,
        recentPeaks: [0.04, 0.05, 0.04, 0.68],
      );
      expect(sample.wouldDetect, isFalse);
      expect(sample.detectionMeter, greaterThan(0.65));
      expect(sample.countsAsShot, isTrue);
    });

    test('loud speech raw peak can be high while meter stays low', () {
      final profile = ShotDetectionProfile.fromStrictness(1);
      final sample = ShotAudioDetector.analyseChunk(
        peak: 0.95,
        rms: 0.22,
        attackSharpness: 1.4,
        transientPeak: 0.03,
        riseRatio: 1.3,
        noiseFloor: 0.05,
        profile: profile,
        recentPeaks: [0.2, 0.21, 0.19, 0.95],
      );
      expect(sample.peak, greaterThan(0.9));
      expect(sample.wouldDetect, isFalse);
      expect(sample.detectionMeter, lessThan(0.45));
    });
  });

  group('ShotDetectionBand', () {
    test('maps meter levels to color bands', () {
      expect(
        ShotDetectionBand.fromMeter(0.4),
        ShotDetectionBand.unlikely,
      );
      expect(
        ShotDetectionBand.fromMeter(0.6),
        ShotDetectionBand.maybe,
      );
      expect(
        ShotDetectionBand.fromMeter(0.9),
        ShotDetectionBand.definite,
      );
      expect(
        ShotDetectionBand.fromMeter(0.2, wouldDetect: true),
        ShotDetectionBand.definite,
      );
    });
  });

  group('CalibrationPeakTracker', () {
    test('peak marker only moves up after louder burst', () {
      final tracker = CalibrationPeakTracker();
      tracker.ingest(0.05);
      tracker.ingest(0.55);
      tracker.ingest(0.60);
      tracker.ingest(0.04);
      expect(tracker.peakMarker, closeTo(0.60, 0.001));

      tracker.ingest(0.50);
      tracker.ingest(0.03);
      expect(tracker.peakMarker, closeTo(0.60, 0.001));

      tracker.ingest(0.72);
      tracker.ingest(0.05);
      expect(tracker.peakMarker, closeTo(0.72, 0.001));
    });

    test('reset clears live and marker', () {
      final tracker = CalibrationPeakTracker();
      tracker.ingest(0.8);
      tracker.ingest(0.02);
      tracker.reset();
      expect(tracker.live, 0);
      expect(tracker.peakMarker, 0);
    });
  });

  group('transientPeakPcm16', () {
    test('sharp spike exceeds gradual ramp slope', () {
      final spike = _syntheticSpikeChunk(spikeAmplitude: 14000);
      final ramp = _syntheticRampChunk(maxAmplitude: 14000);
      expect(
        ShotAudioDetector.transientPeakPcm16(spike),
        greaterThan(ShotAudioDetector.transientPeakPcm16(ramp)),
      );
    });
  });

  group('attackSharpnessInChunk', () {
    test('detects single-spike chunk', () {
      final bytes = _syntheticSpikeChunk(spikeAmplitude: 20000);
      expect(ShotAudioDetector.attackSharpnessInChunk(bytes), greaterThan(4));
    });
  });
}

Uint8List _syntheticClapChunk({
  required int spikeAmplitude,
  int spreadSamples = 4,
}) {
  final samples = List<int>.filled(1024, 0);
  final center = 200;
  for (var i = -spreadSamples; i <= spreadSamples; i++) {
    final idx = center + i;
    if (idx >= 0 && idx < samples.length) {
      final falloff = 1.0 - (i.abs() / (spreadSamples + 1));
      samples[idx] = (spikeAmplitude * falloff).round();
    }
  }
  return _samplesToBytes(samples);
}

Uint8List _syntheticRampChunk({required int maxAmplitude}) {
  final samples = List<int>.filled(1024, 0);
  for (var i = 0; i < 120; i++) {
    samples[100 + i] = (maxAmplitude * (i / 120)).round();
  }
  return _samplesToBytes(samples);
}

Uint8List _samplesToBytes(List<int> samples) {
  final bytes = Uint8List(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    final v = samples[i];
    bytes[i * 2] = v & 0xff;
    bytes[i * 2 + 1] = (v >> 8) & 0xff;
  }
  return bytes;
}

Uint8List _syntheticSpikeChunk({required int spikeAmplitude}) {
  final samples = List<int>.filled(512, 0);
  samples[64] = spikeAmplitude;
  return _samplesToBytes(samples);
}
