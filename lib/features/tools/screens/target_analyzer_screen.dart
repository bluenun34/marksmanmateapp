import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/paper_target_catalog.dart';
import '../data/paper_target_library_service.dart';
import '../models/paper_target_type.dart';
import '../models/target_hit_models.dart';
import '../services/group_size_calculator.dart';
import '../services/target_analyzer_handoff.dart';
import '../services/target_annotated_image.dart';
import '../widgets/target_catalog_sheet.dart';
import '../widgets/target_measurement_guide.dart';
import '../widgets/target_overlay_canvas.dart';
import '../widgets/target_type_preview.dart';

enum _AnalyzerStep { capture, targetSize, markHits, results }

enum _TargetSource { catalog, custom }

class TargetAnalyzerScreen extends ConsumerStatefulWidget {
  const TargetAnalyzerScreen({super.key});

  @override
  ConsumerState<TargetAnalyzerScreen> createState() =>
      _TargetAnalyzerScreenState();
}

class _TargetAnalyzerScreenState extends ConsumerState<TargetAnalyzerScreen> {
  _AnalyzerStep _step = _AnalyzerStep.capture;
  _TargetSource _targetSource = _TargetSource.catalog;

  Uint8List? _imageBytes;

  final _customNameCtrl = TextEditingController(text: 'My target');
  final _diameterCtrl = TextEditingController(text: '100');
  String _diameterUnit = 'mm';
  PaperTargetCategory _customCategory = PaperTargetCategory.other;

  PaperTargetType _selectedTarget = defaultPaperTarget;
  List<PaperTargetType> _savedTargets = const [];

  PaperTargetLibraryService get _targetLibrary =>
      ref.read(paperTargetLibraryProvider);

  final _markedHits = <MarkedHit>[];
  final _groups = <TargetHitGroup>[
    TargetHitGroup.named(0),
    TargetHitGroup.named(1),
  ];
  var _activeGroupId = 0;
  List<TargetGroupAnalysis>? _groupResults;
  GroupSizeResult? _primaryResult;
  var _savingLog = false;

  @override
  void initState() {
    super.initState();
    _loadSavedTargets();
  }

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _diameterCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedTargets() async {
    final saved = await _targetLibrary.loadAll();
    if (!mounted) return;
    setState(() => _savedTargets = saved);
  }

  String get _targetLabel {
    if (_targetSource == _TargetSource.catalog) return _selectedTarget.name;
    final name = _customNameCtrl.text.trim();
    return name.isEmpty ? 'Custom target' : name;
  }

  double get _diameterMm {
    if (_targetSource == _TargetSource.catalog) {
      return _selectedTarget.faceDiameterMm;
    }
    final value = double.tryParse(_diameterCtrl.text.trim());
    if (value == null || value <= 0) return 0;
    return GroupSizeCalculator.diameterToMm(value, _diameterUnit);
  }

  double? _pixelsPerMm(Uint8List bytes) {
    if (_diameterMm <= 0) return null;
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final refPx = math.min(decoded.width, decoded.height) * 0.75;
    return refPx / _diameterMm;
  }

  void _applyCapturedImage(Uint8List bytes) {
    setState(() {
      _imageBytes = bytes;
      _markedHits.clear();
      _groupResults = null;
      _primaryResult = null;
      _step = _AnalyzerStep.targetSize;
    });
  }

  Future<void> _pickTargetFromCatalog() async {
    final picked = await showTargetCatalogSheet(
      context,
      selected: _selectedTarget,
      savedTargets: _savedTargets,
      library: _targetLibrary,
    );
    if (picked == null || !mounted) return;
    await _loadSavedTargets();
    setState(() {
      _selectedTarget = picked;
      _targetSource = _TargetSource.catalog;
    });
  }

