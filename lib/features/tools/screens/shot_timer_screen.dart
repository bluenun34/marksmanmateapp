import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/app_screen_app_bar.dart';
import '../services/range_beep.dart';
import '../services/shot_audio_detector.dart';
import '../widgets/range_tool_setup_sheet.dart';
import '../widgets/shot_detection_meter.dart';
import '../widgets/shot_input_mode_bar.dart';
import '../widgets/shot_timer_help.dart';

enum _TimerPhase { idle, waiting, running, finished }

enum _TimerRunStyle { parDrill, courseRun }

enum _FinishReason { none, parTime, courseComplete, courseDnf }

class ShotTimerScreen extends StatefulWidget {
  const ShotTimerScreen({super.key});

  @override
  State<ShotTimerScreen> createState() => _ShotTimerScreenState();
}

class _ShotTimerScreenState extends State<ShotTimerScreen> {
  _TimerPhase _phase = _TimerPhase.idle;
  _TimerRunStyle _runStyle = _TimerRunStyle.parDrill;
  _FinishReason _finishReason = _FinishReason.none;
  double _parSeconds = 3.0;
  var _courseLimitUnlimited = true;
  double _courseLimitSeconds = 120.0;
  double _delayMin = 2.0;
  double _delayMax = 5.0;
  double _elapsed = 0;
  final List<double> _splits = [];
  Timer? _timer;
  DateTime? _startedAt;

  ShotInputMode _inputMode = ShotInputMode.manual;
  double _strictness = 0.85;
  ShotAudioDetector? _detector;
  var _listening = false;
  var _permissionDenied = false;
  var _lastAudioFlash = false;
  var _peakLevel = 0.0;
  var _wouldDetect = false;
  final _micPeakTracker = CalibrationPeakTracker();
  var _settingsExpanded = false;
  var _introExpanded = false;
  var _setupGuideOpen = false;

  bool get _micAcceptsShots =>
      !_setupGuideOpen && _phase == _TimerPhase.running;

  void _applySetupGuideOpen(bool isOpen) {
    _setupGuideOpen = isOpen;
    if (isOpen) {
      _detector?.acceptsEvents = false;
      unawaited(_releaseMic());
    }
  }

  Future<void> _onSetupGuideVisibilityChanged(bool isOpen) async {
    _applySetupGuideOpen(isOpen);
    if (!isOpen && mounted) {
      await _syncDetector();
    }
  }

  Future<void> _ensureMicMeterActive() async {
    if (_inputMode == ShotInputMode.manual || _setupGuideOpen) return;
    if (_detector?.isStreamAlive == true) {
      _syncMicAcceptsShots();
      if (mounted) {
        setState(() {
          _listening = true;
          _permissionDenied = false;
        });
      }
      return;
    }
    await _restartMic(acceptShots: _micAcceptsShots, forceRestart: true);
  }

  Future<void> _suspendMicForBeep() async {
    if (_detector == null) return;
    await _detector!.stop();
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _resumeMicAfterBeep({required bool acceptShots}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted || _inputMode == ShotInputMode.manual) return;
    _detector?.prepareForShotCapture();
    await _restartMic(acceptShots: acceptShots, forceRestart: true);
  }

  void _syncMicAcceptsShots() {
    _detector?.acceptsEvents = _micAcceptsShots;
  }

