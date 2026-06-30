import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/events_provider.dart';
import '../widgets/event_checkin_qr_panel.dart';

class EventCheckinDeskScreen extends ConsumerStatefulWidget {
  const EventCheckinDeskScreen({super.key, required this.eventId});

  final int eventId;

  @override
  ConsumerState<EventCheckinDeskScreen> createState() =>
      _EventCheckinDeskScreenState();
}

class _EventCheckinDeskScreenState extends ConsumerState<EventCheckinDeskScreen> {
  final _userIdCtrl = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(checkinDeskProvider(widget.eventId));
    ref.invalidate(eventDetailProvider(widget.eventId));
  }

  Future<void> _endShootDay() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End shoot day?'),
        content: const Text(
          'Close check-in for arrivals. If the linked shoot is live, it will '
          'be marked completed and final scores saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close check-in & end shoot'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final result =
          await ref.read(apiServiceProvider).endShootDay(widget.eventId);
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Shoot day ended.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleCheckin(bool open) async {
    setState(() => _busy = true);
    try {
      final result = await ref.read(apiServiceProvider).toggleCheckinDesk(
            widget.eventId,
            open: open,
          );
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _staffCheckin() async {
    final userId = int.tryParse(_userIdCtrl.text.trim());
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid user ID.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final result =
          await ref.read(apiServiceProvider).staffCheckin(widget.eventId, userId);
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Checked in.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _undoCheckin(int userId) async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).undoStaffCheckin(widget.eventId, userId);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deskAsync = ref.watch(checkinDeskProvider(widget.eventId));

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Check-in desk'),
      body: deskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load check-in desk.',
          onRetry: _refresh,
        ),
        data: (desk) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: desk.checkinOpen
                      ? theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.35)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Self check-in',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desk.checkinOpen
                              ? 'Members can scan the QR or enter the PIN. '
                                  'Walk-ins do not need a prior RSVP if eligible.'
                              : 'Check-in is closed — open when the desk is ready.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (desk.setupBlocked != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            desk.setupBlocked!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _busy || !desk.canOpenCheckin
                                    ? null
                                    : () => _toggleCheckin(true),
                                child: const Text('Open check-in'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    _busy || !desk.checkinOpen
                                        ? null
                                        : () => _toggleCheckin(false),
                                child: const Text('Close'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (desk.canEndShootDay) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End shoot day',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Close check-in for arrivals. If the linked shoot '
                            'is live, it will be marked completed.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _busy ? null : _endShootDay,
                            icon: const Icon(Icons.event_busy_outlined),
                            label: const Text('Close check-in & end shoot'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: EventCheckinQrPanel(
                      checkinUrl: desk.checkinUrl,
                      checkinPin: desk.checkinPin,
                      enabled: desk.checkinOpen,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Staff check-in',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _userIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Member user ID',
                    helperText: 'Check in a member without QR/PIN',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _busy ? null : _staffCheckin,
                  child: const Text('Check in member'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Checked in (${desk.checkedIn.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (desk.checkedIn.isEmpty)
                  Text(
                    'Nobody checked in yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final attendee in desk.checkedIn)
                    ListTile(
                      title: Text(attendee.name),
                      subtitle: Text('User #${attendee.userId}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.undo_rounded),
                        tooltip: 'Undo check-in',
                        onPressed:
                            _busy ? null : () => _undoCheckin(attendee.userId),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
