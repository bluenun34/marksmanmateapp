import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_screen_app_bar.dart';
import '../models/calculator_definitions.dart';
import '../services/ballistics_math.dart';

class BallisticsCalculatorScreen extends StatefulWidget {
  const BallisticsCalculatorScreen({super.key, required this.calculatorId});

  final String calculatorId;

  @override
  State<BallisticsCalculatorScreen> createState() =>
      _BallisticsCalculatorScreenState();
}

class _BallisticsCalculatorScreenState extends State<BallisticsCalculatorScreen> {
  final _controllers = <String, TextEditingController>{};
  final _selects = <String, String>{};

  CalculatorDefinition? get _def {
    for (final calc in ballisticsCalculators) {
      if (calc.id.name == widget.calculatorId) return calc;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    final id = _parseId();
    switch (id) {
      case BallisticsCalculatorId.moaMilConverter:
        _field('moa');
        _field('mil');
      case BallisticsCalculatorId.yardsMetresConverter:
        _field('yards');
        _field('metres');
      case BallisticsCalculatorId.groupSizeMoa:
        _field('group', text: '25');
        _select('groupUnit', 'mm', ['mm', 'in']);
        _field('distance', text: '100');
        _select('distanceUnit', 'm', ['m', 'yd']);
      case BallisticsCalculatorId.angleSize:
        _field('size', text: '10');
        _select('sizeUnit', 'cm', ['cm', 'in']);
        _field('distance', text: '100');
        _select('distanceUnit', 'm', ['m', 'yd']);
      case BallisticsCalculatorId.clickValue:
        _field('distance', text: '100');
        _select('distanceUnit', 'yd', ['yd', 'm']);
        _select('scopeUnit', 'moa', ['moa', 'mil']);
        _field('click', text: '0.25');
      case BallisticsCalculatorId.correctionClicks:
        _field('offset', text: '2');
        _select('offsetUnit', 'in', ['in', 'cm']);
        _field('distance', text: '100');
        _select('distanceUnit', 'yd', ['yd', 'm']);
        _select('scopeUnit', 'moa', ['moa', 'mil']);
        _field('click', text: '0.25');
      case BallisticsCalculatorId.energy:
        _field('grains', text: '55');
        _field('velocity', text: '3200');
        _select('velocityUnit', 'fps', ['fps', 'mps']);
      case BallisticsCalculatorId.zeroOffset:
        _field('oldZero', text: '100');
        _field('newZero', text: '200');
        _field('dropPer100', text: '3.5');
      case BallisticsCalculatorId.dropComeUp:
        _field('zero', text: '100');
        _field('drop100', text: '3');
        _field('start', text: '100');
        _field('end', text: '500');
        _field('step', text: '50');
      case BallisticsCalculatorId.windDrift:
        _field('wind', text: '10');
        _field('angle', text: '90');
        _field('distance', text: '300');
        _field('factor', text: '1.5');
      case BallisticsCalculatorId.shotTimerSplits:
        _field('splits', text: '1.2, 0.95, 1.05');
      case BallisticsCalculatorId.powerFactor:
        _field('grains', text: '124');
        _field('velocity', text: '1050');
        _select('velocityUnit', 'fps', ['fps', 'mps']);
      case BallisticsCalculatorId.recoilEnergy:
        _field('gun', text: '8');
        _field('bullet', text: '168');
        _field('powder', text: '44');
        _field('velocity', text: '2650');
      case BallisticsCalculatorId.roundCountCost:
        _field('boxPrice', text: '30');
        _field('roundsPerBox', text: '50');
        _field('roundsSession', text: '120');
        _field('sessionsWeek', text: '1.5');
      case BallisticsCalculatorId.scopeRingHeight:
        _field('objective', text: '50');
        _field('barrel', text: '22');
        _field('clearance', text: '2');
      case BallisticsCalculatorId.unitConverterPack:
        _field('value', text: '100');
        _select('fromUnit', 'yd', ['yd', 'm', 'in', 'mm', 'gr', 'g', 'fps', 'mps']);
      case BallisticsCalculatorId.dopeCardBuilder:
        _field('zero', text: '100');
        _field('drop100', text: '3');
        _field('start', text: '100');
        _field('end', text: '600');
        _field('step', text: '50');
      case null:
        break;
    }
  }

  BallisticsCalculatorId? _parseId() {
    for (final calc in ballisticsCalculators) {
      if (calc.id.name == widget.calculatorId) return calc.id;
    }
    return null;
  }

  TextEditingController _field(String key, {String? text}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: text),
    );
  }

  void _select(String key, String initial, List<String> options) {
    _selects[key] = initial;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(String key) => double.tryParse(_controllers[key]?.text ?? '');

  int? _int(String key) => int.tryParse(_controllers[key]?.text ?? '');

  void _recalc() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final def = _def;
    if (def == null) {
      return Scaffold(
        appBar: AppScreenAppBar.back(context, title: 'Calculator'),
        body: const Center(child: Text('Unknown calculator.')),
      );
    }

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: def.title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            def.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ..._buildInputs(def.id),
          const SizedBox(height: 16),
          ..._buildResults(def.id),
        ],
      ),
    );
  }

  List<Widget> _buildInputs(BallisticsCalculatorId id) {
    Widget numField(String key, String label) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _controllers[key],
            decoration: InputDecoration(labelText: label),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _recalc(),
          ),
        );

    Widget dropdown(String key, String label, Map<String, String> options) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            initialValue: _selects[key],
            decoration: InputDecoration(labelText: label),
            items: options.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selects[key] = v);
                _recalc();
              }
            },
          ),
        );

    switch (id) {
      case BallisticsCalculatorId.moaMilConverter:
        return [
          numField('moa', 'MOA'),
          numField('mil', 'MIL'),
        ];
      case BallisticsCalculatorId.yardsMetresConverter:
        return [
          numField('yards', 'Yards'),
          numField('metres', 'Metres'),
        ];
      case BallisticsCalculatorId.groupSizeMoa:
        return [
          numField('group', 'Group size'),
          dropdown('groupUnit', 'Group unit', {'mm': 'mm', 'in': 'inches'}),
          numField('distance', 'Distance'),
          dropdown('distanceUnit', 'Distance unit', {'m': 'metres', 'yd': 'yards'}),
        ];
      case BallisticsCalculatorId.angleSize:
        return [
          numField('size', 'Target size'),
          dropdown('sizeUnit', 'Size unit', {'cm': 'cm', 'in': 'inches'}),
          numField('distance', 'Distance'),
          dropdown('distanceUnit', 'Distance unit', {'m': 'metres', 'yd': 'yards'}),
        ];
      case BallisticsCalculatorId.clickValue:
        return [
          numField('distance', 'Distance'),
          dropdown('distanceUnit', 'Distance unit', {'yd': 'yards', 'm': 'metres'}),
          dropdown('scopeUnit', 'Scope unit', {'moa': 'MOA', 'mil': 'MIL'}),
          numField('click', 'Click value'),
        ];
      case BallisticsCalculatorId.correctionClicks:
        return [
          numField('offset', 'Offset'),
          dropdown('offsetUnit', 'Offset unit', {'in': 'inches', 'cm': 'cm'}),
          numField('distance', 'Distance'),
          dropdown('distanceUnit', 'Distance unit', {'yd': 'yards', 'm': 'metres'}),
          dropdown('scopeUnit', 'Scope unit', {'moa': 'MOA', 'mil': 'MIL'}),
          numField('click', 'Click value'),
        ];
      case BallisticsCalculatorId.energy:
        return [
          numField('grains', 'Bullet weight (grains)'),
          numField('velocity', 'Velocity'),
          dropdown('velocityUnit', 'Velocity unit', {
            'fps': 'ft/s',
            'mps': 'm/s',
          }),
        ];
      case BallisticsCalculatorId.zeroOffset:
        return [
          numField('oldZero', 'Current zero (yards)'),
          numField('newZero', 'New zero (yards)'),
          numField('dropPer100', 'Drop rate (in per 100 yd)'),
        ];
      case BallisticsCalculatorId.dropComeUp:
        return [
          numField('zero', 'Zero distance (yd)'),
          numField('drop100', 'Drop at 100y beyond zero (in)'),
          numField('start', 'Start distance (yd)'),
          numField('end', 'End distance (yd)'),
          numField('step', 'Step (yd)'),
        ];
      case BallisticsCalculatorId.windDrift:
        return [
          numField('wind', 'Wind speed (mph)'),
          numField('angle', 'Wind angle (°)'),
          numField('distance', 'Distance (yards)'),
          numField('factor', 'Drift factor'),
        ];
      case BallisticsCalculatorId.shotTimerSplits:
        return [
          TextField(
            controller: _controllers['splits'],
            decoration: const InputDecoration(
              labelText: 'Split times (seconds, comma-separated)',
            ),
            onChanged: (_) => _recalc(),
          ),
        ];
      case BallisticsCalculatorId.powerFactor:
        return [
          numField('grains', 'Bullet weight (grains)'),
          numField('velocity', 'Velocity'),
          dropdown('velocityUnit', 'Velocity unit', {
            'fps': 'ft/s',
            'mps': 'm/s',
          }),
        ];
      case BallisticsCalculatorId.recoilEnergy:
        return [
          numField('gun', 'Gun weight (lb)'),
          numField('bullet', 'Bullet (grains)'),
          numField('powder', 'Powder charge (grains)'),
          numField('velocity', 'Muzzle velocity (ft/s)'),
        ];
      case BallisticsCalculatorId.roundCountCost:
        return [
          numField('boxPrice', 'Box price (£)'),
          numField('roundsPerBox', 'Rounds per box'),
          numField('roundsSession', 'Rounds per session'),
          numField('sessionsWeek', 'Sessions per week'),
        ];
      case BallisticsCalculatorId.scopeRingHeight:
        return [
          numField('objective', 'Objective diameter (mm)'),
          numField('barrel', 'Barrel diameter (mm)'),
          numField('clearance', 'Clearance (mm)'),
        ];
      case BallisticsCalculatorId.unitConverterPack:
        return [
          numField('value', 'Value'),
          dropdown('fromUnit', 'From unit', {
            'yd': 'yards',
            'm': 'metres',
            'in': 'inches',
            'mm': 'mm',
            'gr': 'grains',
            'g': 'grams',
            'fps': 'ft/s',
            'mps': 'm/s',
          }),
        ];
      case BallisticsCalculatorId.dopeCardBuilder:
        return [
          numField('zero', 'Zero distance (yd)'),
          numField('drop100', 'Drop at 100y beyond zero (in)'),
          numField('start', 'Start distance (yd)'),
          numField('end', 'End distance (yd)'),
          numField('step', 'Step (yd)'),
        ];
    }
  }

  List<Widget> _buildResults(BallisticsCalculatorId id) {
    Widget resultCard(String title, String value, {String? hint}) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );

    switch (id) {
      case BallisticsCalculatorId.moaMilConverter:
        final moa = _num('moa');
        final mil = _num('mil');
        if (moa != null) {
          return [
            resultCard('MIL', formatNum(milFromMoa(moa) ?? 0, decimals: 4)),
          ];
        }
        if (mil != null) {
          return [
            resultCard('MOA', formatNum(moaFromMil(mil) ?? 0)),
          ];
        }
        return [resultCard('Result', 'Enter MOA or MIL')];

      case BallisticsCalculatorId.yardsMetresConverter:
        final yd = _num('yards');
        final m = _num('metres');
        if (yd != null) {
          return [resultCard('Metres', formatNum(metresFromYards(yd) ?? 0))];
        }
        if (m != null) {
          return [resultCard('Yards', formatNum(yardsFromMetres(m) ?? 0))];
        }
        return [resultCard('Result', 'Enter yards or metres')];

      case BallisticsCalculatorId.groupSizeMoa:
        final moa = groupSizeToMoa(
          groupSize: _num('group') ?? 0,
          groupInMm: _selects['groupUnit'] == 'mm',
          distance: _num('distance') ?? 0,
          distanceInMetres: _selects['distanceUnit'] == 'm',
        );
        return [
          resultCard(
            'Estimated MOA',
            moa != null ? formatNum(moa) : '—',
            hint: 'MOA = (group in × 100) / (distance yd × 1.047)',
          ),
        ];

      case BallisticsCalculatorId.angleSize:
        final result = angleSize(
          targetSize: _num('size') ?? 0,
          sizeInCm: _selects['sizeUnit'] == 'cm',
          distance: _num('distance') ?? 0,
          distanceInMetres: _selects['distanceUnit'] == 'm',
        );
        return [
          resultCard(
            'Angular size',
            result != null
                ? '${formatNum(result.moa)} MOA / ${formatNum(result.mil, decimals: 3)} MIL'
                : '—',
          ),
        ];

      case BallisticsCalculatorId.clickValue:
        final shift = clickValueShift(
          distance: _num('distance') ?? 0,
          distanceInMetres: _selects['distanceUnit'] == 'm',
          scopeInMoa: _selects['scopeUnit'] == 'moa',
          clickValue: _num('click') ?? 0,
        );
        return [
          resultCard(
            'Per click',
            shift != null
                ? '${formatNum(shift.inches, decimals: 3)} in / ${formatNum(shift.cm, decimals: 3)} cm'
                : '—',
          ),
        ];

      case BallisticsCalculatorId.correctionClicks:
        final corr = correctionClicks(
          offset: _num('offset') ?? 0,
          offsetInCm: _selects['offsetUnit'] == 'cm',
          distance: _num('distance') ?? 0,
          distanceInMetres: _selects['distanceUnit'] == 'm',
          scopeInMoa: _selects['scopeUnit'] == 'moa',
          clickValue: _num('click') ?? 0,
        );
        return [
          resultCard(
            'Correction',
            corr != null
                ? '${formatNum(corr.angle)} ${corr.angleUnit} / ${formatNum(corr.clicks, decimals: 1)} clicks'
                : '—',
          ),
        ];

      case BallisticsCalculatorId.energy:
        final e = muzzleEnergy(
          grains: _num('grains') ?? 0,
          velocity: _num('velocity') ?? 0,
          velocityInMps: _selects['velocityUnit'] == 'mps',
        );
        return [
          resultCard(
            'Muzzle energy',
            e != null
                ? '${formatNum(e.ftLb, decimals: 1)} ft-lb / ${formatNum(e.joules, decimals: 1)} J'
                : '—',
          ),
        ];

      case BallisticsCalculatorId.zeroOffset:
        final z = zeroOffset(
          oldZeroYards: _num('oldZero') ?? 0,
          newZeroYards: _num('newZero') ?? 0,
          dropPer100Inches: _num('dropPer100') ?? 0,
        );
        return [
          resultCard(
            'POI shift',
            z != null
                ? '${formatNum(z.inches)} in / ${formatNum(z.cm)} cm (~${formatNum(z.moa)} MOA)'
                : '—',
          ),
        ];

      case BallisticsCalculatorId.dropComeUp:
      case BallisticsCalculatorId.dopeCardBuilder:
        final rows = dropComeUpTable(
          zeroYards: _num('zero') ?? 0,
          dropAt100Inches: _num('drop100') ?? 0,
          startYards: _int('start') ?? 0,
          endYards: _int('end') ?? 0,
          stepYards: _int('step') ?? 0,
        );
        if (rows.isEmpty) {
          return [resultCard('Table', 'Enter valid values')];
        }
        return [
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Distance')),
                  DataColumn(label: Text('Drop (in)')),
                  DataColumn(label: Text('Drop (cm)')),
                  DataColumn(label: Text('MOA')),
                ],
                rows: rows
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(Text('${r.distanceYards} yd')),
                          DataCell(Text(formatNum(r.dropInches))),
                          DataCell(Text(formatNum(r.dropCm))),
                          DataCell(Text(formatNum(r.comeUpMoa))),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ];

      case BallisticsCalculatorId.windDrift:
        final w = windDrift(
          windSpeedMph: _num('wind') ?? 0,
          windAngleDeg: _num('angle') ?? 0,
          distanceYards: _num('distance') ?? 0,
          driftFactor: _num('factor') ?? 0,
        );
        return [
          resultCard(
            'Drift',
            w != null
                ? '${formatNum(w.inches)} in / ${formatNum(w.cm)} cm'
                : '—',
            hint: w != null
                ? '${formatNum(w.moa)} MOA / ${formatNum(w.mil, decimals: 3)} MIL correction'
                : null,
          ),
        ];

      case BallisticsCalculatorId.shotTimerSplits:
        final splits = parseSplitTimes(_controllers['splits']?.text ?? '');
        if (splits == null) {
          return [resultCard('Splits', 'Enter comma-separated seconds')];
        }
        final total = splits.fold<double>(0, (a, b) => a + b);
        final best = splits.reduce((a, b) => a < b ? a : b);
        final worst = splits.reduce((a, b) => a > b ? a : b);
        return [
          resultCard('Total', '${formatNum(total, decimals: 3)} s'),
          resultCard('Splits', '${splits.length}'),
          resultCard(
            'Best / worst',
            '${formatNum(best, decimals: 3)} / ${formatNum(worst, decimals: 3)} s',
          ),
        ];

      case BallisticsCalculatorId.powerFactor:
        final pf = powerFactor(
          grains: _num('grains') ?? 0,
          velocity: _num('velocity') ?? 0,
          velocityInMps: _selects['velocityUnit'] == 'mps',
        );
        return [resultCard('Power factor', pf != null ? formatNum(pf, decimals: 1) : '—')];

      case BallisticsCalculatorId.recoilEnergy:
        final r = recoilEnergy(
          gunWeightLb: _num('gun') ?? 0,
          bulletGrains: _num('bullet') ?? 0,
          powderGrains: _num('powder') ?? 0,
          muzzleVelocityFps: _num('velocity') ?? 0,
        );
        return [
          resultCard(
            'Recoil',
            r != null
                ? '${formatNum(r.recoilVelocity, decimals: 2)} ft/s · ${formatNum(r.ftLb, decimals: 1)} ft-lb'
                : '—',
          ),
        ];

      case BallisticsCalculatorId.roundCountCost:
        final c = roundCountCost(
          boxPrice: _num('boxPrice') ?? 0,
          roundsPerBox: _int('roundsPerBox') ?? 0,
          roundsPerSession: _int('roundsSession') ?? 0,
          sessionsPerWeek: _num('sessionsWeek') ?? 0,
        );
        return [
          resultCard('Per round', c != null ? formatMoneyGbp(c.perRound) : '—'),
          resultCard('Per session', c != null ? formatMoneyGbp(c.perSession) : '—'),
          resultCard('Per week', c != null ? formatMoneyGbp(c.perWeek) : '—'),
          resultCard('Per month', c != null ? formatMoneyGbp(c.perMonth) : '—'),
        ];

      case BallisticsCalculatorId.scopeRingHeight:
        final h = scopeRingHeightMm(
          objectiveMm: _num('objective') ?? 0,
          barrelDiameterMm: _num('barrel') ?? 0,
          clearanceMm: _num('clearance') ?? 0,
        );
        return [
          resultCard(
            'Suggested ring height',
            h != null ? '${formatNum(h, decimals: 1)} mm' : '—',
          ),
        ];

      case BallisticsCalculatorId.unitConverterPack:
        final value = _num('value');
        if (value == null) return [resultCard('Result', 'Enter a value')];
        final from = _selects['fromUnit'] ?? 'yd';
        final lines = <String>[];
        switch (from) {
          case 'yd':
            lines.add('${formatNum(metresFromYards(value) ?? 0)} m');
            lines.add('${formatNum(value * 36)} in');
          case 'm':
            lines.add('${formatNum(yardsFromMetres(value) ?? 0)} yd');
            lines.add('${formatNum(value * 100)} cm');
          case 'in':
            lines.add('${formatNum(value * 25.4, decimals: 2)} mm');
            lines.add('${formatNum(value / 36, decimals: 4)} yd');
          case 'mm':
            lines.add('${formatNum(value / 25.4, decimals: 3)} in');
            lines.add('${formatNum(value / 1000, decimals: 4)} m');
          case 'gr':
            lines.add('${formatNum(value * 0.06479891, decimals: 2)} g');
          case 'g':
            lines.add('${formatNum(value / 0.06479891, decimals: 1)} gr');
          case 'fps':
            lines.add('${formatNum(value / fpsPerMps, decimals: 1)} m/s');
          case 'mps':
            lines.add('${formatNum(value * fpsPerMps, decimals: 1)} ft/s');
        }
        return [resultCard('Conversions', lines.join('\n'))];
    }
  }
}

IconData calculatorIcon(String name) {
  return switch (name) {
    'swap_horiz' => Icons.swap_horiz_rounded,
    'straighten' => Icons.straighten_rounded,
    'center_focus_strong' => Icons.center_focus_strong_outlined,
    'crop_free' => Icons.crop_free_rounded,
    'adjust' => Icons.adjust_rounded,
    'ads_click' => Icons.ads_click_rounded,
    'bolt' => Icons.bolt_rounded,
    'vertical_align_center' => Icons.vertical_align_center_rounded,
    'table_chart' => Icons.table_chart_outlined,
    'air' => Icons.air_rounded,
    'timer' => Icons.timer_outlined,
    'speed' => Icons.speed_rounded,
    'vibration' => Icons.vibration_rounded,
    'payments' => Icons.payments_outlined,
    'height' => Icons.height_rounded,
    _ => Icons.calculate_outlined,
  };
}
