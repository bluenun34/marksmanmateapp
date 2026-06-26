import 'package:flutter/material.dart';

class OnboardingDialog extends StatelessWidget {
  const OnboardingDialog({super.key, required this.onComplete});

  final VoidCallback onComplete;

  static Future<void> showIfNeeded(
    BuildContext context, {
    required bool onboardingComplete,
    required VoidCallback onComplete,
  }) async {
    if (onboardingComplete || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OnboardingDialog(onComplete: onComplete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Welcome to MarksmanMate'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Step(
              icon: Icons.flash_on_rounded,
              title: 'Quick Log',
              body: 'Log rounds and hits fast at the range — even offline.',
            ),
            _Step(
              icon: Icons.track_changes,
              title: 'Full session wizard',
              body: 'Add location, gear, photos, and weather when you have time.',
            ),
            _Step(
              icon: Icons.sync_rounded,
              title: 'Syncs to your account',
              body: 'Sessions upload automatically when you are back online. Check the menu sync panel anytime.',
            ),
            _Step(
              icon: Icons.mic_none_rounded,
              title: 'Range tools',
              body: 'Shot timer and round counter can use your microphone — allow permission when prompted.',
            ),
            const SizedBox(height: 8),
            Text(
              'Manage firearms and full profile details on marksmanmate.com.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            onComplete();
            Navigator.of(context).pop();
          },
          child: const Text('Get started'),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
