import 'package:flutter/material.dart';

import '../services/rifle_level_math.dart';
import 'level_horizon_display.dart';

/// Guided setup — mount, level roll, fine-tune, calibrate (4 steps).
enum SetupGuideStep {
  mountPhone('Mount phone', Icons.phone_android_rounded),
  levelRoll('Level roll', Icons.swap_horiz_rounded),
  levelBoth('Fine-tune', Icons.adjust_rounded),
  calibrate('Calibrate zero', Icons.center_focus_strong_rounded);

  const SetupGuideStep(this.title, this.icon);

  final String title;
  final IconData icon;

  static const stepCount = 4;

  SetupGuideStep? get next {
    final i = index;
    return i < SetupGuideStep.calibrate.index ? SetupGuideStep.values[i + 1] : null;
  }
}

class LevelSetupGuide extends StatelessWidget {
  const LevelSetupGuide({
    super.key,
    required this.step,
    required this.rollDeg,
    required this.inclinationDeg,
    required this.zones,
    required this.rollDirection,
    required this.steadyGreen,
    required this.calibrating,
    required this.showTenths,
    required this.showInclination,
    required this.onStepChange,
    required this.onCalibrate,
  });

  final SetupGuideStep step;
  final double rollDeg;
  final double inclinationDeg;
  final LevelZoneConfig zones;
  final RollDirection rollDirection;
  final bool steadyGreen;
  final bool calibrating;
  final bool showTenths;
  final bool showInclination;
  final ValueChanged<SetupGuideStep> onStepChange;
  final VoidCallback onCalibrate;

  bool get _rollInGreen =>
      zones.bandForDeviation(rollDeg.abs()) == LevelDeviationBand.good;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      color: const Color(0xFF141414),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _stepIndicator(),
              const SizedBox(height: 12),
              Text(
                step.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _instruction,
                style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
              ),
              if (step.index >= SetupGuideStep.levelRoll.index) ...[
                const SizedBox(height: 10),
                _liveStatus(),
              ],
              const SizedBox(height: 12),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    return Row(
      children: [
        for (final s in SetupGuideStep.values) ...[
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: s.index <= step.index
                    ? LevelHorizonDisplay.horizonFill
                    : Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (s != SetupGuideStep.calibrate) const SizedBox(width: 3),
        ],
      ],
    );
  }

  Widget _liveStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: LevelHorizonDisplay.horizonFill.withAlpha(80),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LevelHorizonDisplay.horizonAccent.withAlpha(100)),
      ),
      child: Row(
        children: [
          Text(
            LevelFormat.rollDisplay(rollDeg, tenths: showTenths),
            style: const TextStyle(
              color: LevelHorizonDisplay.horizonText,
              fontSize: 22,
              fontWeight: FontWeight.w300,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusLine(_rollInGreen),
              style: const TextStyle(
                color: LevelHorizonDisplay.horizonText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _instruction {
    final tol = zones.greenDeg.toStringAsFixed(
      zones.greenDeg < 1 ? 2 : 1,
    );
    return switch (step) {
      SetupGuideStep.mountPhone =>
        'Clamp phone on the left in portrait. Screen toward you, back toward the muzzle.',
      SetupGuideStep.levelRoll =>
        'Adjust rifle cant until roll reads 0° (within ±$tol°). Hold steady, then continue.',
      SetupGuideStep.levelBoth =>
        'Fine-tune roll to 0° and hold steady. Check inclination if shown.',
      SetupGuideStep.calibrate =>
        steadyGreen
            ? 'Hold steady within ±$tol°, then calibrate.'
            : 'Centre roll on 0°, hold steady, then calibrate.',
    };
  }

  String _statusLine(bool inGreen) {
    if (inGreen && steadyGreen) return 'Roll on level — hold steady';
    if (inGreen) return 'Roll in range — hold steady…';
    if (step == SetupGuideStep.levelRoll) {
      return '${rollDirection.label} — need 0° ±${zones.greenDeg.toStringAsFixed(1)}°';
    }
    var line =
        'Roll ${LevelFormat.degrees(rollDeg, tenths: showTenths, signed: true)} — ${rollDirection.label}';
    if (showInclination) {
      line +=
          ', Inc ${LevelFormat.degrees(inclinationDeg, tenths: showTenths, signed: true)}';
    }
    return line;
  }

  Widget _actions() {
    if (step == SetupGuideStep.calibrate) {
      return FilledButton(
        onPressed: calibrating || !steadyGreen ? null : onCalibrate,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          backgroundColor: LevelHorizonDisplay.horizonFill,
          foregroundColor: LevelHorizonDisplay.horizonText,
        ),
        child: calibrating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LevelHorizonDisplay.horizonText,
                ),
              )
            : const Text('Calibrate zero'),
      );
    }

    final canAdvance = switch (step) {
      SetupGuideStep.mountPhone => true,
      SetupGuideStep.levelRoll => _rollInGreen && steadyGreen,
      SetupGuideStep.levelBoth => _rollInGreen && steadyGreen,
      SetupGuideStep.calibrate => false,
    };

    return Row(
      children: [
        if (step.index > 0)
          TextButton(
            onPressed: () => onStepChange(SetupGuideStep.values[step.index - 1]),
            child: const Text('Back'),
          ),
        const Spacer(),
        FilledButton(
          onPressed: canAdvance && step.next != null
              ? () => onStepChange(step.next!)
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: LevelHorizonDisplay.horizonFill,
          foregroundColor: LevelHorizonDisplay.horizonText,
          ),
          child: Text(step == SetupGuideStep.levelBoth ? 'Calibrate next' : 'Continue'),
        ),
      ],
    );
  }
}
