import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.plan,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'plan_key')
  final String? plan;
  @JsonKey(name: 'avatar_path')
  final String? avatarUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
