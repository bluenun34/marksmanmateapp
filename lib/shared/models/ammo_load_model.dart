import 'package:json_annotation/json_annotation.dart';

part 'ammo_load_model.g.dart';

@JsonSerializable()
class AmmoLoadModel {
  const AmmoLoadModel({
    required this.id,
    required this.name,
    this.calibre,
    this.manufacturer,
    this.bulletWeight,
    this.powderCharge,
    this.notes,
  });

  final int id;
  final String name;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? calibre;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? manufacturer;
  @JsonKey(name: 'bullet_weight')
  final double? bulletWeight;
  @JsonKey(name: 'powder_charge')
  final double? powderCharge;
  final String? notes;

  factory AmmoLoadModel.fromJson(Map<String, dynamic> json) {
    return AmmoLoadModel(
      id: (json['id'] as num).toInt(),
      name: (json['display_name'] ?? json['name']) as String,
      calibre: json['caliber_or_gauge'] as String?,
      manufacturer: json['brand'] as String?,
      bulletWeight: (json['bullet_weight'] as num?)?.toDouble(),
      powderCharge: (json['powder_charge'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$AmmoLoadModelToJson(this);
}
