import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../../events/providers/events_provider.dart';
import '../widgets/structured_log_reminders_section.dart';

class PersonalShootLogsScreen extends ConsumerWidget {
  const PersonalShootLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remindersAsync = ref.watch(structuredLogRemindersProvider);

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Personal shoot logs'),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load personal shoot log reminders.',
          onRetry: () => ref.invalidate(structuredLogRemindersProvider),
        ),
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All caught up',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When you take part in structured club shoots without '
                      'linking a personal log, reminders will appear here.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(structuredLogRemindersProvider);
              await ref.read(structuredLogRemindersProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                StructuredLogRemindersSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
