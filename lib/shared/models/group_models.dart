/// Group models for the mobile API.
library;

class GroupMembershipRef {
  const GroupMembershipRef({
    required this.role,
    required this.status,
    this.joinedAt,
  });

  final String role;
  final String status;
  final DateTime? joinedAt;

  factory GroupMembershipRef.fromJson(Map<String, dynamic> json) {
    return GroupMembershipRef(
      role: json['role']?.toString() ?? 'member',
      status: json['status']?.toString() ?? 'active',
      joinedAt: _parseDate(json['joined_at']),
    );
  }

  bool get isActive => status == 'active';
  bool get isInvited => status == 'invited';
}

class GroupMemberModel {
  const GroupMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.roleLabel,
    required this.status,
    required this.statusLabel,
    this.joinedAt,
    this.canManage = false,
    this.assignableRoles = const [],
  });

  final int id;
  final int userId;
  final String name;
  final String role;
  final String roleLabel;
  final String status;
  final String statusLabel;
  final DateTime? joinedAt;
  final bool canManage;
  final List<String> assignableRoles;

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['assignable_roles'];
    return GroupMemberModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name']?.toString() ?? 'Member',
      role: json['role']?.toString() ?? 'member',
      roleLabel: json['role_label']?.toString() ?? 'Member',
      status: json['status']?.toString() ?? 'active',
      statusLabel: json['status_label']?.toString() ?? 'Active',
      joinedAt: _parseDate(json['joined_at']),
      canManage: json['can_manage'] == true,
      assignableRoles: rolesRaw is List
          ? rolesRaw.map((e) => e.toString()).toList()
          : const [],
    );
  }

  bool get isInvited => status == 'invited';
}

class GroupListItem {
  const GroupListItem({
    required this.id,
    required this.name,
    this.role,
    this.status,
    this.memberCount,
  });

  final int id;
  final String name;
  final String? role;
  final String? status;
  final int? memberCount;

  factory GroupListItem.fromJson(Map<String, dynamic> json) {
    return GroupListItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Group',
      role: json['role'] as String?,
      status: json['status'] as String?,
      memberCount: json['member_count'] as int?,
    );
  }

  String get detailPath => '/groups/$id';
}

class GroupInviteModel {
  const GroupInviteModel({
    required this.membershipId,
    required this.groupId,
    required this.groupName,
    this.inviterName,
    this.description,
  });

  final int membershipId;
  final int groupId;
  final String groupName;
  final String? inviterName;
  final String? description;

  factory GroupInviteModel.fromJson(Map<String, dynamic> json) {
    return GroupInviteModel(
      membershipId: json['membership_id'] as int,
      groupId: json['group_id'] as int,
      groupName: json['group_name']?.toString() ?? 'Group',
      inviterName: json['inviter_name'] as String?,
      description: json['description'] as String?,
    );
  }
}

class InviteableFriend {
  const InviteableFriend({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory InviteableFriend.fromJson(Map<String, dynamic> json) {
    return InviteableFriend(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Friend',
    );
  }
}

class GroupDetailModel {
  const GroupDetailModel({
    required this.id,
    required this.name,
    this.description,
    this.visibility,
    this.ownerName,
    this.memberCount,
    this.postsCount,
    this.clubId,
    this.clubName,
    this.clubSlug,
    this.conversationId,
    this.upcomingEventsCount,
    this.myMembership,
    this.canManage = false,
  });

  final int id;
  final String name;
  final String? description;
  final String? visibility;
  final String? ownerName;
  final int? memberCount;
  final int? postsCount;
  final int? clubId;
  final String? clubName;
  final String? clubSlug;
  final int? conversationId;
  final int? upcomingEventsCount;
  final GroupMembershipRef? myMembership;
  final bool canManage;

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    final membershipRaw = json['my_membership'];
    return GroupDetailModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Group',
      description: json['description'] as String?,
      visibility: json['visibility'] as String?,
      ownerName: json['owner_name'] as String?,
      memberCount: json['member_count'] as int?,
      postsCount: json['posts_count'] as int?,
      clubId: json['club_id'] as int?,
      clubName: json['club_name'] as String?,
      clubSlug: json['club_slug'] as String?,
      conversationId: json['conversation_id'] as int?,
      upcomingEventsCount: json['upcoming_events_count'] as int?,
      myMembership: membershipRaw is Map
          ? GroupMembershipRef.fromJson(Map<String, dynamic>.from(membershipRaw))
          : null,
      canManage: json['can_manage'] == true,
    );
  }

  String? get conversationPath =>
      conversationId != null ? '/messages/$conversationId' : null;

  String? get clubPath =>
      clubSlug != null && clubSlug!.isNotEmpty ? '/clubs/$clubSlug' : null;

  bool get isOwner => myMembership?.role == 'owner';
}

class GroupPostModel {
  const GroupPostModel({
    required this.id,
    required this.title,
    this.body,
    this.type = 'text',
    this.linkUrl,
    this.isPinned = false,
    this.score = 0,
    this.commentCount = 0,
    required this.authorId,
    required this.authorName,
    this.tags = const [],
    this.createdAt,
  });

  final int id;
  final String title;
  final String? body;
  final String type;
  final String? linkUrl;
  final bool isPinned;
  final int score;
  final int commentCount;
  final int authorId;
  final String authorName;
  final List<String> tags;
  final DateTime? createdAt;

  factory GroupPostModel.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    return GroupPostModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? 'Post',
      body: json['body'] as String?,
      type: json['type']?.toString() ?? 'text',
      linkUrl: json['link_url'] as String?,
      isPinned: json['is_pinned'] == true,
      score: json['score'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      authorId: json['author_id'] as int,
      authorName: json['author_name']?.toString() ?? 'Member',
      tags: tagsRaw is List ? tagsRaw.map((e) => e.toString()).toList() : const [],
      createdAt: _parseDate(json['created_at']),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
