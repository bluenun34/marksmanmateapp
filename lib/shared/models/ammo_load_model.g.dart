// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ammo_load_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AmmoLoadModel _$AmmoLoadModelFromJson(Map<String, dynamic> json) =>
    AmmoLoadModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      bulletWeight: (json['bullet_weight'] as num?)?.toDouble(),
      powderCharge: (json['powder_charge'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AmmoLoadModelToJson(AmmoLoadModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bullet_weight': instance.bulletWeight,
      'powder_charge': instance.powderCharge,
      'notes': instance.notes,
    };
