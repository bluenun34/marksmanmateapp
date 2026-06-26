import '../../../shared/shoot_log/shoot_log_labels.dart';
import '../providers/shoot_log_provider.dart';

class ShootLogFilter {
  const ShootLogFilter({this.query = '', this.discipline});

  final String query;
  final String? discipline;

  ShootLogFilter copyWith({
    String? query,
    String? discipline,
    bool clearDiscipline = false,
  }) {
    return ShootLogFilter(
      query: query ?? this.query,
      discipline: clearDiscipline ? null : (discipline ?? this.discipline),
    );
  }

  List<SessionItem> apply(List<SessionItem> sessions) {
    return sessions.where((item) {
      if (discipline != null && item.discipline != discipline) return false;
      if (query.trim().isEmpty) return true;
      final q = query.trim().toLowerCase();
      final haystack = [
        disciplineLabel(item.discipline),
        sessionTypeLabel(item.sessionType),
        item.rangeName,
        item.local.rangeName,
        item.local.location,
        item.local.notes,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }
}
