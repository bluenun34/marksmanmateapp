String formatSessionDateShort(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year}';
}

String formatSessionDateHuman(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final sessionDay = DateTime(local.year, local.month, local.day);

  if (sessionDay == today) return 'Today';

  final yesterday = today.subtract(const Duration(days: 1));
  if (sessionDay == yesterday) return 'Yesterday';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

String formatSessionDateLabel(DateTime value) {
  return '${formatSessionDateHuman(value)} · ${formatSessionDateShort(value)}';
}
