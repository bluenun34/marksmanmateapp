import 'package:flutter/material.dart';

import '../../../shared/models/event_models.dart';

/// Status chip aligned with website `x-events.status-badge`.
class EventStatusChip extends StatelessWidget {
  const EventStatusChip({
    super.key,
    this.event,
    this.effectiveStatus,
    this.status,
    this.compact = false,
  }) : assert(event != null || effectiveStatus != null || status != null);

  final EventModel? event;
  final String? effectiveStatus;
  final String? status;
  final bool compact;

  factory EventStatusChip.fromEvent(EventModel event, {bool compact = false}) =>
      EventStatusChip(event: event, compact: compact);

  factory EventStatusChip.fromDetail(
    EventDetailModel detail, {
    bool compact = false,
  }) =>
      EventStatusChip(
        effectiveStatus: detail.effectiveStatus,
        status: detail.status,
        compact: compact,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayStatus = _displayStatus();
    final (label, fg, bg, border) = _style(theme, displayStatus);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _displayStatus() {
    final effective = event?.effectiveStatus ?? effectiveStatus;
    final rawStatus = event?.status ?? status;
    if (effective != null && effective.isNotEmpty) return effective;
    if (rawStatus != null && rawStatus.isNotEmpty) return rawStatus;
    return 'published';
  }

  static (String label, Color fg, Color bg, Color border) _style(
    ThemeData theme,
    String status,
  ) {
    switch (status) {
      case 'live':
        return (
          '● Live',
          Colors.green.shade700,
          Colors.green.withValues(alpha: 0.12),
          Colors.green.withValues(alpha: 0.35),
        );
      case 'ended':
        return (
          'Ended',
          theme.colorScheme.onSurfaceVariant,
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.outlineVariant,
        );
      case 'cancelled':
        return (
          'Cancelled',
          theme.colorScheme.error,
          theme.colorScheme.errorContainer.withValues(alpha: 0.5),
          theme.colorScheme.error.withValues(alpha: 0.35),
        );
      case 'draft':
        return (
          'Draft',
          theme.colorScheme.tertiary,
          theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
          theme.colorScheme.tertiary.withValues(alpha: 0.35),
        );
      case 'published':
        return (
          'Upcoming',
          theme.colorScheme.primary,
          theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          theme.colorScheme.primary.withValues(alpha: 0.25),
        );
      default:
        return (
          status,
          theme.colorScheme.onSurfaceVariant,
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.outlineVariant,
        );
    }
  }
}
