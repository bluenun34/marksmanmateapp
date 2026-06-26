import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/sync/sync_status_provider.dart';
import '../../../shared/format/session_date_format.dart';
import '../../../shared/shoot_log/shoot_log_constants.dart';
import '../../../shared/shoot_log/shoot_log_labels.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../data/session_draft_repository.dart';
import '../providers/shoot_log_provider.dart';
import '../widgets/shoot_log_filter.dart';

class ShootLogListScreen extends ConsumerStatefulWidget {
  const ShootLogListScreen({super.key});

  @override
  ConsumerState<ShootLogListScreen> createState() =>
      _ShootLogListScreenState();
}

class _ShootLogListScreenState extends ConsumerState<ShootLogListScreen> {
  final _searchCtrl = TextEditingController();
  final _draftRepo = SessionDraftRepository();
  ShootLogFilter _filter = const ShootLogFilter();
  var _hasDraft = false;

  @override
  void initState() {
    super.initState();
    _checkDraft();
  }

  Future<void> _checkDraft() async {
    final hasDraft = await _draftRepo.hasDraft();
    if (mounted) setState(() => _hasDraft = hasDraft);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    final result = await ref.read(shootLogProvider.notifier).refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.ok
              ? result.sessionCount > 0
                  ? 'Loaded ${result.sessionCount} session${result.sessionCount == 1 ? '' : 's'}'
                  : 'Sync complete'
              : result.error ?? 'Sync failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(shootLogProvider);
    final notifier = ref.read(shootLogProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppScreenAppBar.main(
        context,
        title: 'Shoot Log',
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync shoot log',
            onPressed: _sync,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/shoot-log/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Session'),
      ),
      body: Column(
        children: [
          if (_hasDraft)
            MaterialBanner(
              content: const Text('You have an unfinished session draft.'),
              leading: const Icon(Icons.edit_note_outlined),
              actions: [
                TextButton(
                  onPressed: () => context.go('/shoot-log/new'),
                  child: const Text('Resume draft'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search sessions…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: _filter.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(
                            () => _filter = _filter.copyWith(query: ''),
                          );
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  setState(() => _filter = _filter.copyWith(query: v)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filter.discipline == null,
                  onSelected: (_) => setState(
                    () => _filter = _filter.copyWith(clearDiscipline: true),
                  ),
                ),
                for (final entry in ShootLogConstants.disciplines.entries)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(entry.value),
                      selected: _filter.discipline == entry.key,
                      onSelected: (_) => setState(
                        () => _filter = _filter.copyWith(discipline: entry.key),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: sessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorRetryView(
                message: 'Could not load your shoot log.',
                onRetry: _sync,
              ),
              data: (sessions) {
                final filtered = _filter.apply(sessions);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      sessions.isEmpty
                          ? 'No sessions logged yet'
                          : 'No sessions match your search',
                      style: theme.textTheme.titleMedium,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _sync,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount:
                        filtered.length + (notifier.hasMoreRemote ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      if (i == filtered.length) {
                        return TextButton.icon(
                          onPressed: notifier.isLoadingMore
                              ? null
                              : () => notifier.loadMoreFromApi(),
                          icon: notifier.isLoadingMore
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.expand_more),
                          label: Text(
                            notifier.isLoadingMore
                                ? 'Loading…'
                                : 'Load more sessions',
                          ),
                        );
                      }
                      final s = filtered[i];
                      return AppCard(
                        onTap: () => context.push(s.detailPath),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    disciplineLabel(s.discipline),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${sessionTypeLabel(s.sessionType)} • ${s.rangeName.isNotEmpty ? s.rangeName : 'No range name'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(formatSessionDateHuman(s.date)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (s.totalRounds != null)
                                  Text(
                                    '${s.totalRounds} rds',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                SyncBadge(status: s.syncStatus),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
