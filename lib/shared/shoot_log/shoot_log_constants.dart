/// Mirrors Laravel `config/shoot_log.php` for consistent labels and options.
class ShootLogConstants {
  ShootLogConstants._();

  static const disciplines = <String, String>{
    'rifle': 'Rifle',
    'pistol': 'Pistol',
    'shotgun_clay': 'Shotgun – Clay',
    'shotgun_game': 'Shotgun – Game',
    'air_rifle': 'Air Rifle',
    'air_pistol': 'Air Pistol',
    'other': 'Other',
  };

  static const sessionTypes = <String, String>{
    'practice': 'Practice',
    'competition': 'Competition',
    'zeroing': 'Zeroing',
    'hunting': 'Hunting / Game',
    'training': 'Coaching / Training',
    'other': 'Other',
  };

  static const venueTypes = ['outdoor', 'indoor'];

  static const distanceUnits = ['metres', 'yards', 'feet'];

  static const groupSizeUnits = ['mm', 'inches', 'moa'];

  static const indoorLightingOptions = [
    'artificial',
    'natural',
    'mixed',
  ];

  static const indoorLightingLabels = {
    'artificial': 'Artificial',
    'natural': 'Natural / Daylight',
    'mixed': 'Mixed',
  };

  /// Discipline-specific optional fields from Laravel config.
  static const disciplineFields = <String, List<DisciplineFieldDef>>{
    'rifle': [
      DisciplineFieldDef(
        name: 'shooting_position',
        label: 'Shooting Position',
        type: DisciplineFieldType.select,
        options: ['Prone', 'Standing', 'Kneeling', 'Sitting', 'Benchrest'],
      ),
      DisciplineFieldDef(
        name: 'zero_distance',
        label: 'Zero Distance (m)',
        type: DisciplineFieldType.number,
      ),
      DisciplineFieldDef(
        name: 'scope_magnification',
        label: 'Scope Magnification',
        type: DisciplineFieldType.text,
      ),
      DisciplineFieldDef(
        name: 'elevation_adj',
        label: 'Elevation Adjustment',
        type: DisciplineFieldType.text,
      ),
      DisciplineFieldDef(
        name: 'windage_adj',
        label: 'Windage Adjustment',
        type: DisciplineFieldType.text,
      ),
      DisciplineFieldDef(
        name: 'muzzle_velocity',
        label: 'Muzzle Velocity (fps)',
        type: DisciplineFieldType.number,
      ),
    ],
    'pistol': [
      DisciplineFieldDef(
        name: 'sight_type',
        label: 'Sight Type',
        type: DisciplineFieldType.select,
        options: ['Iron Sights', 'Red Dot', 'Laser', 'Optic'],
      ),
      DisciplineFieldDef(
        name: 'shooting_position',
        label: 'Position',
        type: DisciplineFieldType.select,
        options: ['Standing', 'Isosceles', 'Weaver', 'Seated'],
      ),
    ],
    'shotgun_clay': [
      DisciplineFieldDef(
        name: 'discipline_type',
        label: 'Clay Discipline',
        type: DisciplineFieldType.select,
        options: [
          'Sporting',
          'Skeet',
          'Trap',
          'DTL',
          'Olympic Trap',
          'English Skeet',
          'Compak',
        ],
      ),
      DisciplineFieldDef(
        name: 'ground_name',
        label: 'Shooting Ground',
        type: DisciplineFieldType.text,
      ),
      DisciplineFieldDef(
        name: 'choke',
        label: 'Choke',
        type: DisciplineFieldType.select,
        options: [
          'Cylinder',
          'Improved Cylinder',
          'Quarter',
          'Half',
          'Three-Quarter',
          'Full',
        ],
      ),
      DisciplineFieldDef(
        name: 'shot_size',
        label: 'Shot Size',
        type: DisciplineFieldType.select,
        options: ['7.5', '8', '9', '7', '6'],
      ),
      DisciplineFieldDef(
        name: 'shot_weight',
        label: 'Shot Weight (g)',
        type: DisciplineFieldType.number,
      ),
      DisciplineFieldDef(
        name: 'stands',
        label: 'Stands Shot',
        type: DisciplineFieldType.number,
      ),
    ],
    'shotgun_game': [
      DisciplineFieldDef(
        name: 'quarry',
        label: 'Quarry/Game',
        type: DisciplineFieldType.text,
      ),
      DisciplineFieldDef(
        name: 'estate_name',
        label: 'Estate/Location Name',
        type: DisciplineFieldType.text,
      ),
      DisciplineFieldDef(
        name: 'choke',
        label: 'Choke',
        type: DisciplineFieldType.select,
        options: [
          'Cylinder',
          'Improved Cylinder',
          'Quarter',
          'Half',
          'Three-Quarter',
          'Full',
        ],
      ),
      DisciplineFieldDef(
        name: 'pellet_size',
        label: 'Pellet Size',
        type: DisciplineFieldType.select,
        options: ['BB', '1', '3', '4', '5', '6', '7'],
      ),
      DisciplineFieldDef(
        name: 'birds_flushed',
        label: 'Birds Flushed',
        type: DisciplineFieldType.number,
      ),
    ],
    'air_rifle': [
      DisciplineFieldDef(
        name: 'shooting_position',
        label: 'Shooting Position',
        type: DisciplineFieldType.select,
        options: ['Prone', 'Standing', 'Kneeling', 'Seated'],
      ),
      DisciplineFieldDef(
        name: 'power_source',
        label: 'Power Source',
        type: DisciplineFieldType.select,
        options: ['Spring', 'PCP', 'CO2', 'Gas Ram'],
      ),
      DisciplineFieldDef(
        name: 'fps',
        label: 'FPS / Velocity',
        type: DisciplineFieldType.number,
      ),
      DisciplineFieldDef(
        name: 'scope_magnification',
        label: 'Scope Magnification',
        type: DisciplineFieldType.text,
      ),
    ],
    'air_pistol': [
      DisciplineFieldDef(
        name: 'power_source',
        label: 'Power Source',
        type: DisciplineFieldType.select,
        options: ['Spring', 'PCP', 'CO2'],
      ),
      DisciplineFieldDef(
        name: 'fps',
        label: 'FPS / Velocity',
        type: DisciplineFieldType.number,
      ),
      DisciplineFieldDef(
        name: 'sight_type',
        label: 'Sight Type',
        type: DisciplineFieldType.select,
        options: ['Iron Sights', 'Red Dot', 'Dioptre'],
      ),
    ],
    'other': [
      DisciplineFieldDef(
        name: 'activity_description',
        label: 'Activity Description',
        type: DisciplineFieldType.text,
      ),
    ],
  };
}

enum DisciplineFieldType { text, number, select }

class DisciplineFieldDef {
  const DisciplineFieldDef({
    required this.name,
    required this.label,
    required this.type,
    this.options = const [],
  });

  final String name;
  final String label;
  final DisciplineFieldType type;
  final List<String> options;
}
