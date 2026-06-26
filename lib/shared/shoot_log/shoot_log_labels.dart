import 'shoot_log_constants.dart';

String disciplineLabel(String key) =>
    ShootLogConstants.disciplines[key] ?? key;

String sessionTypeLabel(String key) =>
    ShootLogConstants.sessionTypes[key] ?? key;

String venueTypeLabel(String? key) {
  if (key == null || key.isEmpty) return '—';
  return key[0].toUpperCase() + key.substring(1);
}
