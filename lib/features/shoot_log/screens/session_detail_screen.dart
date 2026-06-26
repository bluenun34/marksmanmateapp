import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../features/locker/providers/locker_provider.dart';
import '../../../shared/models/equipment_model.dart';
import '../../../shared/shoot_log/shoot_log_labels.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/shoot_log_provider.dart';
import '../services/session_export_service.dart';
import '../widgets/voice_note_recorder.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    required this.source,
  });

  final int sessionId;
  final SessionDetailSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (source == SessionDetailSource.local) {
      return _LocalSessionDetail(sessionId: sessionId);
    }
    return _RemoteSessionDetail(sessionId: sessionId);
  }
}

class _LocalSessionDetail extends ConsumerWidget {
  const _LocalSessionDetail({required this.sessionId});
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(appDatabaseProvider);

    return Scaffold(
      appBar: AppScreenAppBar.back(
        context,
        title: 'Session Detail',
        fallbackRoute: '/dashboard',
      ),
      body: StreamBuilder<List<ShootSession>>(
        stream: db.shootSessionDao.watchAllSessions(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final session =
              snap.data!.where((s) => s.id == sessionId).firstOrNull;
          if (session == null) {
            return ErrorRetryView(
              message: 'Session not found. It may still be saving.',
              onRetry: () => ref.read(shootLogProvider.notifier).reloadLocal(),
            );
          }

          return _SessionDetailBody(session: session);
        },
      ),
    );
  }
}

class _RemoteSessionDetail extends ConsumerStatefulWidget {
  const _RemoteSessionDetail({required this.sessionId});
  final int sessionId;

  @override
  ConsumerState<_RemoteSessionDetail> createState() =>
      _RemoteSessionDetailState();
}

class _RemoteSessionDetailState extends ConsumerState<_RemoteSessionDetail> {
  ShootSession? _session;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final localId = await ref
        .read(shootLogProvider.notifier)
        .ensureLocalCache(widget.sessionId);
    if (!mounted) return;
    if (localId == null) {
      setState(() {
        _loading = false;
        _error = 'Could not load this session from the server.';
      });
      return;
    }
    final session = await ref
        .read(appDatabaseProvider)
        .shootSessionDao
        .getByLocalId(localId);
    if (!mounted) return;
    setState(() {
      _session = session;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppScreenAppBar.back(
        context,
        title: 'Session Detail',
        fallbackRoute: '/dashboard',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _session == null
              ? ErrorRetryView(
                  message: _error ?? 'Session not found.',
                  onRetry: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _load();
                  },
                )
              : _SessionDetailBody(session: _session!),
    );
  }
}

class _SessionDetailBody extends ConsumerWidget {
  const _SessionDetailBody({required this.session});
  final ShootSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SessionContent(
      discipline: session.discipline,
      sessionType: session.sessionType,
      rangeName: session.rangeName,
      location: session.location,
      venueType: session.venueType,
      latitude: session.latitude,
      longitude: session.longitude,
      date: session.date,
      syncStatus: session.syncStatus,
      totalRounds: session.totalRounds,
      totalScore: session.totalScore,
      totalHits: session.totalHits,
      totalMisses: session.totalMisses,
      rating: session.rating,
      notes: session.notes,
      weatherCondition: session.weatherCondition,
      temperature: session.temperature,
      windSpeed: session.windSpeed,
      windDirection: session.windDirection,
      humidity: session.humidity,
      pressure: session.pressure,
      firearmId: session.firearmId,
      ammoLoadId: session.ammoLoadId,
      equipmentIds: decodeEquipmentIds(session.equipmentIds),
      localSession: session,
      voiceNotePath: session.voiceNotePath,
      onRetrySync: session.syncStatus == 'error' ||
              session.syncStatus == 'pending'
          ? () async {
              final message = await ref
                  .read(shootLogProvider.notifier)
                  .retrySessionSync(session.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message ?? 'Session synced'),
                ),
              );
            }
          : null,
    );
  }
}

class _SessionContent extends ConsumerWidget {
  const _SessionContent({
    required this.discipline,
    required this.sessionType,
    required this.rangeName,
    required this.location,
    required this.venueType,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.syncStatus,
    required this.totalRounds,
    required this.totalScore,
    required this.totalHits,
    required this.totalMisses,
    required this.rating,
    required this.notes,
    required this.weatherCondition,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.pressure,
    this.firearmId,
    this.ammoLoadId,
    this.equipmentIds = const [],
    this.localSession,
    this.voiceNotePath,
    this.onRetrySync,
  });

