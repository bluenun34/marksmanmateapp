class NotificationSummary {
  const NotificationSummary({
    required this.unreadNotifications,
    required this.unreadMessages,
    required this.pendingFriendRequests,
    required this.pendingGroupInvites,
  });

  final int unreadNotifications;
  final int unreadMessages;
  final int pendingFriendRequests;
  final int pendingGroupInvites;

  int get totalBadge =>
      unreadNotifications + unreadMessages + pendingFriendRequests + pendingGroupInvites;

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      unreadNotifications: json['unread_notifications'] as int? ?? 0,
      unreadMessages: json['unread_messages'] as int? ?? 0,
      pendingFriendRequests: json['pending_friend_requests'] as int? ?? 0,
      pendingGroupInvites: json['pending_group_invites'] as int? ?? 0,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    this.title,
    this.body,
    required this.data,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String? type;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isUnread => readAt == null;

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    return _fallbackTitle();
  }

  String get displayBody {
    if (body != null && body!.trim().isNotEmpty) return body!.trim();
    return _fallbackBody();
  }

  String? get conversationId => data['conversation_id']?.toString();
  int? get eventId {
    final raw = data['event_id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  int? get groupId {
    final raw = data['group_id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  String _fallbackTitle() {
    return switch (type) {
      'new_message' => 'New message',
      'event_rsvp_reminder' => 'Event reminder',
      'event_tomorrow_digest' => 'Tomorrow\'s events',
      'structured_shoot_log_reminder' => 'Log your shoot',
      'friend_request' => 'Friend request',
      'friend_request_accepted' => 'Friend request accepted',
      'group_invite' => 'Group invite',
      _ => 'Notification',
    };
  }

  String _fallbackBody() {
    return switch (type) {
      'new_message' =>
        '${data['sender_name'] ?? 'Someone'}: ${data['preview'] ?? ''}',
      'event_rsvp_reminder' => data['event_name']?.toString() ?? '',
      'structured_shoot_log_reminder' =>
        data['event_name']?.toString() ?? 'Create a shoot log for this event.',
      'friend_request' => '${data['sender_name'] ?? 'Someone'} sent a request.',
      'friend_request_accepted' =>
        '${data['accepter_name'] ?? 'Someone'} accepted your request.',
      'group_invite' =>
        '${data['inviter_name'] ?? data['sender_name'] ?? 'Someone'} invited you to ${data['group_name'] ?? 'a group'}.',
      _ => data['body']?.toString() ?? '',
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      data: dataRaw is Map ? Map<String, dynamic>.from(dataRaw) : const {},
      readAt: _parseDate(json['read_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class ConversationParticipantRef {
  const ConversationParticipantRef({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String? avatarUrl;

  factory ConversationParticipantRef.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    if (id == null) {
      throw FormatException('Participant missing id: ${json['id']}');
    }
    return ConversationParticipantRef(
      id: id,
      name: json['name']?.toString() ?? 'User',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}

class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.type,
    required this.title,
    required this.unread,
    this.latestPreview,
    this.updatedAt,
    this.participants = const [],
  });

  final int id;
  final String type;
  final String title;
  final bool unread;
  final String? latestPreview;
  final DateTime? updatedAt;
  final List<ConversationParticipantRef> participants;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    final latest = json['latest_message'];
    final id = _asInt(json['id']);
    if (id == null) {
      throw FormatException('Conversation missing id: ${json['id']}');
    }
    final participantsRaw = json['participants'];
    final participants = participantsRaw is List
        ? participantsRaw
            .whereType<Map>()
            .map(
              (entry) => ConversationParticipantRef.fromJson(
                Map<String, dynamic>.from(entry),
              ),
            )
            .toList()
        : const <ConversationParticipantRef>[];

    return ConversationSummary(
      id: id,
      type: json['type']?.toString() ?? 'direct',
      title: json['title']?.toString() ?? 'Conversation',
      unread: json['unread'] == true,
      latestPreview: latest is Map ? latest['body']?.toString() : null,
      updatedAt: _parseDate(json['updated_at']),
      participants: participants,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.body,
    required this.userId,
    this.userName,
    this.avatarUrl,
    this.createdAt,
  });

  final int id;
  final String body;
  final int userId;
  final String? userName;
  final String? avatarUrl;
  final DateTime? createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    final userId = _asInt(json['user_id']);
    if (id == null || userId == null) {
      throw FormatException('Message missing id or user_id');
    }
    return ChatMessage(
      id: id,
      body: json['body']?.toString() ?? '',
      userId: userId,
      userName: json['user_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
