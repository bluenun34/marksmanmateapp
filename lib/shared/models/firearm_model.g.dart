// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firearm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirearmModel _$FirearmModelFromJson(Map<String, dynamic> json) => FirearmModel(
  id: (json['id'] as num).toInt(),
  name: json['display_name'] as String,
  make: json['make'] as String?,
  model: json['model'] as String?,
  calibre: json['caliber_or_gauge'] as String?,
  serialNumber: json['serial_number'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$FirearmModelToJson(FirearmModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.name,
      'make': instance.make,
      'model': instance.model,
      'caliber_or_gauge': instance.calibre,
      'serial_number': instance.serialNumber,
      'notes': instance.notes,
    };
