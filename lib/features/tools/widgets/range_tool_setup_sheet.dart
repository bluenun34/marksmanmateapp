import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/range_beep.dart';
import '../services/shot_audio_detector.dart';
import 'shot_detection_meter.dart';
import 'shot_timer_help.dart';

/// Guided setup for range tools (timer / counter).
class RangeToolSetupSheet extends StatefulWidget {
  const RangeToolSetupSheet({
    super.key,
    required this.toolName,
    required this.onComplete,
    this.initialMode = ShotInputMode.manual,
    this.initialStrictness = 0.85,
    this.onMicCalibrationStart,
    this.onMicCalibrationEnd,
  });

  final String toolName;
  final void Function(ShotInputMode mode, double strictness) onComplete;
  final ShotInputMode initialMode;
  final double initialStrictness;
  /// Release the host screen mic before opening a second recorder in setup.
  final Future<void> Function()? onMicCalibrationStart;
  final Future<void> Function()? onMicCalibrationEnd;

  static const _prefsKey = 'range_tool_setup_v4_done';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefsKey) ?? false);
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  static Future<void> resetGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  @override
  State<RangeToolSetupSheet> createState() => _RangeToolSetupSheetState();
}

class _RangeToolSetupSheetState extends State<RangeToolSetupSheet> {
  final _pageCtrl = PageController();
  var _step = 0;
  late ShotInputMode _mode;
  late double _strictness;
  ShotAudioDetector? _detector;
  var _listening = false;
  var _handedMicBack = false;
  var _meterLevel = 0.0;
  var _meterWouldDetect = false;
  final _peakTracker = CalibrationPeakTracker();
  var _clapDetected = false;
  var _speechFalsePositive = false;
  var _beepPlaying = false;
  bool? _heardBeep;
  var _skippedClapTest = false;

  bool get _isShotTimer => widget.toolName.toLowerCase().contains('shot timer');

  bool get _usesMic =>
      _mode == ShotInputMode.audio || _mode == ShotInputMode.both;

  int get _stepCount {
    var n = _usesMic ? 4 : 3;
    if (_isShotTimer) n += 1;
    return n;
  }

  int get _lastStepIndex => _stepCount - 1;

  int get _beepPageIndex => _isShotTimer ? 2 : 1;

