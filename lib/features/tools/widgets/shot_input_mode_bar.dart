import 'package:flutter/material.dart';

import '../services/shot_audio_detector.dart';
import 'shot_detection_meter.dart';

class ShotInputModeBar extends StatelessWidget {
  const ShotInputModeBar({
    super.key,
    required this.mode,
    required this.onModeChanged,
    this.strictness,
    this.onStrictnessChanged,
    this.listening = false,
    this.permissionDenied = false,
    this.peakLevel,
    this.peakMarker,
    this.wouldDetect = false,
    this.onShowSetup,
  });

  final ShotInputMode mode;
  final ValueChanged<ShotInputMode> onModeChanged;
  final double? strictness;
  final ValueChanged<double>? onStrictnessChanged;
  final bool listening;
  final bool permissionDenied;
  final double? peakLevel;
  final double? peakMarker;
  final bool wouldDetect;
  final VoidCallback? onShowSetup;

  bool get _showMicControls =>
      mode != ShotInputMode.manual &&
      strictness != null &&
      onStrictnessChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Shot input',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onShowSetup != null)
                  TextButton.icon(
                    onPressed: onShowSetup,
                    icon: const Icon(Icons.help_outline_rounded, size: 18),
                    label: const Text('Setup guide'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SegmentedButton<ShotInputMode>(
              segments: ShotInputMode.values
                  .map(
                    (value) => ButtonSegment(
                      value: value,
                      label: Text(shotInputModeLabel(value)),
                      icon: Icon(switch (value) {
                        ShotInputMode.manual => Icons.touch_app_outlined,
                        ShotInputMode.audio => Icons.mic_rounded,
                        ShotInputMode.both => Icons.merge_rounded,
                      }),
                    ),
                  )
                  .toList(),
              selected: {mode},
              onSelectionChanged: (selection) =>
                  onModeChanged(selection.first),
            ),
            const SizedBox(height: 8),
            Text(
              shotInputModeHint(mode),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (permissionDenied) ...[
              const SizedBox(height: 8),
              Text(
                'Microphone access denied — use Manual mode or allow mic in device settings.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (_showMicControls) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    listening ? Icons.mic_rounded : Icons.mic_off_outlined,
                    size: 18,
                    color: listening
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    listening ? 'Listening for sharp cracks only…' : 'Mic starting…',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Strictness · ${(strictness! * 100).round()}% — ignores speech; counts sharp cracks',
                style: theme.textTheme.bodySmall,
              ),
              Slider(
                value: strictness!,
                min: 0,
                max: 1,
                onChanged: onStrictnessChanged,
              ),
              if (peakLevel != null) ...[
                const SizedBox(height: 4),
                ShotDetectionMeter(
                  meter: peakLevel!,
                  wouldDetect: wouldDetect,
                  peakMarker: peakMarker,
                  showPeakHint: peakMarker != null && peakMarker! > 0.02,
                  showLegend: false,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
