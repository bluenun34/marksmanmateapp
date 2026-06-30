import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_service.dart';
import '../providers/groups_provider.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';

class CreateGroupEventScreen extends ConsumerStatefulWidget {
  const CreateGroupEventScreen({
    super.key,
    required this.groupId,
    this.groupName,
  });

  final int groupId;
  final String? groupName;

  @override
  ConsumerState<CreateGroupEventScreen> createState() =>
      _CreateGroupEventScreenState();
}

class _CreateGroupEventScreenState extends ConsumerState<CreateGroupEventScreen> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime _eventDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  var _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _busy = true);
    try {
      final event = await ref.read(apiServiceProvider).createGroupEvent(
            widget.groupId,
            name: name,
            eventDate: _formatDate(_eventDate),
            startTime: _startTime != null ? _formatTime(_startTime!) : null,
            endTime: _endTime != null ? _formatTime(_endTime!) : null,
            location: _locationCtrl.text,
            description: _descriptionCtrl.text,
          );
      ref.invalidate(groupDetailProvider(widget.groupId));
      ref.invalidate(
        groupEventsProvider((groupId: widget.groupId, statusFilter: 'upcoming')),
      );
      if (!mounted) return;
      context.go('/events/${event.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group event created.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create event: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.groupName != null
        ? 'Event for ${widget.groupName}'
        : 'Create group event';

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Event name',
              hintText: 'e.g. Saturday practice',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(_formatDate(_eventDate)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _busy ? null : _pickDate,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start time (optional)'),
            subtitle: Text(
              _startTime != null ? _formatTime(_startTime!) : 'Not set',
            ),
            trailing: _startTime != null
                ? IconButton(
                    onPressed: _busy ? null : () => setState(() => _startTime = null),
                    icon: const Icon(Icons.clear),
                  )
                : const Icon(Icons.schedule_outlined),
            onTap: _busy ? null : _pickStartTime,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End time (optional)'),
            subtitle: Text(
              _endTime != null ? _formatTime(_endTime!) : 'Not set',
            ),
            trailing: _endTime != null
                ? IconButton(
                    onPressed: _busy ? null : () => setState(() => _endTime = null),
                    icon: const Icon(Icons.clear),
                  )
                : const Icon(Icons.schedule_outlined),
            onTap: _busy ? null : _pickEndTime,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Location (optional)',
              hintText: 'Range or venue',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionCtrl,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
            ),
            maxLines: 4,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => !_busy ? _submit() : null,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: !_busy ? _submit : null,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create event'),
          ),
        ],
      ),
    );
  }
}
