import '../config/app_config.dart';

/// Resolves API/storage paths to a loadable image URL.
String? resolveMediaUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.trim();
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  final base = AppConfig.websiteBaseUrl.replaceAll(RegExp(r'/+$'), '');
  if (value.startsWith('/')) return '$base$value';
  return '$base/$value';
}
