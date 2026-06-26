import 'package:json_annotation/json_annotation.dart';

part 'firearm_model.g.dart';

@JsonSerializable()
class FirearmModel {
  const FirearmModel({
    required this.id,
    required this.name,
    this.make,
    this.model,
    this.calibre,
    this.serialNumber,
    this.notes,
  });

  final int id;
  @JsonKey(name: 'display_name')
  final String name;
  final String? make;
  final String? model;
  @JsonKey(name: 'caliber_or_gauge')
  final String? calibre;
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  final String? notes;

  factory FirearmModel.fromJson(Map<String, dynamic> json) =>
      _$FirearmModelFromJson(json);

  Map<String, dynamic> toJson() => _$FirearmModelToJson(this);
}
