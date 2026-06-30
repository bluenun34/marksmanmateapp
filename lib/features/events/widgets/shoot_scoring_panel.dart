import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../shared/models/event_models.dart';

class ShootScoringPanel extends ConsumerStatefulWidget {
  const ShootScoringPanel({
    super.key,
    required this.shootId,
    required this.state,
    required this.canScore,
    required this.onUpdated,
  });

  final int shootId;
  final ShootLiveState state;
  final bool canScore;
  final ValueChanged<ShootLiveState> onUpdated;

  @override
  ConsumerState<ShootScoringPanel> createState() => _ShootScoringPanelState();
}

class _ShootScoringPanelState extends ConsumerState<ShootScoringPanel> {
  final _fieldControllers = <String, TextEditingController>{};
  var _busy = false;

  @override
  void dispose() {
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key) {
    return _fieldControllers.putIfAbsent(key, TextEditingController.new);
  }

  Future<void> _run(Future<ShootLiveState> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final next = await action();
      widget.onUpdated(next);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scoring failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  int? get _participantId => widget.state.currentParticipantId;
  int? get _stageId => widget.state.currentStageId;
  int? get _standId => widget.state.currentStandId;

  ApiService get _api => ref.read(apiServiceProvider);

  @override
  Widget build(BuildContext context) {
    if (!widget.canScore) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final pattern = widget.state.scoringPattern;
    final actions = widget.state.scoringActions;
    final fields = widget.state.scoringFields;
    final capture = widget.state.currentCapture;

    if (_participantId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Waiting for the next shooter.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score', style: theme.textTheme.titleMedium),
            if (capture != null && capture.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                capture.entries
                    .where((e) => e.value != null)
                    .map((e) => '${e.key}: ${e.value}')
                    .join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            if (pattern == 'events' || pattern == 'clay_stands')
              _actionButtons(actions, _recordClayOrQuick)
            else if (pattern == 'stage_quick')
              _actionButtons(actions, _recordQuick)
            else if (pattern == 'relay_stage') ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final endpoint in ['start', 'scoring', 'advance'])
                    FilledButton.tonal(
                      onPressed: _busy
                          ? null
                          : () => _run(() => _api.relayAction(
                                widget.shootId,
                                endpoint: endpoint,
                              )),
                      child: Text('Relay $endpoint'),
                    ),
                ],
              ),
            ] else if (fields.isNotEmpty) ...[
              for (final field in fields) ...[
                TextField(
                  controller: _controllerFor(field['key']?.toString() ?? ''),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: field['label']?.toString() ?? 'Score',
                  ),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _busy ? null : _submitFormScore,
                child: Text(
                  widget.state.scoringUi?['save_label']?.toString() ??
                      'Save score',
                ),
              ),
            ] else if (actions.isNotEmpty)
              _actionButtons(actions, _recordQuick),
            if (widget.state.supportsUndo && _standId != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : _undoClay,
                child: const Text('Undo last clay'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(
    List<Map<String, dynamic>> actions,
    Future<void> Function(String key) onTap,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          FilledButton.tonal(
            onPressed: _busy
                ? null
                : () => onTap(action['key']?.toString() ?? ''),
            child: Text(action['label']?.toString() ?? 'Action'),
          ),
      ],
    );
  }

  Future<void> _recordClayOrQuick(String key) async {
    if (_standId != null) {
      await _run(() => _api.recordClayEvent(
            widget.shootId,
            participantId: _participantId!,
            standId: _standId!,
            result: key,
          ));
      return;
    }
    await _recordQuick(key);
  }

  Future<void> _recordQuick(String action) async {
    if (_stageId == null) return;
    await _run(() => _api.recordShootQuickAction(
          widget.shootId,
          participantId: _participantId!,
          stageId: _stageId!,
          action: action,
        ));
  }

  Future<void> _submitFormScore() async {
    if (_participantId == null) return;
    final values = <String, dynamic>{};
    for (final field in widget.state.scoringFields) {
      final key = field['key']?.toString();
      if (key == null) continue;
      final text = _controllerFor(key).text.trim();
      if (text.isEmpty) continue;
      values[key] = num.tryParse(text) ?? text;
    }
    values['finished'] = true;

    if (_stageId != null) {
      await _run(() => _api.recordStageScore(
            widget.shootId,
            participantId: _participantId!,
            stageId: _stageId!,
            fields: values,
          ));
      return;
    }

    await _run(() => _api.recordSimpleScore(
          widget.shootId,
          participantId: _participantId!,
          fields: values,
        ));
  }

  Future<void> _undoClay() async {
    if (_participantId == null || _standId == null) return;
    await _run(() => _api.undoClayEvent(
          widget.shootId,
          participantId: _participantId!,
          standId: _standId!,
        ));
  }
}
