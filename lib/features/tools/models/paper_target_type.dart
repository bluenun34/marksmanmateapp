/// Category for browsing paper target types.
enum PaperTargetCategory {
  airPistol('Air pistol'),
  airRifle('Air rifle / smallbore'),
  fullBore('Full-bore & F-Class'),
  gallery('Gallery & rimfire'),
  hftFt('HFT & field target'),
  other('Other');

  const PaperTargetCategory(this.label);

  final String label;
}

/// A standard paper target the shooter may photograph for group analysis.
class PaperTargetType {
  const PaperTargetType({
    required this.id,
    required this.name,
    required this.category,
    required this.faceDiameterMm,
    required this.description,
    this.bullDiameterMm,
    this.ringDiametersMm = const [],
    this.isUserSaved = false,
    this.serverId,
  });

  final String id;
  final String name;
  final PaperTargetCategory category;
  /// Real-world scoring-face diameter in millimetres.
  final double faceDiameterMm;
  final double? bullDiameterMm;
  /// Optional ring diameters (mm, outer → inner) for the schematic preview.
  final List<double> ringDiametersMm;
  final String description;
  final bool isUserSaved;
  /// Server row id when synced to the MarksmanMate account.
  final int? serverId;

  double get faceDiameterInches => faceDiameterMm / 25.4;

  String get sizeLabel =>
      '${faceDiameterMm.toStringAsFixed(faceDiameterMm % 1 == 0 ? 0 : 1)} mm · '
      '${faceDiameterInches.toStringAsFixed(2)} in';

  /// Ring diameters for drawing, largest first.
  List<double> get previewRingDiametersMm {
    if (ringDiametersMm.isNotEmpty) return ringDiametersMm;
    final face = faceDiameterMm;
    final bull = bullDiameterMm ?? face * 0.12;
    return [face, face * 0.72, face * 0.44, bull];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'faceDiameterMm': faceDiameterMm,
        'description': description,
        if (bullDiameterMm != null) 'bullDiameterMm': bullDiameterMm,
        if (ringDiametersMm.isNotEmpty)
          'ringDiametersMm': ringDiametersMm,
        'isUserSaved': isUserSaved,
        if (serverId != null) 'serverId': serverId,
      };

  Map<String, dynamic> toApiJson() => {
        'client_id': id,
        'name': name,
        'category': category.name,
        'face_diameter_mm': faceDiameterMm,
        'description': description,
        if (bullDiameterMm != null) 'bull_diameter_mm': bullDiameterMm,
        if (ringDiametersMm.isNotEmpty) 'ring_diameters_mm': ringDiametersMm,
      };

  factory PaperTargetType.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String? ?? PaperTargetCategory.other.name;
    final category = PaperTargetCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => PaperTargetCategory.other,
    );
    return PaperTargetType(
      id: json['id'] as String? ?? 'user-import',
      name: json['name'] as String? ?? 'Imported target',
      category: category,
      faceDiameterMm: (json['faceDiameterMm'] as num?)?.toDouble() ?? 100,
      description: json['description'] as String? ?? '',
      bullDiameterMm: (json['bullDiameterMm'] as num?)?.toDouble(),
      ringDiametersMm: (json['ringDiametersMm'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      isUserSaved: json['isUserSaved'] as bool? ?? true,
      serverId: json['serverId'] as int? ?? json['server_id'] as int?,
    );
  }

  factory PaperTargetType.fromApiJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String? ?? PaperTargetCategory.other.name;
    final category = PaperTargetCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => PaperTargetCategory.other,
    );
    final rings = (json['ring_diameters_mm'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [];
    return PaperTargetType(
      id: json['client_id'] as String? ?? 'user-${json['id']}',
      name: json['name'] as String? ?? 'Saved target',
      category: category,
      faceDiameterMm: (json['face_diameter_mm'] as num?)?.toDouble() ?? 100,
      description: json['description'] as String? ?? '',
      bullDiameterMm: (json['bull_diameter_mm'] as num?)?.toDouble(),
      ringDiametersMm: rings,
      isUserSaved: true,
      serverId: json['id'] as int?,
    );
  }

  PaperTargetType copyWith({
    String? id,
    String? name,
    PaperTargetCategory? category,
    double? faceDiameterMm,
    String? description,
    double? bullDiameterMm,
    List<double>? ringDiametersMm,
    bool? isUserSaved,
    int? serverId,
  }) {
    return PaperTargetType(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      faceDiameterMm: faceDiameterMm ?? this.faceDiameterMm,
      description: description ?? this.description,
      bullDiameterMm: bullDiameterMm ?? this.bullDiameterMm,
      ringDiametersMm: ringDiametersMm ?? this.ringDiametersMm,
      isUserSaved: isUserSaved ?? this.isUserSaved,
      serverId: serverId ?? this.serverId,
    );
  }
}