  Future<void> _saveCustomTarget() async {
    if (_diameterMm <= 0) {
      _showMessage('Enter a valid target diameter.');
      return;
    }
    final name = _customNameCtrl.text.trim();
    if (name.isEmpty) {
      _showMessage('Enter a name for your target.');
      return;
    }
    final target = PaperTargetType(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _customCategory,
      faceDiameterMm: _diameterMm,
      description: 'Saved custom target',
      isUserSaved: true,
    );
    final saved = await _targetLibrary.save(target);
    await _loadSavedTargets();
    if (!mounted) return;
    setState(() {
      _selectedTarget = saved;
      _targetSource = _TargetSource.catalog;
    });
    final synced = ref.read(authStateProvider).isAuthenticated;
    _showMessage(
      synced
          ? 'Saved "$name" to My targets and your MarksmanMate account'
          : 'Saved "$name" to My targets (sign in to sync to your account)',
    );
  }

  Future<void> _copyTargetShareCode() async {
    final target = _targetSource == _TargetSource.catalog
        ? _selectedTarget
        : PaperTargetType(
            id: 'share-draft',
            name: _targetLabel,
            category: _customCategory,
            faceDiameterMm: _diameterMm,
            description: 'Shared custom target',
            isUserSaved: true,
          );
    if (target.faceDiameterMm <= 0) {
      _showMessage('Enter a valid target diameter first.');
      return;
    }
    await Clipboard.setData(
      ClipboardData(text: _targetLibrary.shareCodeFor(target)),
    );
    _showMessage('Share code copied — others can import from the catalog sheet');
  }