  int get _micPageIndex => _usesMic ? (_isShotTimer ? 3 : 2) : -1;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _strictness = widget.initialStrictness;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(widget.onMicCalibrationStart?.call());
    });
  }

  @override
  void dispose() {
    unawaited(_stopMicMonitor(handBackToHost: true));
    _detector?.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _startMicMonitor() async {
    if (!_usesMic || _step != _micPageIndex) return;

    await widget.onMicCalibrationStart?.call();
    final detector = _detector ??= ShotAudioDetector(
      strictness: _strictness,
      onSample: (sample) {
        if (mounted) {
          setState(() {
            _peakTracker.ingest(
              sample.detectionMeter,
              wouldDetect: sample.countsAsShot,
            );
            _meterLevel = _peakTracker.live;
            _meterWouldDetect = sample.countsAsShot;
            if (sample.countsAsShot) {
              _clapDetected = true;
            } else if (sample.detectionMeter > 0.45) {
              _speechFalsePositive = true;
            }
          });
        }
      },
    );
    detector
      ..applyStrictness(_strictness)
      ..acceptsEvents = false;

    if (detector.isListening) {
      if (mounted) setState(() => _listening = true);
      return;
    }
    if (!await detector.hasPermission) return;
    await detector.start();
    if (mounted) setState(() => _listening = true);
  }

  Future<void> _stopMicMonitor({bool handBackToHost = false}) async {
    await _detector?.stop();
    if (handBackToHost && !_handedMicBack) {
      _handedMicBack = true;
      await widget.onMicCalibrationEnd?.call();
    }
    if (mounted) setState(() => _listening = false);
  }

  void _syncPageController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      final target = _step.clamp(0, _lastStepIndex);
      if (_pageCtrl.page?.round() != target) {
        _pageCtrl.jumpToPage(target);
      }
    });
  }

  Future<void> _playBeepTest() async {
    setState(() {
      _beepPlaying = true;
      _heardBeep = null;
    });
    final ok = await RangeBeep.playTest();
    if (mounted) {
      setState(() => _beepPlaying = false);
      if (!ok) _heardBeep = false;
    }
  }

  void _onModeChanged(ShotInputMode mode) {
    if (_mode == mode) return;

    if (_detector?.isListening == true) {
      unawaited(_stopMicMonitor());
    }

    setState(() {
      _mode = mode;
      if (_step > _lastStepIndex) {
        _step = _lastStepIndex;
      }
    });
    _syncPageController();

    if (_step == _micPageIndex && _usesMic) {
      unawaited(_startMicMonitor());
    }
  }

  bool get _clapTestPassed =>
      _clapDetected || _peakTracker.peakMarker >= 0.72;

  bool _canAdvanceFromStep(int step) {
    if (step == _beepPageIndex && _heardBeep == null) return false;
    if (step == _micPageIndex &&
        _usesMic &&
        !_clapTestPassed &&
        !_skippedClapTest) {
      return false;
    }
    return true;
  }

  void _next() {
    if (!_canAdvanceFromStep(_step)) return;

    if (_step < _lastStepIndex) {
      final leavingMic = _step == _micPageIndex;
      final nextStep = _step + 1;
      if (leavingMic) {
        unawaited(_stopMicMonitor());
      }
      setState(() => _step = nextStep);
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      if (nextStep == _micPageIndex) {
        unawaited(_startMicMonitor());
      }
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step == 0) return;
    final leavingMic = _step == _micPageIndex;
    final prevStep = _step - 1;
    if (leavingMic) {
      unawaited(_stopMicMonitor());
    }
    setState(() => _step = prevStep);
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
    if (prevStep == _micPageIndex) {
      unawaited(_startMicMonitor());
    }
  }

  Future<void> _finish() async {
    await _stopMicMonitor(handBackToHost: true);
    await RangeToolSetupSheet.markDone();
    widget.onComplete(_mode, _strictness);
    if (mounted) Navigator.of(context).pop();
  }

  void _onStrictnessChanged(double value) {
    setState(() {
      _strictness = value;
      _peakTracker.reset();
      _meterLevel = 0;
      _meterWouldDetect = false;
      _clapDetected = false;
      _speechFalsePositive = false;
      _skippedClapTest = false;
    });
    _detector
      ?..applyStrictness(value)
      ..resetCalibration()
      ..acceptsEvents = false;
  }

  List<Widget> _pages(ThemeData theme) {
    return [
      if (_isShotTimer)
        _StepBody(
          icon: Icons.timer_outlined,
          title: ShotTimerHelp.introTitle,
          body: ShotTimerHelp.introBody,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tip: Manual mode is the most reliable on busy ranges. '
              'Use Audio on a quiet bay after the mic test below.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ),
      _StepBody(
        icon: Icons.touch_app_outlined,
        title: 'How do you want to count shots?',
        body:
            'Pick a mode below. Each option explains what it does and when to use it.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<ShotInputMode>(
              segments: ShotInputMode.values
                  .map(
                    (m) => ButtonSegment(
                      value: m,
                      label: Text(shotInputModeLabel(m)),
                    ),
                  )
                  .toList(),
              selected: {_mode},
              onSelectionChanged: (s) => _onModeChanged(s.first),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                shotInputModeGuideBody(_mode),
                style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ),
          ],
        ),
      ),
      _StepBody(
        icon: Icons.volume_up_rounded,
        title: 'Start signal (beep)',
        body: _usesMic
            ? 'The timer plays a loud double beep when your par time starts. '
                'Turn up Media volume (music/video slider — not ringtone). '
                'The phone also vibrates, so the timer still works without sound.'
            : 'Even in Manual mode the timer beeps when your par time starts so '
                'you know when to shoot. Turn up Media volume (not ringtone). '
                'You tap for splits yourself — the beep is only the start signal. '
                'Vibration still fires if audio is muted.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _beepPlaying ? null : _playBeepTest,
              icon: _beepPlaying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_beepPlaying ? 'Playing…' : 'Play start beep'),
            ),
            if (_heardBeep == false) ...[
              const SizedBox(height: 12),
              Text(
                'No audio heard? Check Media volume, disable Do Not Disturb, '
                'and try again. You can still use the timer — watch the on-screen '
                'countdown and vibration.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _heardBeep = true),
                    child: const Text('I heard it'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _heardBeep = false),
                    child: const Text('No sound'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      if (_usesMic)
        _StepBody(
          icon: Icons.tune_rounded,
          title: 'Calibrate the microphone',
          body:
              'What: Adjust how picky the mic is about counting a shot.\n\n'
              '${ShotTimerHelp.strictnessBody}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Strictness · ${(_strictness * 100).round()}%'),
              Slider(
                value: _strictness,
                min: 0,
                max: 1,
                onChanged: _onStrictnessChanged,
              ),
              if (_step == _micPageIndex && _usesMic) ...[
                const SizedBox(height: 8),
                Text(
                  _listening
                      ? 'Shot-likeness — talk, then clap sharply once'
                      : 'Starting mic…',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                ShotDetectionMeter(
                  meter: _meterLevel,
                  wouldDetect: _meterWouldDetect,
                  peakMarker: _peakTracker.peakMarker,
                  showPeakHint: true,
                ),
                Text(
                  _clapTestPassed
                      ? 'Sharp crack detected ✓'
                      : 'Clap once — bar should spike only on the clap',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _clapTestPassed
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_speechFalsePositive && !_clapTestPassed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Speech is still too “shot-like” at this strictness — slide right '
                    'until talking keeps the bar low, then clap to confirm.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                if (!_clapTestPassed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Dedicated timers ignore sustained voice and only count short sharp '
                    'cracks. Normal talking should keep this bar low; a hard clap should '
                    'spike it.',
                    style: theme.textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _skippedClapTest = true),
                    child: const Text('Skip clap test'),
                  ),
                ],
              ],
            ],
          ),
        ),
      _StepBody(
        icon: Icons.check_circle_outline,
        title: 'Ready to go',
        body: switch (_mode) {
          ShotInputMode.manual =>
            'Manual mode selected.\n\n'
            'What: Tap the screen for each shot split.\n\n'
            'Why: Reliable on any range — no mic, no false counts from other shooters. '
            'Use the on-screen timer and vibration if you cannot hear the start beep.',
          ShotInputMode.audio =>
            'Audio mode selected.\n\n'
            'What: The mic registers loud cracks automatically.\n\n'
            'Why: Hands-free splits when shooting alone. Switch to Manual on the main '
            'screen if you get false counts.',
          ShotInputMode.both =>
            'Both mode selected.\n\n'
            'What: Mic counts shots; tap the screen if one is missed.\n\n'
            'Why: Automatic splits with a manual backup — useful when audio is mostly '
            'right but not perfect. Raise strictness if voice still triggers shots.',
        },
        child: Text(
          shotInputModeHint(_mode),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = _pages(theme);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.toolName} setup',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text('Step ${_step + 1}/$_stepCount'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (_step + 1) / _stepCount),
            const SizedBox(height: 16),
            SizedBox(
              height: _usesMic ? 380 : 340,
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),
            Row(
              children: [
                if (_step > 0)
                  TextButton(onPressed: _back, child: const Text('Back'))
                else
                  const Spacer(),
                const Spacer(),
                FilledButton(
                  onPressed: _canAdvanceFromStep(_step) ? _next : null,
                  child: Text(_step == _lastStepIndex ? 'Start using' : 'Next'),
                ),
              ],
            ),
            if (!_canAdvanceFromStep(_step) && _step == _beepPageIndex) ...[
              const SizedBox(height: 8),
              Text(
                'Tap “I heard it” or “No sound” above to continue.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            if (!_canAdvanceFromStep(_step) && _step == _micPageIndex) ...[
              const SizedBox(height: 8),
              Text(
                'Clap once so the bar turns green, or tap “Skip clap test”.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.icon,
    required this.title,
    required this.body,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

Future<void> showRangeToolSetupIfNeeded(
  BuildContext context, {
  required String toolName,
  required void Function(ShotInputMode mode, double strictness) onComplete,
  ShotInputMode initialMode = ShotInputMode.manual,
  double initialStrictness = 0.85,
  Future<void> Function()? onMicCalibrationStart,
  Future<void> Function()? onMicCalibrationEnd,
  void Function(bool isOpen)? onVisibilityChanged,
}) async {
  if (!await RangeToolSetupSheet.shouldShow()) return;
  if (!context.mounted) return;
  onVisibilityChanged?.call(true);
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RangeToolSetupSheet(
        toolName: toolName,
        onComplete: onComplete,
        initialMode: initialMode,
        initialStrictness: initialStrictness,
        onMicCalibrationStart: onMicCalibrationStart,
        onMicCalibrationEnd: onMicCalibrationEnd,
      ),
    );
  } finally {
    onVisibilityChanged?.call(false);
  }
}
