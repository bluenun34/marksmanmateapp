import 'package:flutter/material.dart';

enum FieldRequirement { required, optional }

/// Builds an [InputDecoration] with clear required (*) or optional labelling.
InputDecoration fieldDecoration({
  required String label,
  FieldRequirement requirement = FieldRequirement.optional,
  IconData? prefixIcon,
  String? hintText,
  String? helperText,
  bool alignLabelWithHint = false,
}) {
  final suffix = requirement == FieldRequirement.required ? ' *' : '';
  return InputDecoration(
    labelText: '$label$suffix',
    hintText: hintText,
    helperText: helperText ??
        (requirement == FieldRequirement.optional ? 'Optional' : null),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    alignLabelWithHint: alignLabelWithHint,
  );
}

/// Section header matching the website's required/optional grouping.
class FormSectionHeader extends StatelessWidget {
  const FormSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.requirement,
  });

  final String title;
  final String? subtitle;
  final FieldRequirement? requirement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (requirement == FieldRequirement.required)
              Text(
                'Required',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (requirement == FieldRequirement.optional)
              Text(
                'All optional',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Legend shown at the top of long forms.
class FormRequirementLegend extends StatelessWidget {
  const FormRequirementLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        'Fields marked with * are required. Everything else is optional.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
