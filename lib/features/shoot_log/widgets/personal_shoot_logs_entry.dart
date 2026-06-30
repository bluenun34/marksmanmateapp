import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../events/providers/events_provider.dart';

/// Compact entry point for pending personal shoot log reminders.
class PersonalShootLogsEntry extends ConsumerWidget {
  const PersonalShootLogsEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(structuredLogRemindersProvider);

    return remindersAsync.maybeWhen(
      data: (reminders) {
        if (reminders.isEmpty) return const SizedBox.shrink();

        return IconButton(
          tooltip: 'Personal shoot logs',
          onPressed: () => context.push('/shoot-log/personal'),
          icon: Badge(
            isLabelVisible: reminders.isNotEmpty,
            label: Text('${reminders.length}'),
            child: const Icon(Icons.assignment_outlined),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
