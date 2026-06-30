import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

bool? _readNullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'on') {
      return true;
    }
    if (normalized == 'false' ||
        normalized == '0' ||
        normalized == 'no' ||
        normalized == 'off') {
      return false;
    }
  }
  return null;
}

String? _readPlanKey(Map json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

Map<String, dynamic> normalizeUserJson(Map<String, dynamic> json) {
  final root = Map<String, dynamic>.from(json);
  final nested = root['data'];
  final source = nested is Map
      ? Map<String, dynamic>.from(nested)
      : root['user'] is Map
          ? Map<String, dynamic>.from(root['user'] as Map)
          : root;

  return {
    'id': source['id'],
    'name': source['name'],
    'email': source['email'],
    'plan_key': _readPlanKey(source, 'plan_key') ??
        _readPlanKey(source, 'plan') ??
        (source['plan'] is Map
            ? _readPlanKey(Map<String, dynamic>.from(source['plan'] as Map), 'key')
            : null),
    'mobile_access': _readNullableBool(source['mobile_access']),
    'avatar_path': source['avatar_path'] ?? source['avatar_url'],
  };
}

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.plan,
    this.mobileAccess,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'plan_key')
  final String? plan;
  @JsonKey(name: 'mobile_access')
  final bool? mobileAccess;
  @JsonKey(name: 'avatar_path')
  final String? avatarUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(normalizeUserJson(json));

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
