import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_service.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../shared/models/structured_log_reminder_models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../events/providers/events_provider.dart';

/// Website-aligned reminder cards for unlinked structured club shoots.
class StructuredLogRemindersSection extends ConsumerWidget {
  const StructuredLogRemindersSection({
    super.key,
    this.compact = false,
    this.maxItems,
  });

  final bool compact;
  final int? maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remindersAsync = ref.watch(structuredLogRemindersProvider);

    return remindersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (reminders) {
        if (reminders.isEmpty) return const SizedBox.shrink();

        final visible = maxItems != null
            ? reminders.take(maxItems!).toList()
            : reminders;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    compact
                        ? 'Unlinked structured shoots'
                        : 'Personal shoot logs needed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!compact)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '${reminders.length} pending',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              Text(
                'You took part in structured club shoots but have not linked a '
                'personal shoot log yet. Record rounds fired, firearms, and ammo '
                'for your records.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...visible.map(
              (reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ReminderCard(reminder: reminder),
              ),
            ),
            if (maxItems != null && reminders.length > maxItems!)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.push('/shoot-log'),
                  child: Text('View all ${reminders.length} reminders'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReminderCard extends ConsumerStatefulWidget {
  const _ReminderCard({required this.reminder});

  final StructuredLogReminder reminder;

  @override
  ConsumerState<_ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends ConsumerState<_ReminderCard> {
  var _busy = false;

  Future<void> _dismiss() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(apiServiceProvider)
          .dismissStructuredLogReminder(widget.reminder.eventId);
    } catch (_) {
      await ref
          .read(appPreferencesProvider)
          .dismissStructuredLogEvent(widget.reminder.eventId);
    } finally {
      ref.invalidate(structuredLogRemindersProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _linkLog(LinkableShootLogRef log) async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).linkStructuredLogReminder(
            eventId: widget.reminder.eventId,
            shootLogId: log.id,
          );
      ref.invalidate(structuredLogRemindersProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shoot log linked to event.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not link log: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = widget.reminder;
    final meta = [
      if (reminder.eventDate != null)
        '${reminder.eventDate!.day}/${reminder.eventDate!.month}/${reminder.eventDate!.year}',
      reminder.clubName,
      reminder.disciplineName,
    ].whereType<String>().where((v) => v.isNotEmpty).join(' · ');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          reminder.eventName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (reminder.shootStatusLabel != null)
                          _StatusPill(label: reminder.shootStatusLabel!),
                      ],
                    ),
                    if (meta.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          meta,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => context.push(reminder.createLogPath),
                child: const Text('Create shoot log'),
              ),
              OutlinedButton(
                onPressed:
                    _busy ? null : () => context.push(reminder.eventDetailPath),
                child: const Text('View event'),
              ),
              TextButton(
                onPressed: _busy ? null : _dismiss,
                child: const Text('Dismiss'),
              ),
            ],
          ),
          if (reminder.linkableLogs.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Or link an existing log from around this date',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reminder.linkableLogs
                  .map(
                    (log) => OutlinedButton(
                      onPressed: _busy ? null : () => _linkLog(log),
                      child: Text('Link ${log.linkLabel}'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
