import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/paper_target_type.dart';

const savedTargetSharePrefix = 'marksmanmate-target:';

/// Persists user-defined paper targets on device for reuse and sharing.
class SavedTargetStore {
  static const _prefsKey = 'user_paper_targets';

  Future<List<PaperTargetType>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    final targets = <PaperTargetType>[];
    for (final entry in raw) {
      try {
        targets.add(PaperTargetType.fromJson(jsonDecode(entry) as Map<String, dynamic>));
      } catch (_) {
        // Skip corrupt entries.
      }
    }
    targets.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return targets;
  }

  Future<void> save(PaperTargetType target) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadAll();
    final updated = [
      for (final t in existing)
        if (t.id != target.id) t,
      target,
    ];
    await prefs.setStringList(
      _prefsKey,
      updated.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadAll();
    final updated = existing.where((t) => t.id != id).toList();
    await prefs.setStringList(
      _prefsKey,
      updated.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  Future<void> replaceAll(List<PaperTargetType> targets) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = List<PaperTargetType>.of(targets)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    await prefs.setStringList(
      _prefsKey,
      sorted.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  PaperTargetType? parseShareCode(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith(savedTargetSharePrefix)) return null;
    final payload = trimmed.substring(savedTargetSharePrefix.length);
    try {
      return PaperTargetType.fromJson(jsonDecode(payload) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String shareCodeFor(PaperTargetType target) =>
      '$savedTargetSharePrefix${jsonEncode(target.toJson())}';
}