  Future<void> _onRunEnded({bool refreshMic = true}) async {
    _detector?.acceptsEvents = false;
    if (refreshMic) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await _ensureMicMeterActive();
    }
  }

  @override
  void initState() {
    super.initState();
    _syncDetector();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showRangeToolSetupIfNeeded(
        context,
        toolName: 'Shot timer',
        initialMode: _inputMode,
        initialStrictness: _strictness,
        onMicCalibrationStart: _releaseMic,
        onMicCalibrationEnd: () => _restartMic(),
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
    _timer?.cancel();
    _detector?.dispose();
    super.dispose();
  }

  Future<void> _releaseMic() async {
    await _detector?.stop();
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _restartMic({
    bool acceptShots = false,
    bool forceRestart = false,
  }) async {
    if (_inputMode == ShotInputMode.manual) return;

    _detector ??= ShotAudioDetector(
      strictness: _strictness,
      onShot: (_) {
        if (!mounted) return;
        _recordSplit(fromAudio: true);
      },
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
      ..acceptsEvents = acceptShots;

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

      if (_detector!.isListening &&
          !forceRestart &&
          _detector!.isStreamAlive) {
        if (mounted) {
          setState(() {
            _listening = true;
            _permissionDenied = false;
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
      if (mounted) setState(() => _permissionDenied = false);
      return;
    }
    await _restartMic(acceptShots: _micAcceptsShots);
  }

  void _resetRunState() {
    _timer?.cancel();
    setState(() {
      _phase = _TimerPhase.idle;
      _finishReason = _FinishReason.none;
      _elapsed = 0;
      _splits.clear();
      _startedAt = null;
      _lastAudioFlash = false;
    });
  }

  void _reset() {
    _resetRunState();
    unawaited(_onRunEnded());
  }

  void _finishRun({required bool dnf}) {
    if (_phase != _TimerPhase.running) return;
    _timer?.cancel();
    unawaited(_finishRunAsync(dnf: dnf));
  }

  Future<void> _finishRunAsync({required bool dnf}) async {
    if (_inputMode != ShotInputMode.manual && dnf) {
      await _suspendMicForBeep();
    }
    if (dnf) {
      await RangeBeep.playPar();
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    if (!mounted) return;
    setState(() {
      _phase = _TimerPhase.finished;
      _finishReason =
          dnf ? _FinishReason.courseDnf : _FinishReason.courseComplete;
    });
    await _onRunEnded();
  }

  double? get _activeTimeLimit {
    if (_runStyle != _TimerRunStyle.courseRun || _courseLimitUnlimited) {
      return null;
    }
    return _courseLimitSeconds;
  }

  Future<void> _startSequence() async {
    _resetRunState();
    setState(() => _phase = _TimerPhase.waiting);

    if (_inputMode != ShotInputMode.manual) {
      await _restartMic(acceptShots: false);
    }

    final delayRange = (_delayMax - _delayMin).clamp(0, 60);
    final waitSeconds = _delayMin + Random().nextDouble() * delayRange;
    await Future<void>.delayed(Duration(milliseconds: (waitSeconds * 1000).round()));
    if (!mounted || _phase != _TimerPhase.waiting) return;

    if (_inputMode != ShotInputMode.manual) {
      await _suspendMicForBeep();
    }
    await RangeBeep.playStart();
    HapticFeedback.heavyImpact();

    _startedAt = DateTime.now();
    setState(() {
      _phase = _TimerPhase.running;
      _finishReason = _FinishReason.none;
      _elapsed = 0;
    });

    if (_inputMode != ShotInputMode.manual) {
      await _resumeMicAfterBeep(acceptShots: true);
    }

    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_startedAt == null) return;
      final next = DateTime.now().difference(_startedAt!).inMilliseconds / 1000;
      setState(() => _elapsed = next);

      if (_runStyle == _TimerRunStyle.parDrill && next >= _parSeconds) {
        _timer?.cancel();
        unawaited(_completeParDrill());
        return;
      }

      final limit = _activeTimeLimit;
      if (limit != null && next >= limit) {
        _finishRun(dnf: true);
      }
    });
  }

  Future<void> _completeParDrill() async {
    if (_inputMode != ShotInputMode.manual) {
      await _suspendMicForBeep();
    }
    await RangeBeep.playPar();
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() {
      _phase = _TimerPhase.finished;
      _finishReason = _FinishReason.parTime;
    });
    await _onRunEnded();
  }

  void _recordSplit({bool fromAudio = false}) {
    if (_setupGuideOpen) return;
    if (_phase != _TimerPhase.running) return;
    if (fromAudio && _inputMode == ShotInputMode.manual) return;
    if (!fromAudio && _inputMode == ShotInputMode.audio) return;

    HapticFeedback.lightImpact();
    setState(() {
      _splits.add(_elapsed);
      if (fromAudio) _lastAudioFlash = true;
    });

    if (fromAudio) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (mounted) setState(() => _lastAudioFlash = false);
      });
    }
  }

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
    _syncMicAcceptsShots();
  }

  Future<void> _openSetup() async {
    _applySetupGuideOpen(true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RangeToolSetupSheet(
        toolName: 'Shot timer',
        initialMode: _inputMode,
        initialStrictness: _strictness,
        onMicCalibrationStart: _releaseMic,
        onMicCalibrationEnd: () => _restartMic(),
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

  bool get _manualSplitEnabled =>
      _inputMode == ShotInputMode.manual || _inputMode == ShotInputMode.both;

  String _format(double seconds) => seconds.toStringAsFixed(2);

  Color _phaseColor(ThemeData theme) => switch (_phase) {
        _TimerPhase.running => theme.colorScheme.primary,
        _TimerPhase.waiting => theme.colorScheme.tertiary,
        _TimerPhase.finished => theme.colorScheme.secondary,
        _TimerPhase.idle => theme.colorScheme.onSurfaceVariant,
      };

  String get _phaseLabel => switch (_phase) {
        _TimerPhase.idle => 'Ready',
        _TimerPhase.waiting => 'Wait for the beep…',
        _TimerPhase.running => _runStyle == _TimerRunStyle.courseRun
            ? 'Course in progress'
            : 'Shoot!',
        _TimerPhase.finished => switch (_finishReason) {
            _FinishReason.parTime =>
              _elapsed > _parSeconds ? 'Over par' : 'Par or better',
            _FinishReason.courseComplete => 'Run complete',
            _FinishReason.courseDnf => 'Time limit — DNF',
            _FinishReason.none => 'Finished',
          },
      };

  String get _timerSubtitle {
    final splits = '${_splits.length} splits';
    if (_runStyle == _TimerRunStyle.courseRun) {
      if (_courseLimitUnlimited) {
        return 'Unlimited · $splits';
      }
      return 'Limit ${_format(_courseLimitSeconds)} s · $splits';
    }
    return 'Par ${_format(_parSeconds)} s · $splits';
  }

  double? get _progressLimit {
    if (_phase != _TimerPhase.running) return null;
    if (_runStyle == _TimerRunStyle.parDrill) return _parSeconds;
    return _activeTimeLimit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = _phase == _TimerPhase.running;
    final waiting = _phase == _TimerPhase.waiting;

    return Scaffold(
      appBar: AppScreenAppBar.back(
        context,
        title: 'Shot timer',
        fallbackRoute: '/tools',
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Setup guide',
            onPressed: _openSetup,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _IntroCard(
            expanded: _introExpanded,
            onToggle: () => setState(() => _introExpanded = !_introExpanded),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _lastAudioFlash
                    ? theme.colorScheme.primary
                    : _phaseColor(theme).withAlpha(running ? 180 : 60),
                width: running || _lastAudioFlash ? 3 : 1,
              ),
            ),
            child: Material(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      _phaseLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _phaseColor(theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (waiting) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Random delay ${_delayMin.toStringAsFixed(1)}–${_delayMax.toStringAsFixed(1)} s',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      _format(_elapsed),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: running ? theme.colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timerSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_phase == _TimerPhase.running &&
                        _runStyle == _TimerRunStyle.courseRun &&
                        _courseLimitUnlimited) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Assistant: tap Finish when the stage is done',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                    if (_progressLimit != null &&
                        _elapsed > _progressLimit! * 0.85) ...[
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: (_elapsed / _progressLimit!).clamp(0, 1),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                        color: _runStyle == _TimerRunStyle.courseRun
                            ? theme.colorScheme.error
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: waiting ? null : _startSequence,
                  icon: Icon(
                    waiting
                        ? Icons.hourglass_top_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    _phase == _TimerPhase.idle || _phase == _TimerPhase.finished
                        ? (_runStyle == _TimerRunStyle.courseRun
                            ? 'Start course'
                            : 'Start drill')
                        : 'Restart',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (running && _runStyle == _TimerRunStyle.courseRun)
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _finishRun(dnf: false),
                    child: const Text('Finish'),
                  ),
                )
              else if (running && _manualSplitEnabled)
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _recordSplit(),
                    child: const Text('Split'),
                  ),
                )
              else if (!waiting)
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
            ],
          ),
          if (running &&
              _runStyle == _TimerRunStyle.courseRun &&
              _manualSplitEnabled) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _recordSplit(),
                child: const Text('Manual split'),
              ),
            ),
          ],
          if (waiting && _inputMode != ShotInputMode.manual) ...[
            const SizedBox(height: 10),
            Text(
              'Mic live — clap to check the meter. Shots are ignored until the beep.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (running && _inputMode == ShotInputMode.audio) ...[
            const SizedBox(height: 10),
            Text(
              'Listening for gunshots only — raise strictness if voices trigger splits.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
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
          const SizedBox(height: 8),
          _SettingsPanel(
            expanded: _settingsExpanded,
            onToggle: () => setState(() => _settingsExpanded = !_settingsExpanded),
            runStyle: _runStyle,
            onRunStyleChanged: (v) => setState(() => _runStyle = v),
            parSeconds: _parSeconds,
            courseLimitUnlimited: _courseLimitUnlimited,
            courseLimitSeconds: _courseLimitSeconds,
            onCourseLimitUnlimitedChanged: (v) =>
                setState(() => _courseLimitUnlimited = v),
            onCourseLimitSecondsChanged: (v) =>
                setState(() => _courseLimitSeconds = v),
            delayMin: _delayMin,
            delayMax: _delayMax,
            onParChanged: (v) => setState(() => _parSeconds = v),
            onDelayMinChanged: (v) => setState(() {
              _delayMin = v;
              if (_delayMax < _delayMin) _delayMax = _delayMin;
            }),
            onDelayMaxChanged: (v) => setState(() => _delayMax = v),
          ),
          if (_splits.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Shots & splits', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _splits.asMap().entries.map((e) {
                  final delta = e.key == 0
                      ? e.value
                      : e.value - _splits[e.key - 1];
                  final label =
                      e.key == 0 ? 'First shot' : 'Split ${e.key + 1}';
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      child: Text(
                        e.key == 0 ? '1' : '${e.key + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    title: Text(label),
                    subtitle: Text(
                      e.key == 0
                          ? '${_format(e.value)} s from start'
                          : '${_format(e.value)} s total',
                    ),
                    trailing: Text(
                      e.key == 0
                          ? 'start → shot'
                          : '+${_format(delta)} s',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
            title: Text(ShotTimerHelp.introTitle),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: onToggle,
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                ShotTimerHelp.introBody,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.expanded,
    required this.onToggle,
    required this.runStyle,
    required this.onRunStyleChanged,
    required this.parSeconds,
    required this.courseLimitUnlimited,
    required this.courseLimitSeconds,
    required this.onCourseLimitUnlimitedChanged,
    required this.onCourseLimitSecondsChanged,
    required this.delayMin,
    required this.delayMax,
    required this.onParChanged,
    required this.onDelayMinChanged,
    required this.onDelayMaxChanged,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final _TimerRunStyle runStyle;
  final ValueChanged<_TimerRunStyle> onRunStyleChanged;
  final double parSeconds;
  final bool courseLimitUnlimited;
  final double courseLimitSeconds;
  final ValueChanged<bool> onCourseLimitUnlimitedChanged;
  final ValueChanged<double> onCourseLimitSecondsChanged;
  final double delayMin;
  final double delayMax;
  final ValueChanged<double> onParChanged;
  final ValueChanged<double> onDelayMinChanged;
  final ValueChanged<double> onDelayMaxChanged;

  String get _subtitle {
    final delay =
        'Delay ${delayMin.toStringAsFixed(1)}–${delayMax.toStringAsFixed(1)} s';
    if (runStyle == _TimerRunStyle.courseRun) {
      final limit = courseLimitUnlimited
          ? 'Unlimited'
          : '${courseLimitSeconds.round()} s limit';
      return 'Course run · $limit · $delay';
    }
    return 'Par drill · ${parSeconds.toStringAsFixed(1)} s · $delay';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Drill settings'),
            subtitle: Text(_subtitle),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: onToggle,
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                ShotTimerHelp.runStyleBody,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<_TimerRunStyle>(
                segments: const [
                  ButtonSegment(
                    value: _TimerRunStyle.parDrill,
                    label: Text(ShotTimerHelp.parDrillLabel),
                    icon: Icon(Icons.speed_rounded),
                  ),
                  ButtonSegment(
                    value: _TimerRunStyle.courseRun,
                    label: Text(ShotTimerHelp.courseRunLabel),
                    icon: Icon(Icons.flag_rounded),
                  ),
                ],
                selected: {runStyle},
                onSelectionChanged: (s) => onRunStyleChanged(s.first),
              ),
            ),
            const SizedBox(height: 8),
            if (runStyle == _TimerRunStyle.parDrill)
              _ExplainedSlider(
                title: ShotTimerHelp.parTitle,
                explanation: ShotTimerHelp.parBody,
                value: parSeconds,
                min: 1,
                max: 10,
                divisions: 18,
                format: (v) => '${v.toStringAsFixed(1)} s',
                onChanged: onParChanged,
              )
            else ...[
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text('Unlimited par'),
                subtitle: Text(
                  ShotTimerHelp.courseLimitBody,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                ),
                value: courseLimitUnlimited,
                onChanged: onCourseLimitUnlimitedChanged,
              ),
              if (!courseLimitUnlimited)
                _ExplainedSlider(
                  title: ShotTimerHelp.courseLimitTitle,
                  explanation: ShotTimerHelp.courseLimitBody,
                  value: courseLimitSeconds,
                  min: 30,
                  max: 240,
                  divisions: 21,
                  format: (v) => '${v.round()} s',
                  onChanged: onCourseLimitSecondsChanged,
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                ShotTimerHelp.delayBody,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ),
            _ExplainedSlider(
              title: ShotTimerHelp.delayMinTitle,
              explanation: ShotTimerHelp.delayMinBody,
              value: delayMin,
              min: 0,
              max: 8,
              divisions: 16,
              format: (v) => '${v.toStringAsFixed(1)} s',
              onChanged: onDelayMinChanged,
            ),
            _ExplainedSlider(
              title: ShotTimerHelp.delayMaxTitle,
              explanation: ShotTimerHelp.delayMaxBody,
              value: delayMax,
              min: delayMin,
              max: 10,
              divisions: 20,
              format: (v) => '${v.toStringAsFixed(1)} s',
              onChanged: onDelayMaxChanged,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ExplainedSlider extends StatelessWidget {
  const _ExplainedSlider({
    required this.title,
    required this.explanation,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
  });

  final String title;
  final String explanation;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: theme.textTheme.titleSmall),
              ),
              Text(format(value), style: theme.textTheme.titleSmall),
            ],
          ),
          Text(
            explanation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
