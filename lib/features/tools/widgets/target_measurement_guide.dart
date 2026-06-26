import 'package:flutter/material.dart';

import '../../shoot_log/widgets/form_step_indicator.dart';

/// Guidance shown when defining a custom paper target size.
class TargetMeasurementGuide extends StatefulWidget {
  const TargetMeasurementGuide({super.key});

  @override
  State<TargetMeasurementGuide> createState() => _TargetMeasurementGuideState();
}

class _TargetMeasurementGuideState extends State<TargetMeasurementGuide> {
  var _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GuidedStepBanner(
          icon: Icons.straighten_rounded,
          message:
              'Enter the real-world diameter of the scoring face — the part your '
              'group size is measured against — not the full sheet of paper.',
        ),
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'How to measure correctly',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              if (_expanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GuideStep(
                        number: 1,
                        title: 'Measure the scoring face, not the paper',
                        body:
                            'Use the diameter of the black scoring area, outer scoring ring, '
                            'or kill zone — whichever matches how you analyse groups. Ignore '
                            'margins, branding, and the full card or sheet size unless that '
                            'is the scoring face.',
                      ),
                      _GuideStep(
                        number: 2,
                        title: 'Match how the target is shot',
                        body:
                            'Air pistol: usually the black circle (e.g. 59.5 mm). Rimfire cards: '
                            'often the printed target face on the card. HFT/FT: the kill zone '
                            'diameter, not the whole plate.',
                      ),
                      _GuideStep(
                        number: 3,
                        title: 'Photograph face-on',
                        body:
                            'Take the analyser photo square to the target with the full scoring '
                            'face visible. Tilt or perspective makes group size less accurate.',
                      ),
                      _GuideStep(
                        number: 4,
                        title: 'Use mm or inches consistently',
                        body:
                            'Measure with calipers or a ruler, then enter that value here. The app '
                            'converts inches to millimetres for calculations.',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final int number;
  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              '$number',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
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
