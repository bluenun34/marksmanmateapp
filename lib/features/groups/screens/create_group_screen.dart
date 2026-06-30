import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  bool _canCreate(WidgetRef ref) {
    final plan = ref.read(authStateProvider).user?.plan;
    return plan == 'pro_user';
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _busy = true);
    try {
      final group = await ref.read(apiServiceProvider).createGroup(
            name: name,
            description: _descriptionCtrl.text,
          );
      ref.invalidate(myGroupsProvider);
      if (!mounted) return;
      context.go('/groups/${group.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create group: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCreate = _canCreate(ref);

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Create group'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!canCreate)
            Material(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pro required',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Creating private groups requires a Pro subscription.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => launchUrl(
                        Uri.parse('${AppConfig.websiteBaseUrl}/billing'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: const Text('View plans'),
                    ),
                  ],
                ),
              ),
            ),
          if (!canCreate) const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            enabled: canCreate && !_busy,
            decoration: const InputDecoration(
              labelText: 'Group name',
              hintText: 'e.g. Saturday Gallery Squad',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionCtrl,
            enabled: canCreate && !_busy,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'What is this group for?',
            ),
            maxLines: 4,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => canCreate && !_busy ? _submit() : null,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: canCreate && !_busy ? _submit : null,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create group'),
          ),
        ],
      ),
    );
  }
}
