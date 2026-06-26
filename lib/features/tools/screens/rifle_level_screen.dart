import 'dart:async';

import 'dart:math';



import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import 'package:wakelock_plus/wakelock_plus.dart';



import '../services/level_audio_feedback_service.dart';

import '../services/level_haptic_feedback_service.dart';

import '../services/level_reading_smoother.dart';

import '../services/level_settings_repository.dart';

import '../services/rifle_level_math.dart';

import '../services/rifle_level_sensor.dart';

import '../widgets/level_horizon_display.dart';

import '../widgets/level_setup_guide.dart';



/// Phone-as-rifle-level — clinometer horizon UI.

class RifleLevelScreen extends StatefulWidget {

  const RifleLevelScreen({super.key});



  @override

  State<RifleLevelScreen> createState() => _RifleLevelScreenState();

}



class _RifleLevelScreenState extends State<RifleLevelScreen> {

  final _repo = LevelSettingsRepository();

  late final _calibrationService = LevelCalibrationService(_repo);

  final _sensor = RifleLevelSensor();

  final _readingSmoother = LevelReadingSmoother();

  final _audio = LevelAudioFeedbackService();

  final _haptic = LevelHapticFeedbackService();

  StreamSubscription<RifleLevelReading>? _sub;



  LevelSettings _settings = const LevelSettings();

  LevelCalibration _calibration = const LevelCalibration();

  RifleLevelReading? _raw;

  RifleLevelReading? _display;

  var _calibrating = false;

  var _hasCalibration = false;

  SetupGuideStep _setupStep = SetupGuideStep.mountPhone;

  DateTime? _greenSince;



  bool get _isCalibrated => _hasCalibration;



  @override

  void initState() {

    super.initState();

    _bootstrap();

  }



  Future<void> _bootstrap() async {

    final settings = await _repo.loadSettings();

    final cal = await _repo.loadCalibration();

    _hasCalibration = await _repo.hasCalibration();

    _settings = settings;

    _calibration = cal;

    _sensor.mount = MountProfile.defaultMount;

    _sensor.start();

    _applyWakelock();

    _sub = _sensor.readings.listen(_onReading);

    if (mounted) setState(() {});

  }



  void _onReading(RifleLevelReading reading) {

    if (!mounted) return;

    _raw = reading;



    final display = _readingSmoother.smooth(_displayReading(reading));

    final dev = LevelZoneConfig.rollDeviation(display.rollDeg);

    final inGreen =

        _settings.zones.bandForDeviation(dev) == LevelDeviationBand.good;

    if (inGreen) {

      _greenSince ??= DateTime.now();

    } else {

      _greenSince = null;

    }



    setState(() => _display = display);



    if (_settings.mode == LevelDisplayMode.shooting && _isCalibrated) {

      _audio.update(

        deviationDeg: dev,

        rollDeg: display.rollDeg,

        zones: _settings.zones,

        settings: _settings,

        calibrated: true,

      );

      _haptic.update(

        deviationDeg: dev,

        zones: _settings.zones,

        enabled: _settings.hapticEnabled,

        calibrated: true,

      );

    } else {

      _audio.stop();

      _haptic.stop();

    }

  }



  RifleLevelReading _displayReading(RifleLevelReading raw) {

    if (_settings.mode == LevelDisplayMode.shooting && _isCalibrated) {

      return raw.applyCalibration(_calibration);

    }

    return raw;

  }



  Future<void> _applyWakelock() async {

    if (_settings.keepScreenAwake &&

        _settings.mode == LevelDisplayMode.shooting) {

      await WakelockPlus.enable();

    } else {

      await WakelockPlus.disable();

    }

  }



  Future<void> _saveSettings(LevelSettings settings) async {

    _settings = settings;

    await _repo.saveSettings(settings);

    _sensor.mount = MountProfile.defaultMount;

    _readingSmoother.reset();

    await _applyWakelock();

    if (_raw != null) {

      setState(() => _display = _displayReading(_raw!));

    }

  }



  Future<void> _calibrate() async {

    if (_calibrating) return;

    setState(() => _calibrating = true);

    HapticFeedback.mediumImpact();

    try {

      final cal = await _calibrationService.captureZero(_sensor);

      setState(() {

        _calibration = cal;

        _hasCalibration = true;

        _display = _raw?.applyCalibration(cal);

      });

      if (mounted) {

        Navigator.of(context).maybePop();

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text('Zero saved — shooting mode'),

            duration: Duration(seconds: 2),

          ),

        );

      }

