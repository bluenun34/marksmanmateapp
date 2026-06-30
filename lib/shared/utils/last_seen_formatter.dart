/// Formats last-seen / online status for user profiles.
String formatLastSeen({
  DateTime? lastActiveAt,
  String? lastActiveLabel,
  bool? isOnline,
}) {
  if (isOnline == true) return 'Online now';

  if (lastActiveLabel != null && lastActiveLabel.trim().isNotEmpty) {
    final normalized = lastActiveLabel.trim();
    if (normalized.toLowerCase().startsWith('last seen')) {
      return normalized;
    }
    return 'Last seen $normalized';
  }

  if (lastActiveAt == null) return '';

  final local = lastActiveAt.toLocal();
  final diff = DateTime.now().difference(local);
  if (diff.inMinutes < 5) return 'Online now';
  if (diff.inMinutes < 60) {
    final minutes = diff.inMinutes;
    return 'Last seen ${minutes}m ago';
  }
  if (diff.inHours < 24) {
    final hours = diff.inHours;
    return 'Last seen ${hours}h ago';
  }
  if (diff.inDays < 7) {
    final days = diff.inDays;
    return 'Last seen ${days}d ago';
  }

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return 'Last seen $day/$month/${local.year}';
}
