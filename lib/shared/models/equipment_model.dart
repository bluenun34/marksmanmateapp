class EquipmentModel {
  const EquipmentModel({
    required this.id,
    required this.name,
    this.category,
    this.brand,
    this.model,
    this.firearmId,
    this.notes,
  });

  final int id;
  final String name;
  final String? category;
  final String? brand;
  final String? model;
  final int? firearmId;
  final String? notes;

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: (json['id'] as num).toInt(),
      name: (json['display_name'] ?? json['name']) as String,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      firearmId: (json['firearm_id'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );
  }

  static const fieldCategories = {
    'optic',
    'binocular',
    'spotting_scope',
    'chronograph',
    'rangefinder',
    'bipod_rest',
    'bag_rest',
    'sling',
    'moderator',
    'mount_rings',
    'accessory',
    'other',
  };

  bool get isFieldUsable =>
      category == null || fieldCategories.contains(category);
}
