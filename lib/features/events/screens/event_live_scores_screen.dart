import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/events_provider.dart';

class EventLiveScoresScreen extends ConsumerStatefulWidget {
  const EventLiveScoresScreen({super.key, required this.eventId});

  final int eventId;

  @override
  ConsumerState<EventLiveScoresScreen> createState() =>
      _EventLiveScoresScreenState();
}

class _EventLiveScoresScreenState extends ConsumerState<EventLiveScoresScreen> {
  final _userIdCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _stageCtrl = TextEditingController(text: '1');
  var _busy = false;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _scoreCtrl.dispose();
    _stageCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(liveEventScoresProvider(widget.eventId));
  }

  Future<void> _submitScore() async {
    final userId = int.tryParse(_userIdCtrl.text.trim());
    final score = double.tryParse(_scoreCtrl.text.trim());
    final stage = int.tryParse(_stageCtrl.text.trim()) ?? 1;
    if (userId == null || score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid user ID and score.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).storeLiveEventScore(
            widget.eventId,
            userId: userId,
            score: score,
            stage: stage,
          );
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live score updated.')),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoresAsync = ref.watch(liveEventScoresProvider(widget.eventId));

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Live scores'),
      body: scoresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load live scores.',
          onRetry: _refresh,
        ),
        data: (scores) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Leaderboard',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (scores.isEmpty)
                  Text(
                    'No live scores yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (var i = 0; i < scores.length; i++)
                    ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text('User #${scores[i].userId}'),
                      subtitle: Text('Stage ${scores[i].stage}'),
                      trailing: Text(
                        scores[i].score.toStringAsFixed(1),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                const SizedBox(height: 24),
                Text(
                  'Update score (staff)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _userIdCtrl,
                  decoration: const InputDecoration(labelText: 'User ID'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _scoreCtrl,
                  decoration: const InputDecoration(labelText: 'Score'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _stageCtrl,
                  decoration: const InputDecoration(labelText: 'Stage'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy ? null : _submitScore,
                  child: const Text('Save live score'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
