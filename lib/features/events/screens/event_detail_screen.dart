import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/events_provider.dart';
import '../widgets/event_status_chip.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final int eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final _tokenCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _divisionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _pinCtrl.dispose();
    _scoreCtrl.dispose();
    _divisionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(eventDetailProvider(widget.eventId));
    ref.invalidate(eventCheckinProvider(widget.eventId));
    ref.invalidate(eventScoresProvider(widget.eventId));
    ref.invalidate(liveEventScoresProvider(widget.eventId));
  }

  Future<void> _toggleAttend(EventDetailModel detail, bool attend) async {
    setState(() => _busy = true);
    try {
      final api = ref.read(apiServiceProvider);
      if (attend) {
        await api.attendEvent(widget.eventId);
      } else {
        await api.unattendEvent(widget.eventId);
      }
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attend ? 'You are attending.' : 'RSVP removed.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update RSVP: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selfCheckin() async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).selfCheckinEvent(
            widget.eventId,
            token: _tokenCtrl.text.trim(),
            pin: _pinCtrl.text.trim(),
          );
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked in successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _endShootDay() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End shoot day?'),
        content: const Text(
          'Close check-in for arrivals. If the linked shoot is live, it will '
          'be marked completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End shoot day'),
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

  Future<void> _saveSelfScore(int userId) async {
    final score = double.tryParse(_scoreCtrl.text.trim());
    if (score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid score.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).updateEventScore(
            widget.eventId,
            userId,
            score: score,
            division: _divisionCtrl.text.trim().isEmpty
                ? null
                : _divisionCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Score saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save score: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider);
    final detailAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Event'),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load event.',
          onRetry: _refresh,
        ),
        data: (detail) {
          final myScore = detail.scores
              .where((s) => s.userId == auth.user?.id)
              .firstOrNull;
          if (myScore?.score != null && _scoreCtrl.text.isEmpty) {
            _scoreCtrl.text = myScore!.score!.toStringAsFixed(1);
          }
          if (myScore?.division != null && _divisionCtrl.text.isEmpty) {
            _divisionCtrl.text = myScore!.division!;
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  detail.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detail.club?.name != null) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: detail.club!.slug != null
                        ? () => context.push('/clubs/${detail.club!.slug}')
                        : null,
                    child: Row(
                      children: [
                        const Icon(Icons.groups_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            detail.club!.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: detail.club!.slug != null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: detail.club!.slug != null
                                  ? FontWeight.w600
                                  : null,
                            ),
                          ),
                        ),
                        if (detail.club!.slug != null)
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    EventStatusChip.fromDetail(detail),
                    if (detail.discipline?.name != null)
                      Chip(label: Text(detail.discipline!.name)),
                    Chip(label: Text('${detail.attendeeCount} attending')),
                  ],
                ),
                if (detail.eventDate != null) ...[
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: _formatWhen(detail),
                  ),
                ],
                if (detail.location?.isNotEmpty == true)
                  _InfoRow(icon: Icons.place_outlined, label: detail.location!),
                if (detail.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Text(detail.description!),
                ],
                const SizedBox(height: 20),
                _ActionSection(
                  detail: detail,
                  busy: _busy,
                  onAttend: () => _toggleAttend(detail, true),
                  onUnattend: () => _toggleAttend(detail, false),
                  onLog: () => context.push(
                    '/shoot-log/new?event_id=${detail.id}'
                    '${detail.discipline?.key != null ? '&discipline=${detail.discipline!.key}' : ''}'
                    '${detail.location != null ? '&location=${Uri.encodeComponent(detail.location!)}' : ''}',
                  ),
                  onDesk: detail.participation.canManage
                      ? () => context.push('/events/${detail.id}/checkin-desk')
                      : null,
                  onEndShootDay: detail.capabilities.canEndShootDay
                      ? _endShootDay
                      : null,
                  onLiveShoot: detail.linkedShoot != null
                      ? () => context.push(
                            '/shoots/${detail.linkedShoot!.id}/live',
                          )
                      : null,
                  onLiveScores: () =>
                      context.push('/events/${detail.id}/live-scores'),
                ),
                if (detail.participation.canSelfCheckIn ||
                    detail.participation.isCheckedIn) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Check-in',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (detail.participation.isCheckedIn)
                    ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: const Text('You are checked in'),
                      subtitle: detail.participation.checkedInAt != null
                          ? Text(detail.participation.checkedInAt!.toLocal().toString())
                          : null,
                    )
                  else ...[
                    TextField(
                      controller: _tokenCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Check-in token (optional)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pinCtrl,
                      decoration: const InputDecoration(labelText: 'PIN'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _busy ? null : _selfCheckin,
                      icon: const Icon(Icons.qr_code_scanner_outlined),
                      label: const Text('Check in'),
                    ),
                  ],
                ],
                if (detail.allowMemberSelfScoring &&
                    detail.participation.isAttending) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Your score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _scoreCtrl,
                    decoration: const InputDecoration(labelText: 'Score'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (detail.league?.divisions.isNotEmpty == true)
                    DropdownButtonFormField<String>(
                      initialValue: _divisionCtrl.text.isEmpty
                          ? null
                          : _divisionCtrl.text,
                      decoration: const InputDecoration(labelText: 'Division'),
                      items: detail.league!.divisions
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) => _divisionCtrl.text = v ?? '',
                    )
                  else
                    TextField(
                      controller: _divisionCtrl,
                      decoration: const InputDecoration(labelText: 'Division'),
                    ),
                  TextField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy || auth.user == null
                        ? null
                        : () => _saveSelfScore(auth.user!.id),
                    child: const Text('Save score'),
                  ),
                ],
                if (detail.scores.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Scores',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final score in detail.scores)
                    ListTile(
                      title: Text(score.name ?? 'Shooter ${score.userId}'),
                      subtitle: score.division != null
                          ? Text('Division: ${score.division}')
                          : null,
                      trailing: Text(
                        score.score?.toStringAsFixed(1) ?? '—',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatWhen(EventDetailModel detail) {
    final d = detail.eventDate!;
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (detail.startTime != null) {
      final end = detail.endTime != null ? ' – ${detail.endTime}' : '';
      return '$date • ${detail.startTime}$end';
    }
    return date;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.detail,
    required this.busy,
    required this.onAttend,
    required this.onUnattend,
    required this.onLog,
    required this.onLiveScores,
    this.onDesk,
    this.onLiveShoot,
    this.onEndShootDay,
  });

  final EventDetailModel detail;
  final bool busy;
  final VoidCallback onAttend;
  final VoidCallback onUnattend;
  final VoidCallback onLog;
  final VoidCallback onLiveScores;
  final VoidCallback? onDesk;
  final VoidCallback? onLiveShoot;
  final VoidCallback? onEndShootDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (detail.participation.canRsvp) ...[
          if (detail.participation.isAttending)
            OutlinedButton.icon(
              onPressed: busy ? null : onUnattend,
              icon: const Icon(Icons.event_busy_outlined),
              label: const Text('Cancel RSVP'),
            )
          else
            FilledButton.icon(
              onPressed: busy ? null : onAttend,
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('Attend event'),
            ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: onLog,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Log this event'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onLiveScores,
          icon: const Icon(Icons.leaderboard_outlined),
          label: const Text('Live scores'),
        ),
        if (onLiveShoot != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onLiveShoot,
            icon: const Icon(Icons.sports_score_outlined),
            label: const Text('Live shoot'),
          ),
        ],
        if (onDesk != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onDesk,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Check-in desk'),
          ),
        ],
        if (onEndShootDay != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: busy ? null : onEndShootDay,
            icon: const Icon(Icons.event_busy_outlined),
            label: const Text('Close check-in & end shoot'),
          ),
        ],
      ],
    );
  }
}
