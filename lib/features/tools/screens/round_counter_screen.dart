import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_screen_app_bar.dart';
import '../services/shot_audio_detector.dart';
import '../widgets/range_tool_setup_sheet.dart';
import '../widgets/shot_detection_meter.dart';
import '../widgets/shot_input_mode_bar.dart';

class RoundCounterScreen extends StatefulWidget {
  const RoundCounterScreen({super.key});

  @override
  State<RoundCounterScreen> createState() => _RoundCounterScreenState();
}

class _RoundCounterScreenState extends State<RoundCounterScreen> {
  int _count = 0;
  ShotInputMode _inputMode = ShotInputMode.manual;
  double _strictness = 0.85;
  ShotAudioDetector? _detector;
  var _listening = false;
  var _permissionDenied = false;
  var _lastAudioFlash = false;
  var _peakLevel = 0.0;
  var _wouldDetect = false;
  final _micPeakTracker = CalibrationPeakTracker();
  var _setupGuideOpen = false;

  bool get _micAcceptsShots => !_setupGuideOpen;

  void _applySetupGuideOpen(bool isOpen) {
    _setupGuideOpen = isOpen;
    if (isOpen) {
      _detector?.acceptsEvents = false;
      unawaited(_releaseMic());
    }
  }

  Future<void> _onSetupGuideVisibilityChanged(bool isOpen) async {
    _applySetupGuideOpen(isOpen);
    if (!isOpen && mounted) await _syncDetector();
  }

  @override
  void initState() {
    super.initState();
    _syncDetector();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showRangeToolSetupIfNeeded(
        context,
        toolName: 'Round counter',
        initialMode: _inputMode,
        initialStrictness: _strictness,
        onMicCalibrationStart: _releaseMic,
        onMicCalibrationEnd: _restartMic,
        onVisibilityChanged: _onSetupGuideVisibilityChanged,
        onComplete: (mode, strictness) {
          setState(() {
            _inputMode = mode;
            _strictness = strictness;
          });
          unawaited(_syncDetector());
        },
      );
    });
  }

  @override
  void dispose() {
    _detector?.dispose();
    super.dispose();
  }

  Future<void> _releaseMic() async {
    await _detector?.stop();
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _restartMic() async {
    if (_inputMode == ShotInputMode.manual) return;

    _detector ??= ShotAudioDetector(
      strictness: _strictness,
      onShot: (_) => _increment(fromAudio: true),
      onSample: (sample) {
        if (mounted) {
          setState(() {
            _micPeakTracker.ingest(
              sample.detectionMeter,
              wouldDetect: sample.countsAsShot,
            );
            _peakLevel = _micPeakTracker.live;
            _wouldDetect = sample.countsAsShot;
          });
        }
      },
    );
    _detector!
      ..applyStrictness(_strictness)
      ..acceptsEvents = _micAcceptsShots;

    try {
      if (!await _detector!.hasPermission) {
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _listening = false;
          });
        }
        return;
      }
      if (_detector!.isListening) {
        await _detector!.restart();
      } else {
        await _detector!.start();
      }
      if (mounted) {
        setState(() {
          _listening = true;
          _permissionDenied = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _listening = false;
        });
      }
    }
  }

  Future<void> _syncDetector() async {
    if (_inputMode == ShotInputMode.manual) {
      await _releaseMic();
      if (mounted) {
        setState(() {
          _permissionDenied = false;
          _peakLevel = 0;
        });
      }
      return;
    }
    await _restartMic();
  }

  void _increment({bool fromAudio = false}) {
    if (_setupGuideOpen) return;
    if (fromAudio && _inputMode == ShotInputMode.manual) return;
    if (!fromAudio && _inputMode == ShotInputMode.audio) return;

    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      if (fromAudio) _lastAudioFlash = true;
    });

    if (fromAudio) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (mounted) setState(() => _lastAudioFlash = false);
      });
    }
  }

  void _decrement() {
    if (_count <= 0) return;
    HapticFeedback.selectionClick();
    setState(() => _count--);
  }

  void _reset() => setState(() => _count = 0);

  void _setInputMode(ShotInputMode mode) {
    setState(() => _inputMode = mode);
    _syncDetector();
  }

  void _setStrictness(double value) {
    setState(() {
      _strictness = value;
      _micPeakTracker.reset();
      _peakLevel = 0;
      _wouldDetect = false;
    });
    _detector?.applyStrictness(value);
  }

  Future<void> _openSetup() async {
    _applySetupGuideOpen(true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RangeToolSetupSheet(
        toolName: 'Round counter',
        initialMode: _inputMode,
        initialStrictness: _strictness,
        onMicCalibrationStart: _releaseMic,
        onMicCalibrationEnd: _restartMic,
        onComplete: (mode, strictness) {
          setState(() {
            _inputMode = mode;
            _strictness = strictness;
          });
          unawaited(_syncDetector());
        },
      ),
    );
    _applySetupGuideOpen(false);
    if (mounted) await _syncDetector();
  }

  bool get _manualEnabled =>
      _inputMode == ShotInputMode.manual || _inputMode == ShotInputMode.both;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppScreenAppBar.back(
        context,
        title: 'Round Counter',
        fallbackRoute: '/tools',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShotInputModeBar(
            mode: _inputMode,
            onModeChanged: _setInputMode,
            strictness: _inputMode == ShotInputMode.manual ? null : _strictness,
            onStrictnessChanged:
                _inputMode == ShotInputMode.manual ? null : _setStrictness,
            listening: _listening,
            permissionDenied: _permissionDenied,
            peakLevel: _inputMode == ShotInputMode.manual ? null : _peakLevel,
            peakMarker: _inputMode == ShotInputMode.manual
                ? null
                : _micPeakTracker.peakMarker,
            wouldDetect: _wouldDetect,
            onShowSetup: _openSetup,
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _lastAudioFlash
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: Card(
              margin: EdgeInsets.zero,
              child: SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    '$_count',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 96,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_manualEnabled)
            SizedBox(
              width: double.infinity,
              height: 72,
              child: FilledButton(
                onPressed: () => _increment(),
                child: const Text('+1 Round', style: TextStyle(fontSize: 22)),
              ),
            ),
          if (!_manualEnabled)
            Text(
              'Audio mode — only very loud sharp sounds count.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _count > 0 ? _decrement : null,
                  child: const Text('−1'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _count > 0 ? _reset : null,
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_count > 0)
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => context.go('/shoot-log/quick?rounds=$_count'),
                icon: const Icon(Icons.save_outlined),
                label: Text('Log $_count rounds'),
              ),
            ),
        ],
      ),
    );
  }
}
