import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Record and play a short voice note attached to a shoot session.
class VoiceNoteRecorder extends StatefulWidget {
  const VoiceNoteRecorder({
    super.key,
    this.initialPath,
    required this.onPathChanged,
  });

  final String? initialPath;
  final ValueChanged<String?> onPathChanged;

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  String? _path;
  var _recording = false;
  var _playing = false;

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<String> _newFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'voice_notes'));
    if (!await folder.exists()) await folder.create(recursive: true);
    return p.join(folder.path, 'note_${DateTime.now().millisecondsSinceEpoch}.m4a');
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _path = path;
      });
      widget.onPathChanged(_path);
      return;
    }

    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
      return;
    }

    final filePath = await _newFilePath();
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );
    if (!mounted) return;
    setState(() => _recording = true);
  }

  Future<void> _togglePlay() async {
    final path = _path;
    if (path == null || !File(path).existsSync()) return;

    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }

    await _player.play(DeviceFileSource(path));
    if (mounted) setState(() => _playing = true);
  }

  Future<void> _remove() async {
    final path = _path;
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _path = null;
      _playing = false;
    });
    widget.onPathChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNote = _path != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice note',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional spoken notes — useful when your hands are full at the range.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: _toggleRecord,
              icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
              label: Text(_recording ? 'Stop' : hasNote ? 'Re-record' : 'Record'),
            ),
            if (hasNote) ...[
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: _playing ? 'Stop playback' : 'Play voice note',
                onPressed: _togglePlay,
                icon: Icon(_playing ? Icons.stop_circle_outlined : Icons.play_arrow_rounded),
              ),
              IconButton(
                tooltip: 'Remove voice note',
                onPressed: _remove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class VoiceNotePlayer extends StatefulWidget {
  const VoiceNotePlayer({super.key, required this.filePath});

  final String filePath;

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  final _player = AudioPlayer();
  var _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!File(widget.filePath).existsSync()) return;
    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    await _player.play(DeviceFileSource(widget.filePath));
    if (mounted) setState(() => _playing = true);
    _player.onPlayerComplete.first.then((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.mic_rounded),
      title: const Text('Voice note'),
      trailing: IconButton(
        onPressed: _toggle,
        icon: Icon(_playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
      ),
    );
  }
}
