enum BallisticsCalculatorId {
  moaMilConverter,
  yardsMetresConverter,
  groupSizeMoa,
  angleSize,
  clickValue,
  correctionClicks,
  energy,
  zeroOffset,
  dropComeUp,
  windDrift,
  shotTimerSplits,
  powerFactor,
  recoilEnergy,
  roundCountCost,
  scopeRingHeight,
  unitConverterPack,
  dopeCardBuilder,
}

class CalculatorDefinition {
  const CalculatorDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final BallisticsCalculatorId id;
  final String title;
  final String subtitle;
  final String icon;
}

const ballisticsCalculators = <CalculatorDefinition>[
  CalculatorDefinition(
    id: BallisticsCalculatorId.moaMilConverter,
    title: 'MOA ↔ MIL',
    subtitle: 'Convert minute of angle and milliradian values',
    icon: 'swap_horiz',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.yardsMetresConverter,
    title: 'Yards ↔ Metres',
    subtitle: 'Distance unit conversion',
    icon: 'straighten',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.groupSizeMoa,
    title: 'Group size → MOA',
    subtitle: 'Estimate precision from group and distance',
    icon: 'center_focus_strong',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.angleSize,
    title: 'Angle size',
    subtitle: 'Target size at distance in MOA/MIL',
    icon: 'crop_free',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.clickValue,
    title: 'Click value',
    subtitle: 'Impact shift per scope click',
    icon: 'adjust',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.correctionClicks,
    title: 'Correction → clicks',
    subtitle: 'Convert POI offset to scope clicks',
    icon: 'ads_click',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.energy,
    title: 'Muzzle energy',
    subtitle: 'Energy from bullet weight and velocity',
    icon: 'bolt',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.zeroOffset,
    title: 'Zero offset',
    subtitle: 'POI shift when changing zero distance',
    icon: 'vertical_align_center',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.dropComeUp,
    title: 'Drop / come-up table',
    subtitle: 'Quick holdover planning table',
    icon: 'table_chart',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.windDrift,
    title: 'Wind drift',
    subtitle: 'Estimate horizontal drift and correction',
    icon: 'air',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.shotTimerSplits,
    title: 'Split calculator',
    subtitle: 'Summarise shot timer split strings',
    icon: 'timer',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.powerFactor,
    title: 'Power factor',
    subtitle: 'IPSC/USPSA style power factor',
    icon: 'speed',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.recoilEnergy,
    title: 'Recoil energy',
    subtitle: 'Free recoil from gun and load data',
    icon: 'vibration',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.roundCountCost,
    title: 'Round count cost',
    subtitle: 'Ammo spend per session, week, month',
    icon: 'payments',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.scopeRingHeight,
    title: 'Scope ring height',
    subtitle: 'Approx ring height from objective size',
    icon: 'height',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.unitConverterPack,
    title: 'Unit converter pack',
    subtitle: 'Grains, grams, inches, mm, fps, m/s',
    icon: 'calculate',
  ),
  CalculatorDefinition(
    id: BallisticsCalculatorId.dopeCardBuilder,
    title: 'DOPE card builder',
    subtitle: 'Quick range card from zero and drop rate',
    icon: 'table_chart',
  ),
];

CalculatorDefinition? calculatorByRoute(String route) {
  for (final calc in ballisticsCalculators) {
    if (calc.id.name == route) return calc;
  }
  return null;
}

String calculatorRoute(BallisticsCalculatorId id) => id.name;