  void _goToMarkHits() {
    if (_diameterMm <= 0) {
      _showMessage('Choose a target or enter a valid face diameter.');
      return;
    }
    setState(() => _step = _AnalyzerStep.markHits);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 2400,
      imageQuality: 92,
    );
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    _applyCapturedImage(bytes);
  }

  void _onHitTap(Offset point) {
    setState(() {
      _markedHits.add(MarkedHit(position: point, groupId: _activeGroupId));
    });
  }

  void _onRemoveHit(int index) {
    setState(() => _markedHits.removeAt(index));
  }

  void _selectGroup(int groupId) {
    setState(() => _activeGroupId = groupId);
  }

  void _addGroup() {
    if (_groups.length >= TargetHitGroup.defaultPalette.length) return;
    setState(() {
      final id = _groups.length;
      _groups.add(TargetHitGroup.named(id));
      _activeGroupId = id;
    });
  }

  int _hitsInGroup(int groupId) =>
      _markedHits.where((h) => h.groupId == groupId).length;

  bool get _canCalculate =>
      _groups.any((g) => _hitsInGroup(g.id) >= 2);

  void _computeResults() {
    final bytes = _imageBytes;
    if (bytes == null) return;
    final pxPerMm = _pixelsPerMm(bytes);
    if (pxPerMm == null || pxPerMm <= 0) {
      _showMessage('Could not read photo — try another image.');
      return;
    }
    if (_diameterMm <= 0) {
      _showMessage('Enter a valid target diameter.');
      return;
    }
    if (!_canCalculate) {
      _showMessage('Mark at least two hits in one group.');
      return;
    }

    final analyses = <TargetGroupAnalysis>[];
    for (final group in _groups) {
      final hits = _markedHits
          .where((h) => h.groupId == group.id)
          .map((h) => h.position)
          .toList();
      if (hits.length < 2) continue;
      analyses.add(
        TargetGroupAnalysis(
          group: group,
          result: GroupSizeCalculator.compute(
            hits: hits,
            pixelsPerMm: pxPerMm,
          ),
        ),
      );
    }

    setState(() {
      _groupResults = analyses;
      _primaryResult = analyses.isNotEmpty ? analyses.first.result : null;
      _step = _AnalyzerStep.results;
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _reset() {
    setState(() {
      _step = _AnalyzerStep.capture;
      _imageBytes = null;
      _targetSource = _TargetSource.catalog;
      _selectedTarget = defaultPaperTarget;
      _markedHits.clear();
      _groupResults = null;
      _primaryResult = null;
      _groups
        ..clear()
        ..addAll([TargetHitGroup.named(0), TargetHitGroup.named(1)]);
      _activeGroupId = 0;
    });
  }

  String _logQueryParams({required bool quick}) {
    final result = _primaryResult;
    final params = <String, String>{
      if (result != null) 'group_size': result.extremeSpreadMm.toStringAsFixed(1),
      if (result != null) 'group_size_unit': 'mm',
      'hits': _markedHits.length.toString(),
      'target_type': _targetLabel,
    };
    if (quick) {
      params['rounds'] = _markedHits.length.toString();
    }
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _createSessionLog() async {
    if (_primaryResult == null || _imageBytes == null || _savingLog) return;
    setState(() => _savingLog = true);
    try {
      final draft = await TargetAnnotatedImage.render(
        imageBytes: _imageBytes!,
        markedHits: _markedHits,
        groups: _groups,
        extremePairsByGroup: _extremePairsByGroup(),
      );
      if (!mounted) return;
      if (draft == null) {
        _showMessage('Could not prepare target photo for the log.');
        return;
      }
      TargetAnalyzerHandoff.setTargetPhoto(draft);
      context.go('/shoot-log/new?${_logQueryParams(quick: false)}');
    } finally {
      if (mounted) setState(() => _savingLog = false);
    }
  }

  void _quickLog() {
    if (_primaryResult == null) return;
    context.go('/shoot-log/quick?${_logQueryParams(quick: true)}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Target group analyzer'),
      body: Column(
        children: [
          _StepHeader(step: _step),
          Expanded(child: _buildStepBody(theme)),
          _buildBottomBar(theme),
        ],
      ),
    );
  }

  Widget _buildStepBody(ThemeData theme) {
    return switch (_step) {
      _AnalyzerStep.capture => _buildCaptureStep(theme),
      _AnalyzerStep.targetSize => _buildTargetSizeStep(theme),
      _AnalyzerStep.markHits => _buildMarkHitsStep(theme),
      _AnalyzerStep.results => _buildResultsStep(theme),
    };
  }

  Widget _buildCaptureStep(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Add a photo of your target, then state the target size and mark your hits.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Take picture'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose from gallery'),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSizeStep(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'State the scoring-face size of your target. Save custom sizes to reuse '
          'or share with others.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<_TargetSource>(
          segments: const [
            ButtonSegment(
              value: _TargetSource.catalog,
              label: Text('Catalog / saved'),
              icon: Icon(Icons.list_alt_outlined, size: 18),
            ),
            ButtonSegment(
              value: _TargetSource.custom,
              label: Text('Custom size'),
              icon: Icon(Icons.edit_outlined, size: 18),
            ),
          ],
          selected: {_targetSource},
          onSelectionChanged: (s) => setState(() => _targetSource = s.first),
        ),
        const SizedBox(height: 16),
        if (_targetSource == _TargetSource.catalog)
          Card(
            child: InkWell(
              onTap: _pickTargetFromCatalog,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TargetTypePreview(target: _selectedTarget, size: 88),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTarget.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTarget.sizeLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTarget.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.unfold_more),
                  ],
                ),
              ),
            ),
          )
        else ...[
          const TargetMeasurementGuide(),
          const SizedBox(height: 16),
          TextField(
            controller: _customNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Target name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _diameterCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Face diameter',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _diameterUnit,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mm', child: Text('mm')),
                    DropdownMenuItem(value: 'inches', child: Text('inches')),
                  ],
                  onChanged: (v) => setState(() => _diameterUnit = v ?? 'mm'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PaperTargetCategory>(
            initialValue: _customCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final cat in PaperTargetCategory.values)
                DropdownMenuItem(value: cat, child: Text(cat.label)),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _customCategory = v);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveCustomTarget,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save to My targets'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copy share code',
                onPressed: _copyTargetShareCode,
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
        ],
        if (_targetSource == _TargetSource.catalog) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _pickTargetFromCatalog,
              icon: const Icon(Icons.search),
              label: Text(
                'Browse catalog & saved (${paperTargetCatalog.length + _savedTargets.length})',
              ),
            ),
          ),
        ],
        if (_imageBytes != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.memory(_imageBytes!, fit: BoxFit.cover),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMarkHitsStep(ThemeData theme) {
    final bytes = _imageBytes!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Pinch to zoom, tap each hole. Tap a marker again to remove it. '
            'Use groups for separate strings.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$_targetLabel · ${_diameterMm.toStringAsFixed(_diameterMm % 1 == 0 ? 0 : 1)} mm',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final group in _groups)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: group.id == _activeGroupId,
                      avatar: CircleAvatar(
                        radius: 8,
                        backgroundColor: group.color,
                      ),
                      label: Text('${group.name} (${_hitsInGroup(group.id)})'),
                      onSelected: (_) => _selectGroup(group.id),
                    ),
                  ),
                if (_groups.length < TargetHitGroup.defaultPalette.length)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('Group'),
                    onPressed: _addGroup,
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TargetOverlayView(
                imageBytes: bytes,
                markedHits: _markedHits,
                groups: _groups,
                activeGroupId: _activeGroupId,
                enableZoom: true,
                onTapImage: _onHitTap,
                onRemoveHit: _onRemoveHit,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_markedHits.length} hits · '
              '${_groups.where((g) => _hitsInGroup(g.id) > 0).length} groups',
              style: theme.textTheme.titleSmall,
            ),
          ),
        ),
      ],
    );
  }

  Map<int, (Offset, Offset)> _extremePairsByGroup() {
    final map = <int, (Offset, Offset)>{};
    for (final analysis in _groupResults ?? const <TargetGroupAnalysis>[]) {
      final pair = analysis.result.extremePair;
      if (pair != null) map[analysis.group.id] = pair;
    }
    return map;
  }

  Widget _buildResultsStep(ThemeData theme) {
    final bytes = _imageBytes!;
    final analyses = _groupResults ?? const <TargetGroupAnalysis>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 260,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TargetOverlayView(
              imageBytes: bytes,
              markedHits: _markedHits,
              groups: _groups,
              extremePairsByGroup: _extremePairsByGroup(),
              mode: TargetOverlayMode.results,
              readOnly: true,
              enableZoom: true,
              onTapImage: (_) {},
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final analysis in analyses) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: analysis.group.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        analysis.group.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${analysis.result.extremeSpreadMm.toStringAsFixed(1)} mm  ·  '
                    '${analysis.result.extremeSpreadInches.toStringAsFixed(3)} in',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: analysis.group.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${analysis.result.hitCount} hits · '
                    'mean radius ${analysis.result.meanRadiusMm.toStringAsFixed(1)} mm',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Target: $_targetLabel · '
          '${_diameterMm.toStringAsFixed(_diameterMm % 1 == 0 ? 0 : 1)} mm · '
          '${_markedHits.length} total hits',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Creating a session log attaches this photo with your hit markers as '
          'the target image.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Group size is approximate — based on your stated target size and a '
          'face-on photo.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: (_primaryResult == null || _savingLog)
                ? null
                : _createSessionLog,
            icon: _savingLog
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.note_add_outlined),
            label: Text(_savingLog ? 'Preparing photo…' : 'Create session log'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _primaryResult == null ? null : _quickLog,
            icon: const Icon(Icons.bolt_outlined),
            label: const Text('Quick log at range'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _step = _AnalyzerStep.markHits),
            child: const Text('Adjust hits'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (_step != _AnalyzerStep.capture)
              TextButton(
                onPressed: () {
                  if (_step == _AnalyzerStep.targetSize) {
                    _reset();
                  } else {
                    setState(() {
                      _step = switch (_step) {
                        _AnalyzerStep.markHits => _AnalyzerStep.targetSize,
                        _AnalyzerStep.results => _AnalyzerStep.markHits,
                        _ => _AnalyzerStep.capture,
                      };
                    });
                  }
                },
                child: const Text('Back'),
              ),
            const Spacer(),
            if (_step == _AnalyzerStep.targetSize)
              FilledButton(
                onPressed: _goToMarkHits,
                child: const Text('Mark hits'),
              ),
            if (_step == _AnalyzerStep.markHits)
              FilledButton(
                onPressed: _canCalculate ? _computeResults : null,
                child: const Text('See results'),
              ),
            if (_step == _AnalyzerStep.results)
              TextButton(onPressed: _reset, child: const Text('New target')),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final _AnalyzerStep step;

  @override
  Widget build(BuildContext context) {
    final label = switch (step) {
      _AnalyzerStep.capture => '1. Photo',
      _AnalyzerStep.targetSize => '2. Target size',
      _AnalyzerStep.markHits => '3. Mark hits',
      _AnalyzerStep.results => '4. Results',
    };
    final index = step.index;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