  final String discipline;
  final String sessionType;
  final String? rangeName;
  final String? location;
  final String? venueType;
  final double? latitude;
  final double? longitude;
  final DateTime date;
  final String syncStatus;
  final int? totalRounds;
  final double? totalScore;
  final int? totalHits;
  final int? totalMisses;
  final int? rating;
  final String? notes;
  final String? weatherCondition;
  final double? temperature;
  final double? windSpeed;
  final String? windDirection;
  final double? humidity;
  final double? pressure;
  final int? firearmId;
  final int? ammoLoadId;
  final List<int> equipmentIds;
  final ShootSession? localSession;
  final String? voiceNotePath;
  final Future<void> Function()? onRetrySync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locker = ref.watch(lockerProvider);
    final firearm = firearmId == null
        ? null
        : locker.firearms.where((f) => f.id == firearmId).firstOrNull;
    final ammo = ammoLoadId == null
        ? null
        : locker.ammoLoads.where((a) => a.id == ammoLoadId).firstOrNull;
    final equipment = <EquipmentModel>[];
    for (final id in equipmentIds) {
      final item =
          locker.equipment.where((e) => e.id == id).firstOrNull;
      if (item != null) equipment.add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (localSession != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/shoot-log/${localSession!.id}/edit'),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final newId = await ref
                      .read(shootLogProvider.notifier)
                      .duplicateSession(localSession!.id);
                  if (!context.mounted || newId == null) return;
                  await ref.read(shootLogProvider.notifier).reloadLocal();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session duplicated')),
                  );
                  context.push('/shoot-log/$newId?source=local');
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Duplicate'),
              ),
              OutlinedButton.icon(
                onPressed: () => SessionExportService.share(localSession!),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share'),
              ),
              if (localSession!.syncStatus == 'pending' ||
                  localSession!.syncStatus == 'error')
                FilledButton.icon(
                  onPressed: () async {
                    final message = await ref
                        .read(shootLogProvider.notifier)
                        .retrySessionSync(localSession!.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message ?? 'Session synced')),
                    );
                  },
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Sync now'),
                ),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete session?'),
                      content: const Text(
                        'This removes the session from your device and account.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;
                  final error =
                      await ref.read(shootLogProvider.notifier).deleteSession(
                            localId: localSession!.id,
                            serverId: localSession!.serverId,
                          );
                  if (!context.mounted) return;
                  if (error != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }
                  context.go('/shoot-log');
                },
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (syncStatus == 'conflict' && localSession != null) ...[
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sync conflict',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This session was changed on your device and on the website. Choose which version to keep.',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () async {
                          final message = await ref
                              .read(shootLogProvider.notifier)
                              .resolveConflictKeepLocal(localSession!.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                message ?? 'Your changes were uploaded',
                              ),
                            ),
                          );
                        },
                        child: const Text('Keep mine'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final message = await ref
                              .read(shootLogProvider.notifier)
                              .resolveConflictUseServer(localSession!.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                message ?? 'Website version applied',
                              ),
                            ),
                          );
                        },
                        child: const Text('Use website version'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if ((syncStatus == 'error' || syncStatus == 'pending') &&
            onRetrySync != null) ...[
          Card(
            color: syncStatus == 'error'
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.tertiaryContainer,
            child: ListTile(
              leading: Icon(
                syncStatus == 'error'
                    ? Icons.cloud_off_rounded
                    : Icons.cloud_upload_outlined,
                color: syncStatus == 'error'
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onTertiaryContainer,
              ),
              title: Text(
                syncStatus == 'error' ? 'Sync failed' : 'Waiting to sync',
                style: TextStyle(
                  color: syncStatus == 'error'
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onTertiaryContainer,
                ),
              ),
              subtitle: Text(
                syncStatus == 'error'
                    ? 'This session is saved locally but has not reached the server.'
                    : 'Saved offline — tap to upload when you are online.',
                style: TextStyle(
                  color: syncStatus == 'error'
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onTertiaryContainer,
                ),
              ),
              trailing: FilledButton(
                onPressed: onRetrySync,
                child: const Text('Sync now'),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      disciplineLabel(discipline),
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SyncBadge(status: syncStatus),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${sessionTypeLabel(sessionType)} • ${rangeName?.isNotEmpty == true ? rangeName : 'No range name'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (venueType != null) ...[
                const SizedBox(height: 4),
                Text(
                  venueTypeLabel(venueType),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (location?.isNotEmpty == true ||
            latitude != null ||
            longitude != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (location?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(location!),
                ],
                if (latitude != null && longitude != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (firearm != null || ammo != null || equipment.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gear used',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (firearm != null) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.settings_outlined, firearm.name),
                ],
                if (ammo != null)
                  _detailRow(Icons.linear_scale_rounded, ammo.name),
                ...equipment.map(
                  (item) => _detailRow(Icons.build_outlined, item.name),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: StatCard(
              label: 'Rounds',
              value: '${totalRounds ?? '—'}',
              icon: Icons.my_location_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Score',
              value: '${totalScore ?? '—'}',
              icon: Icons.emoji_events_outlined,
              accent: ColorTokens.accentBrass,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: StatCard(
              label: 'Hits',
              value: '${totalHits ?? '—'}',
              icon: Icons.check_circle_outline_rounded,
              accent: ColorTokens.accentGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Misses',
              value: '${totalMisses ?? '—'}',
              icon: Icons.cancel_outlined,
              accent: ColorTokens.danger,
            ),
          ),
        ]),
        if (rating != null && rating! > 0) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                const Text('Rating'),
                const Spacer(),
                ...List.generate(
                  5,
                  (i) => Icon(
                    rating! > i
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (voiceNotePath != null && voiceNotePath!.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: VoiceNotePlayer(filePath: voiceNotePath!),
          ),
        ],
        if (notes?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(notes!),
              ],
            ),
          ),
        ],
        if (weatherCondition != null ||
            temperature != null ||
            windSpeed != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                if (weatherCondition != null)
                  _weatherRow(Icons.wb_sunny_outlined, weatherCondition!),
                if (temperature != null)
                  _weatherRow(Icons.thermostat_outlined, '${temperature}°C'),
                if (windSpeed != null)
                  _weatherRow(
                    Icons.air_outlined,
                    '${windSpeed} km/h ${windDirection ?? ''}'.trim(),
                  ),
                if (humidity != null)
                  _weatherRow(Icons.water_drop_outlined, '${humidity!.round()}%'),
                if (pressure != null)
                  _weatherRow(Icons.speed_outlined, '${pressure} hPa'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _detailRow(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
          ],
        ),
      );

  Widget _weatherRow(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      );

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
