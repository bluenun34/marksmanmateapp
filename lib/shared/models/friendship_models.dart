/// Friend models for the mobile API.
library;

class FriendUserModel {
  const FriendUserModel({
    required this.id,
    required this.name,
    this.friendshipId,
    this.friendshipStatus,
    this.canRequest = false,
  });

  final int id;
  final String name;
  final int? friendshipId;
  final String? friendshipStatus;
  final bool canRequest;

  factory FriendUserModel.fromJson(Map<String, dynamic> json) {
    return FriendUserModel(
      id: json['id'] as int,
      name: json['name']?.toString() ??
          json['user_name']?.toString() ??
          'User',
      friendshipId: json['friendship_id'] as int?,
      friendshipStatus: json['friendship_status'] as String?,
      canRequest: json['can_request'] == true,
    );
  }
}

class FriendshipModel {
  const FriendshipModel({
    required this.id,
    required this.status,
    required this.direction,
    required this.userId,
    required this.userName,
    this.createdAt,
    this.acceptedAt,
  });

  final int id;
  final String status;
  final String direction;
  final int userId;
  final String userName;
  final DateTime? createdAt;
  final DateTime? acceptedAt;

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    return FriendshipModel(
      id: json['id'] as int,
      status: json['status']?.toString() ?? 'pending',
      direction: json['direction']?.toString() ?? 'incoming',
      userId: json['user_id'] as int,
      userName: json['user_name']?.toString() ?? 'User',
      createdAt: _parseDate(json['created_at']),
      acceptedAt: _parseDate(json['accepted_at']),
    );
  }

  bool get isIncoming => direction == 'incoming';
  bool get isPending => status == 'pending';
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
