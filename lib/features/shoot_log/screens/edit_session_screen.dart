import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/sync/shoot_session_payload.dart';
import '../../../shared/shoot_log/shoot_log_constants.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/form_field_label.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/shoot_log_provider.dart';

class EditSessionScreen extends ConsumerStatefulWidget {
  const EditSessionScreen({super.key, required this.localId});

  final int localId;

  @override
  ConsumerState<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends ConsumerState<EditSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  ShootSession? _session;
  var _loading = true;

  late DateTime _date;
  late String _discipline;
  late String _sessionType;
  late String _venueType;
  final _rangeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _roundsCtrl = TextEditingController();
  final _hitsCtrl = TextEditingController();
  final _missesCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  var _rating = 0;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = await ref
        .read(appDatabaseProvider)
        .shootSessionDao
        .getByLocalId(widget.localId);
    if (!mounted) return;
    if (session == null) {
      setState(() => _loading = false);
      return;
    }
    _session = session;
    _date = session.date;
    _discipline = session.discipline;
    _sessionType = session.sessionType;
    _venueType = session.venueType ?? 'outdoor';
    _rangeCtrl.text = session.rangeName ?? '';
    _locationCtrl.text = session.location ?? '';
    _roundsCtrl.text = session.totalRounds?.toString() ?? '';
    _hitsCtrl.text = session.totalHits?.toString() ?? '';
    _missesCtrl.text = session.totalMisses?.toString() ?? '';
    _scoreCtrl.text = session.totalScore?.toString() ?? '';
    _notesCtrl.text = session.notes ?? '';
    _rating = session.rating ?? 0;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _rangeCtrl.dispose();
    _locationCtrl.dispose();
    _roundsCtrl.dispose();
    _hitsCtrl.dispose();
    _missesCtrl.dispose();
    _scoreCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_session == null || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    final session = _session!;

    final companion = ShootSessionsCompanion(
      id: Value(session.id),
      date: Value(_date),
      discipline: Value(_discipline),
      sessionType: Value(_sessionType),
      rangeName: Value(_rangeCtrl.text.trim().isEmpty ? null : _rangeCtrl.text.trim()),
      venueType: Value(_venueType),
      location: Value(
        _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      ),
      latitude: Value(session.latitude),
      longitude: Value(session.longitude),
      firearmId: Value(session.firearmId),
      ammoLoadId: Value(session.ammoLoadId),
      equipmentIds: Value(session.equipmentIds),
      totalRounds: Value(int.tryParse(_roundsCtrl.text)),
      totalHits: Value(int.tryParse(_hitsCtrl.text)),
      totalMisses: Value(int.tryParse(_missesCtrl.text)),
      totalScore: Value(double.tryParse(_scoreCtrl.text)),
      rating: Value(_rating > 0 ? _rating : null),
      notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      weatherCondition: Value(session.weatherCondition),
      temperature: Value(session.temperature),
      windSpeed: Value(session.windSpeed),
      windDirection: Value(session.windDirection),
      humidity: Value(session.humidity),
      pressure: Value(session.pressure),
      eventId: Value(session.eventId),
      serverId: Value(session.serverId),
    );

    final payload = buildShootSessionPayload(
      date: _date,
      discipline: _discipline,
      sessionType: _sessionType,
      rangeName: _rangeCtrl.text.trim().isEmpty ? null : _rangeCtrl.text.trim(),
      venueType: _venueType,
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      latitude: session.latitude,
      longitude: session.longitude,
      firearmId: session.firearmId,
      ammoLoadId: session.ammoLoadId,
      equipmentIds: decodeEquipmentIds(session.equipmentIds),
      totalRounds: int.tryParse(_roundsCtrl.text),
      totalHits: int.tryParse(_hitsCtrl.text),
      totalMisses: int.tryParse(_missesCtrl.text),
      totalScore: double.tryParse(_scoreCtrl.text),
      rating: _rating > 0 ? _rating : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      weatherCondition: session.weatherCondition,
      temperature: session.temperature,
      windSpeed: session.windSpeed,
      windDirection: session.windDirection,
      humidity: session.humidity,
      pressure: session.pressure,
      eventId: session.eventId,
    );

    final error = await ref.read(shootLogProvider.notifier).updateSession(
          localId: session.id,
          serverId: session.serverId,
          companion: companion,
          payload: payload,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session updated')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppScreenAppBar.back(context, title: 'Edit session'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_session == null) {
      return Scaffold(
        appBar: AppScreenAppBar.back(context, title: 'Edit session'),
        body: const Center(child: Text('Session not found')),
      );
    }

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Edit session'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(
                '${_date.day}/${_date.month}/${_date.year} ${_date.hour}:${_date.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked == null) return;
                if (!mounted) return;
                setState(() {
                  _date = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    _date.hour,
                    _date.minute,
                  );
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _discipline,
              decoration: const InputDecoration(
                labelText: 'Discipline',
                border: OutlineInputBorder(),
              ),
              items: ShootLogConstants.disciplines.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _discipline = v);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _sessionType,
              decoration: const InputDecoration(
                labelText: 'Session type',
                border: OutlineInputBorder(),
              ),
              items: ShootLogConstants.sessionTypes.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _sessionType = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rangeCtrl,
              decoration: const InputDecoration(
                labelText: 'Range name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const FormSectionHeader(title: 'Results'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _roundsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rounds fired',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hitsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hits',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _missesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Misses',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _scoreCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Score',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text('Rating', style: Theme.of(context).textTheme.labelLarge),
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star == _rating ? 0 : star),
                  icon: Icon(
                    star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save changes',
              onPressed: _saving ? null : _save,
              isLoading: _saving,
              icon: Icons.save_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
