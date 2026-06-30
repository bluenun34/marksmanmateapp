import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/clubs_provider.dart';

class ClubLeagueScreen extends ConsumerStatefulWidget {
  const ClubLeagueScreen({
    super.key,
    required this.clubSlug,
    required this.leagueId,
  });

  final String clubSlug;
  final int leagueId;

  @override
  ConsumerState<ClubLeagueScreen> createState() => _ClubLeagueScreenState();
}

class _ClubLeagueScreenState extends ConsumerState<ClubLeagueScreen> {
  int? _selectedSeasonId;
  String? _selectedDivision;

  ({String clubSlug, int leagueId, int? season, String? division}) _params() {
    return (
      clubSlug: widget.clubSlug,
      leagueId: widget.leagueId,
      season: _selectedSeasonId,
      division: _selectedDivision,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final params = _params();
    final standingsAsync = ref.watch(clubLeagueStandingsProvider(params));

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'League standings'),
      body: standingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load standings.',
          onRetry: () => ref.invalidate(clubLeagueStandingsProvider(params)),
        ),
        data: (standings) {
          if (_selectedSeasonId == null && standings.seasonId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedSeasonId = standings.seasonId;
                  _selectedDivision = standings.division;
                });
              }
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      standings.leagueName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (standings.disciplineName != null)
                      Text(
                        standings.disciplineName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (standings.seasons.length > 1) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Season',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: standings.seasons.map((season) {
                          final activeSeasonId =
                              _selectedSeasonId ?? standings.seasonId;
                          final selected = season.id == activeSeasonId;
                          return ChoiceChip(
                            label: Text(season.name),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedSeasonId = season.id;
                                _selectedDivision = null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (standings.seasonName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          standings.seasonName!,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                    if (standings.divisionOptions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        initialValue: standings.division,
                        decoration: const InputDecoration(
                          labelText: 'Division',
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All divisions'),
                          ),
                          ...standings.divisionOptions.map(
                            (division) => DropdownMenuItem<String?>(
                              value: division,
                              child: Text(division),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedDivision = value);
                        },
                      ),
                    ],
                    if (standings.bestN != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Best ${standings.bestN} rounds',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: standings.standings.isEmpty
                    ? Center(
                        child: Text(
                          'No standings yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: standings.standings.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final row = standings.standings[index];
                          final place = index + 1;
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('$place'),
                            ),
                            title: Text(row.userName),
                            subtitle: row.eventsEntered != null
                                ? Text('${row.eventsEntered} events')
                                : null,
                            trailing: Text(
                              row.countedScore?.toStringAsFixed(1) ??
                                  row.totalScore?.toStringAsFixed(1) ??
                                  '—',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
