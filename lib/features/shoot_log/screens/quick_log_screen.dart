import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/shoot_session_payload.dart';
import '../../../shared/shoot_log/shoot_log_constants.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/form_field_label.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/shoot_log_provider.dart';

const _lastDisciplineKey = 'quick_log_last_discipline';

/// Minimal offline-friendly session logger for use at the range.
class QuickLogScreen extends ConsumerStatefulWidget {
  const QuickLogScreen({
    super.key,
    this.eventId,
    this.initialRounds,
    this.initialHits,
  });

  final int? eventId;
  final int? initialRounds;
  final int? initialHits;

  @override
  ConsumerState<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends ConsumerState<QuickLogScreen> {
  String _discipline = 'rifle';
  String _sessionType = 'practice';
  final _roundsCtrl = TextEditingController();
  final _hitsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialRounds != null && widget.initialRounds! > 0) {
      _roundsCtrl.text = '${widget.initialRounds}';
    }
    if (widget.initialHits != null && widget.initialHits! > 0) {
      _hitsCtrl.text = '${widget.initialHits}';
    }
    _loadLastDiscipline();
  }

  Future<void> _loadLastDiscipline() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_lastDisciplineKey);
    if (saved != null && mounted) {
      setState(() => _discipline = saved);
    }
  }

  @override
  void dispose() {
    _roundsCtrl.dispose();
    _hitsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final rounds = int.tryParse(_roundsCtrl.text.trim());
    if (rounds == null || rounds < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter rounds fired')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final hits = int.tryParse(_hitsCtrl.text.trim());
      final misses =
          hits != null && hits <= rounds ? rounds - hits : null;
      final notes = _notesCtrl.text.trim();

      final companion = ShootSessionsCompanion.insert(
        date: DateTime.now(),
        discipline: _discipline,
        sessionType: _sessionType,
        eventId: Value(widget.eventId),
        totalRounds: Value(rounds),
        totalHits: Value(hits),
        totalMisses: Value(misses),
        notes: Value(notes.isNotEmpty ? notes : null),
      );

      final payload = buildShootSessionPayload(
        date: DateTime.now(),
        discipline: _discipline,
        sessionType: _sessionType,
        totalRounds: rounds,
        totalHits: hits,
        totalMisses: misses,
        notes: notes.isNotEmpty ? notes : null,
        eventId: widget.eventId,
      );

      final outcome = await ref
          .read(shootLogProvider.notifier)
          .createSession(companion, payload);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDisciplineKey, _discipline);

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final message = switch (outcome.result) {
        SessionSaveResult.synced => 'Session saved and synced',
        SessionSaveResult.syncedPhotosPending =>
          outcome.detail ?? 'Session saved',
        SessionSaveResult.savedOffline ||
        SessionSaveResult.savedOfflineAfterApiFailure =>
          outcome.detail ?? 'Saved locally — will sync when online',
        SessionSaveResult.savedOfflinePhotosSkipped =>
          outcome.detail ?? 'Saved locally',
        SessionSaveResult.failed => 'Could not save session',
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
      if (outcome.result != SessionSaveResult.failed) {
        context.go('/shoot-log');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppScreenAppBar.back(
        context,
        title: 'Quick Log',
        fallbackRoute: '/dashboard',
        actions: [
          TextButton(
            onPressed: () {
              final query = widget.eventId != null
                  ? '?event_id=${widget.eventId}'
                  : '';
              context.go('/shoot-log/new$query');
            },
            child: const Text('Full log'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.eventId != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_rounded),
                title: const Text('Linked to website event'),
                subtitle: Text('Event #${widget.eventId}'),
              ),
            ),
          Text(
            'Log the essentials now. Add gear, photos, and weather later from the full log or on the website.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _discipline,
            decoration: fieldDecoration(
              label: 'Discipline',
              requirement: FieldRequirement.required,
            ),
            items: ShootLogConstants.disciplines.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _discipline = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _sessionType,
            decoration: fieldDecoration(
              label: 'Session type',
              requirement: FieldRequirement.required,
            ),
            items: ShootLogConstants.sessionTypes.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _sessionType = v!),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _roundsCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: fieldDecoration(
              label: 'Rounds fired',
              requirement: FieldRequirement.required,
            ).copyWith(contentPadding: const EdgeInsets.symmetric(vertical: 20)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _hitsCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: fieldDecoration(label: 'Hits'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: fieldDecoration(
              label: 'Quick note',
              hintText: 'Optional',
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Save Session',
            icon: Icons.check_rounded,
            isLoading: _submitting,
            onPressed: _submitting ? null : _save,
          ),
        ],
      ),
    );
  }
}
