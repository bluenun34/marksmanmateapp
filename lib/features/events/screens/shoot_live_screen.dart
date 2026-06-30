import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/events_provider.dart';
import '../widgets/shoot_scoring_panel.dart';

class ShootLiveScreen extends ConsumerStatefulWidget {
  const ShootLiveScreen({super.key, required this.shootId});

  final int shootId;

  @override
  ConsumerState<ShootLiveScreen> createState() => _ShootLiveScreenState();
}

class _ShootLiveScreenState extends ConsumerState<ShootLiveScreen> {
  var _busy = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted || _busy) return;
      ref.invalidate(shootLiveStateProvider(widget.shootId));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(shootLiveStateProvider(widget.shootId));
    ref.invalidate(shootDetailProvider(widget.shootId));
  }

  Future<void> _advance(String action) async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).advanceShoot(
            widget.shootId,
            action: action,
          );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Advance failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _canControl(Map<String, dynamic>? detail) {
    final access = detail?['access'];
    if (access is! Map) return false;
    return access['can_score'] == true || access['can_manage'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateAsync = ref.watch(shootLiveStateProvider(widget.shootId));
    final detailAsync = ref.watch(shootDetailProvider(widget.shootId));

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Live shoot'),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load shoot state.',
          onRetry: _refresh,
        ),
        data: (state) {
          final detail = detailAsync.maybeWhen(data: (d) => d, orElse: () => null);
          final canControl = _canControl(detail);
          final labels = <String, String>{
            'next_participant': 'Next shooter',
            'next_stand': 'Next stand',
            'next_stage': 'Next stage',
            'next_run': 'Next run',
          };

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  state.shootName ?? 'Shoot #${widget.shootId}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (state.shootStatus != null)
                      Chip(label: Text(state.shootStatus!)),
                    if (state.setupMode != null)
                      Chip(label: Text(state.setupMode!)),
                  ],
                ),
                const SizedBox(height: 16),
                ShootScoringPanel(
                  shootId: widget.shootId,
                  state: state,
                  canScore: canControl,
                  onUpdated: (_) => _refresh(),
                ),
                if (state.rotation != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rotation', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            state.rotation!.entries
                                .map((e) => '${e.key}: ${e.value}')
                                .join('\n'),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (canControl) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Advance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final action in state.advanceActions)
                        FilledButton.tonal(
                          onPressed: _busy ? null : () => _advance(action),
                          child: Text(labels[action] ?? action),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Leaderboard',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (state.leaderboard.isEmpty)
                  Text(
                    'No scores recorded yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (var i = 0; i < state.leaderboard.length; i++)
                    ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(
                        state.leaderboard[i]['name']?.toString() ??
                            'Participant',
                      ),
                      trailing: Text(
                        state.leaderboard[i]['total_points']?.toString() ??
                            state.leaderboard[i]['score_percent']?.toString() ??
                            '—',
                      ),
                    ),
                const SizedBox(height: 16),
                Text(
                  'Participants (${state.participants.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (final p in state.participants)
                  ListTile(
                    title: Text(p['name']?.toString() ?? 'Participant'),
                    subtitle: p['result'] is Map
                        ? Text(
                            'Hits: ${(p['result'] as Map)['hits'] ?? '—'}',
                          )
                        : const Text('No score yet'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