      await _saveSettings(_settings.copyWith(mode: LevelDisplayMode.shooting));

    } finally {

      if (mounted) setState(() => _calibrating = false);

    }

  }



  Future<void> _clearCalibration() async {

    await _calibrationService.clear();

    setState(() {

      _calibration = const LevelCalibration();

      _hasCalibration = false;

      _display = _raw;

    });

    _audio.stop();

    _haptic.stop();

  }



  void _cycleTolerance() {

    HapticFeedback.selectionClick();

    if (!_settings.customGreen) {

      final presets = LevelZoneConfig.presets;

      final idx = presets.indexWhere(

        (v) => (v - _settings.zones.greenDeg).abs() < 0.01,

      );

      final next = presets[(idx + 1) % presets.length];

      var yellow = _settings.zones.yellowDeg;

      if (yellow <= next) yellow = next + 1.0;

      _saveSettings(

        _settings.copyWith(

          zones: LevelZoneConfig(greenDeg: next, yellowDeg: yellow),

        ),

      );

      return;

    }

    _showSettings();

  }



  void _toggleInclination() {
    HapticFeedback.selectionClick();
    _saveSettings(_settings.copyWith(showInclination: !_settings.showInclination));
  }

  void _toggleMode() {

    HapticFeedback.selectionClick();

    final next = _settings.mode == LevelDisplayMode.setup

        ? LevelDisplayMode.shooting

        : LevelDisplayMode.setup;

    if (next == LevelDisplayMode.shooting && !_isCalibrated) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text('Calibrate zero first (save icon or setup guide)'),

          duration: Duration(seconds: 2),

        ),

      );

      _showSetupGuide();

      return;

    }

    _saveSettings(_settings.copyWith(mode: next));

  }



  void _showSetupGuide() {

    showModalBottomSheet<void>(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (ctx) {

        return StatefulBuilder(

          builder: (context, setSheet) {

            final d = _display;

            final roll = d?.rollDeg ?? 0;

            final incl = d?.inclinationDeg ?? 0;

            final steadyGreen = _greenSince != null &&

                DateTime.now().difference(_greenSince!).inMilliseconds > 1500;



            return LevelSetupGuide(

              step: _setupStep,

              rollDeg: roll,

              inclinationDeg: incl,

              zones: _settings.zones,

              rollDirection: d?.rollDirection() ?? RollDirection.level,

              steadyGreen: steadyGreen,

              calibrating: _calibrating,

              showTenths: _settings.showTenths,

              showInclination: _settings.showInclination,

              onStepChange: (s) {

                HapticFeedback.selectionClick();

                setSheet(() => _setupStep = s);

                setState(() => _setupStep = s);

              },

              onCalibrate: _calibrate,

            );

          },

        );

      },

    );

  }



  void _showSettings() {

    showModalBottomSheet<void>(

      context: context,

      isScrollControlled: true,

      showDragHandle: true,

      builder: (ctx) {

        var local = _settings;

        var yellow = local.zones.yellowDeg;



        return StatefulBuilder(

          builder: (context, setSheet) {

            final minYellow = local.zones.greenDeg + 0.5;

            if (yellow < minYellow) yellow = minYellow;



            return Padding(

              padding: EdgeInsets.fromLTRB(

                20,

                0,

                20,

                24 + MediaQuery.viewInsetsOf(context).bottom,

              ),

              child: SingleChildScrollView(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [

                    Text('Level settings', style: Theme.of(context).textTheme.titleLarge),

                    const SizedBox(height: 8),

                    Text(

                      MountProfile.defaultMount.hint,

                      style: Theme.of(context).textTheme.bodySmall,

                    ),

                    const SizedBox(height: 16),

                    Text('Roll tolerance', style: Theme.of(context).textTheme.titleSmall),

                    Wrap(

                      spacing: 8,

                      children: [

                        for (final p in LevelZoneConfig.presets)

                          ChoiceChip(

                            label: Text('±${p.toStringAsFixed(2)}°'),

                            selected: !local.customGreen &&

                                (local.zones.greenDeg - p).abs() < 0.01,

                            onSelected: (_) {

                              setSheet(() {

                                local = local.copyWith(

                                  customGreen: false,

                                  zones: LevelZoneConfig(

                                    greenDeg: p,

                                    yellowDeg: max(p + 1, local.zones.yellowDeg),

                                  ),

                                );

                                yellow = local.zones.yellowDeg;

                              });

                              _saveSettings(local);

                            },

                          ),

                        ChoiceChip(

                          label: const Text('Custom'),

                          selected: local.customGreen,

                          onSelected: (_) {

                            setSheet(() => local = local.copyWith(customGreen: true));

                            _saveSettings(local);

                          },

                        ),

                      ],

                    ),

                    if (local.customGreen) ...[

                      Text('Custom ±${local.zones.greenDeg.toStringAsFixed(2)}°'),

                      Slider(

                        value: local.zones.greenDeg,

                        min: 0.1,

                        max: 3,

                        divisions: 29,

                        label: local.zones.greenDeg.toStringAsFixed(2),

                        onChanged: (v) {

                          setSheet(() {

                            local = local.copyWith(

                              zones: local.zones.copyWith(greenDeg: v),

                            );

                          });

                          _saveSettings(local);

                        },

                      ),

                    ],

                    Text('Amber zone — ±${yellow.toStringAsFixed(1)}°'),

                    Slider(

                      value: yellow,

                      min: minYellow,

                      max: 6,

                      divisions: ((6 - minYellow) * 2).round(),

                      onChanged: (v) {

                        setSheet(() {

                          yellow = v;

                          local = local.copyWith(

                            zones: local.zones.copyWith(yellowDeg: v),

                          );

                        });

                        _saveSettings(local);

                      },

                    ),

                    const Divider(height: 28),

                    Text('Display', style: Theme.of(context).textTheme.titleSmall),

                    SwitchListTile(

                      contentPadding: EdgeInsets.zero,

                      title: const Text('Show inclination'),

                      subtitle: const Text('Display only — colours follow roll'),

                      value: local.showInclination,

                      onChanged: (v) {

                        setSheet(() => local = local.copyWith(showInclination: v));

                        _saveSettings(local);

                      },

                    ),

                    SwitchListTile(

                      contentPadding: EdgeInsets.zero,

                      title: const Text('Show tenths (0.1°)'),

                      subtitle: const Text('Off shows whole degrees only'),

                      value: local.showTenths,

                      onChanged: (v) {

                        setSheet(() => local = local.copyWith(showTenths: v));

                        _saveSettings(local);

                      },

                    ),

                    const Divider(height: 28),

                    Text('Feedback', style: Theme.of(context).textTheme.titleSmall),

                    SwitchListTile(

                      contentPadding: EdgeInsets.zero,

                      title: const Text('Audio warning'),

                      subtitle: const Text('Speaker or earbud proximity beeps'),

                      value: local.audioEnabled,

                      onChanged: (v) {

                        setSheet(() => local = local.copyWith(audioEnabled: v));

                        _saveSettings(local);

                      },

                    ),

                    if (local.audioEnabled) ...[

                      SegmentedButton<LevelAudioMode>(

                        segments: const [

                          ButtonSegment(

                            value: LevelAudioMode.speaker,

                            label: Text('Speaker'),

                          ),

                          ButtonSegment(

                            value: LevelAudioMode.stereoEarbuds,

                            label: Text('Earbuds'),

                          ),

                        ],

                        selected: {local.audioMode},

                        onSelectionChanged: (s) {

                          setSheet(() => local = local.copyWith(audioMode: s.first));

                          _saveSettings(local);

                        },

                      ),

                      Text('Volume ${(local.audioVolume * 100).round()}%'),

                      Slider(

                        value: local.audioVolume,

                        min: 0.2,

                        max: 1,

                        onChanged: (v) {

                          setSheet(() => local = local.copyWith(audioVolume: v));

                          _saveSettings(local);

                        },

                      ),

                      SwitchListTile(

                        contentPadding: EdgeInsets.zero,

                        title: const Text('Chirp when level'),

                        value: local.chirpOnLevel,

                        onChanged: (v) {

                          setSheet(() => local = local.copyWith(chirpOnLevel: v));

                          _saveSettings(local);

                        },

                      ),

                    ],

                    SwitchListTile(

                      contentPadding: EdgeInsets.zero,

                      title: const Text('Vibration warning'),

                      value: local.hapticEnabled,

                      onChanged: (v) {

                        setSheet(() => local = local.copyWith(hapticEnabled: v));

                        _saveSettings(local);

                      },

                    ),

                    SwitchListTile(

                      contentPadding: EdgeInsets.zero,

                      title: const Text('Keep screen awake (shooting mode)'),

                      value: local.keepScreenAwake,

                      onChanged: (v) {

                        setSheet(() => local = local.copyWith(keepScreenAwake: v));

                        _saveSettings(local);

                      },

                    ),

                    const SizedBox(height: 8),

                    OutlinedButton(

                      onPressed: () {

                        Navigator.pop(ctx);

                        _clearCalibration();

                      },

                      child: const Text('Clear calibration'),

                    ),

                  ],

                ),

              ),

            );

          },

        );

      },

    );

  }



  @override

  void dispose() {

    _sub?.cancel();

    _audio.dispose();

    _haptic.dispose();

    unawaited(_sensor.dispose());

    unawaited(WakelockPlus.disable());

    super.dispose();

  }



  String get _toleranceLabel {

    final g = _settings.zones.greenDeg;

    if (_settings.customGreen) return '${g.toStringAsFixed(1)}°';

    if ((g - 0.25).abs() < 0.01) return '¼°';

    if ((g - 0.5).abs() < 0.01) return '½°';

    if ((g - 1.0).abs() < 0.01) return '1°';

    return '${g.toStringAsFixed(1)}°';

  }



  @override

  Widget build(BuildContext context) {

    final d = _display;

    final roll = d?.rollDeg ?? 0;

    final incl = d?.inclinationDeg ?? 0;

    final band = _settings.zones.bandForDeviation(roll.abs());

    final shooting = _settings.mode == LevelDisplayMode.shooting;



    return Scaffold(

      backgroundColor: Colors.white,

      body: Stack(

        fit: StackFit.expand,

        children: [

          LevelHorizonDisplay(

            rollDeg: roll,

            inclinationDeg: incl,

            band: band,

            calibrated: _isCalibrated,

            settings: _settings,

          ),

          SafeArea(

            child: Stack(

              children: [

                Positioned(

                  top: 10,

                  left: 10,

                  child: _LevelCircleButton(

                    icon: Icons.arrow_back_rounded,

                    onTap: () => context.pop(),

                  ),

                ),

                Positioned(

                  top: 10,

                  right: 10,

                  child: _LevelCircleButton(

                    icon: Icons.settings_outlined,

                    onTap: _showSettings,

                  ),

                ),

                Positioned(

                  left: 10,

                  bottom: 10,

                  child: Column(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      _LevelCircleButton(

                        label: _toleranceLabel,

                        onTap: _cycleTolerance,

                        tooltip: 'Roll tolerance',

                      ),

                      const SizedBox(height: 10),

                      _LevelCircleButton(

                        icon: _calibrating

                            ? null

                            : Icons.save_outlined,

                        busy: _calibrating,

                        onTap: _calibrate,

                        tooltip: 'Save zero',

                      ),

                    ],

                  ),

                ),

                Positioned(

                  right: 10,

                  bottom: 10,

                  child: Column(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      _LevelCircleButton(

                        icon: Icons.height_rounded,

                        selected: _settings.showInclination,

                        onTap: _toggleInclination,

                        tooltip: 'Show inclination',

                      ),

                      const SizedBox(height: 10),

                      _LevelCircleButton(

                        icon: shooting ? Icons.lock_rounded : Icons.lock_open_rounded,

                        selected: shooting && _isCalibrated,

                        onTap: _toggleMode,

                        tooltip: shooting ? 'Shooting mode' : 'Setup mode',

                      ),

                      const SizedBox(height: 10),

                      _LevelCircleButton(

                        icon: Icons.menu_rounded,

                        onTap: _showSetupGuide,

                        tooltip: 'Setup guide',

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



class _LevelCircleButton extends StatelessWidget {

  const _LevelCircleButton({

    this.icon,

    this.label,

    required this.onTap,

    this.selected = false,

    this.busy = false,

    this.tooltip,

  }) : assert(icon != null || label != null || busy);



  final IconData? icon;

  final String? label;

  final VoidCallback onTap;

  final bool selected;

  final bool busy;

  final String? tooltip;



  static const _accent = LevelHorizonDisplay.horizonAccent;
  static const _fill = LevelHorizonDisplay.horizonFill;



  @override

  Widget build(BuildContext context) {

    final child = busy

        ? const SizedBox(

            width: 22,

            height: 22,

            child: CircularProgressIndicator(strokeWidth: 2, color: _accent),

          )

        : icon != null

            ? Icon(icon, color: _accent, size: 26)

            : Text(

                label!,

                style: const TextStyle(

                  color: _accent,

                  fontWeight: FontWeight.w600,

                  fontSize: 15,

                ),

              );



    final button = Material(

      color: selected ? _fill.withAlpha(120) : Colors.white.withAlpha(235),

      elevation: 1,

      shadowColor: Colors.black26,

      shape: const CircleBorder(),

      clipBehavior: Clip.antiAlias,

      child: InkWell(

        onTap: busy ? null : onTap,

        child: SizedBox(width: 50, height: 50, child: Center(child: child)),

      ),

    );



    if (tooltip == null) return button;

    return Tooltip(message: tooltip!, child: button);

  }

}


