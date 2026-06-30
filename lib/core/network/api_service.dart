import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/models/ammo_load_model.dart';
import '../../shared/models/club_models.dart';
import '../../shared/models/group_models.dart';
import '../../shared/models/friendship_models.dart';
import '../../shared/models/equipment_model.dart';
import '../../shared/models/event_model.dart';
import '../../shared/models/firearm_model.dart';
import '../../shared/models/notification_models.dart';
import '../../shared/models/shoot_session_model.dart';
import '../../shared/models/sync_payload.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/public_user_profile_model.dart';
import '../../shared/models/structured_log_reminder_models.dart';
import 'api_errors.dart';
import 'dio_client.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(dioClientProvider));
});

class CreateShootSessionResult {
  const CreateShootSessionResult({
    required this.session,
    this.firstEntryId,
  });

  final ShootSessionModel session;
  final int? firstEntryId;
}

class ApiService {
  const ApiService(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
      'device_name': 'MarksmanMate Flutter',
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final resp = await _dio.post('/auth/google', data: {
      'id_token': idToken,
      'device_name': 'MarksmanMate Flutter',
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<UserModel> getUser() async {
    final resp = await _dio.get('/user');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<PublicUserProfileModel> getUserProfile(int userId) async {
    final resp = await _dio.get('/users/$userId');
    return PublicUserProfileModel.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<SyncPayload> getSync({int shootLogsLimit = 50}) async {
    final resp = await _dio.get(
      '/sync',
      queryParameters: {'shoot_logs_limit': shootLogsLimit},
    );
    final raw = resp.data;
    if (raw is! Map) {
      throw const FormatException('Sync response was not a JSON object');
    }
    return SyncPayload.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<List<FirearmModel>> getFirearms() async {
    final resp = await _dio.get('/firearms');
    final list = resp.data as List;
    return list
        .map((e) => FirearmModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AmmoLoadModel>> getAmmoLoads() async {
    final resp = await _dio.get('/ammo-loads');
    final list = resp.data as List;
    return list
        .map((e) => AmmoLoadModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EquipmentModel>> getEquipment() async {
    final resp = await _dio.get('/equipment');
    final list = resp.data as List;
    return list
        .map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ShootSessionModel>> getShootSessions({
    int page = 1,
    int perPage = 50,
  }) async {
    final resp = await _dio.get(
      '/shoot-log',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final raw = resp.data;
    final List list;
    if (raw is Map && raw['data'] is List) {
      list = raw['data'] as List;
    } else if (raw is List) {
      list = raw;
    } else {
      return const [];
    }
    final sessions = <ShootSessionModel>[];
    for (final entry in list) {
      if (entry is! Map) continue;
      try {
        sessions.add(
          ShootSessionModel.fromApiJson(Map<String, dynamic>.from(entry)),
        );
      } catch (_) {}
    }
    return sessions;
  }

  Future<CreateShootSessionResult> createShootSession(
    Map<String, dynamic> data,
  ) async {
    final resp = await _dio.post('/shoot-log', data: data);
    final body = resp.data as Map<String, dynamic>;
    final logJson = Map<String, dynamic>.from(
      (body['shoot_log'] ?? body) as Map,
    );
    int? firstEntryId;
    final entries = logJson['entries'];
    if (entries is List && entries.isNotEmpty) {
      final first = entries.first;
      if (first is Map) {
        firstEntryId = first['id'] as int?;
      }
    }
    return CreateShootSessionResult(
      session: ShootSessionModel.fromApiJson(logJson),
      firstEntryId: firstEntryId,
    );
  }

  Future<void> uploadSessionPhotos({
    required int shootLogId,
    required List<XFile> files,
  }) async {
    if (files.isEmpty) return;
    final formData = FormData();
    for (final file in files) {
      final bytes = await file.readAsBytes();
      formData.files.add(
        MapEntry(
          'images[]',
          MultipartFile.fromBytes(bytes, filename: file.name),
        ),
      );
    }
    await _dio.post(
      '/shoot-log/$shootLogId/session-images',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> uploadTargetPhotos({
    required int shootLogId,
    required int entryId,
    required List<XFile> files,
  }) async {
    if (files.isEmpty) return;
    final formData = FormData();
    for (final file in files) {
      final bytes = await file.readAsBytes();
      formData.files.add(
        MapEntry(
          'images[]',
          MultipartFile.fromBytes(bytes, filename: file.name),
        ),
      );
    }
    await _dio.post(
      '/shoot-log/$shootLogId/entries/$entryId/target-images',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<ShootSessionModel> getShootSession(int id) async {
    final resp = await _dio.get('/shoot-log/$id');
    return ShootSessionModel.fromApiJson(resp.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getPaperTargets() async {
    final resp = await _dio.get('/paper-targets');
    final raw = resp.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  Future<Map<String, dynamic>> upsertPaperTarget(
    Map<String, dynamic> data,
  ) async {
    final resp = await _dio.post('/paper-targets', data: data);
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<void> deletePaperTarget(int id) async {
    await _dio.delete('/paper-targets/$id');
  }

  Future<ShootSessionModel> updateShootSession(
    int id,
    Map<String, dynamic> data,
  ) async {
    final resp = await _dio.put('/shoot-log/$id', data: data);
    final body = resp.data as Map<String, dynamic>;
    final logJson = Map<String, dynamic>.from(
      (body['shoot_log'] ?? body) as Map,
    );
    return ShootSessionModel.fromApiJson(logJson);
  }

  Future<void> deleteShootSession(int id) async {
    await _dio.delete('/shoot-log/$id');
  }

  Future<List<EventModel>> getUpcomingEvents({int limit = 5}) async {
    return getEvents(limit: limit, statusFilter: 'upcoming');
  }

  Future<List<EventModel>> getEvents({
    int limit = 20,
    String statusFilter = 'upcoming',
    String? scope,
  }) async {
    final resp = await _dio.get(
      '/events',
      queryParameters: {
        'limit': limit,
        if (statusFilter.isNotEmpty) 'status_filter': statusFilter,
        if (scope != null && scope.isNotEmpty) 'scope': scope,
      },
    );
    final raw = resp.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => EventModel.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<EventDetailModel> getEvent(int id) async {
    final resp = await _dio.get('/events/$id');
    return EventDetailModel.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<void> attendEvent(int id) async {
    await _dio.post('/events/$id/attend');
  }

  Future<void> unattendEvent(int id) async {
    await _dio.delete('/events/$id/attend');
  }

  Future<EventCheckinStatus> getEventCheckin(int id) async {
    final resp = await _dio.get('/events/$id/checkin');
    return EventCheckinStatus.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<Map<String, dynamic>> selfCheckinEvent(
    int id, {
    String? token,
    String? pin,
  }) async {
    final resp = await _dio.post(
      '/events/$id/checkin',
      data: {
        if (token != null && token.isNotEmpty) 'token': token,
        if (pin != null && pin.isNotEmpty) 'pin': pin,
      },
    );
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<List<EventScoreModel>> getEventScores(int id) async {
    final resp = await _dio.get('/events/$id/scores');
    final raw = resp.data;
    if (raw is! Map) return const [];
    final list = raw['scores'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => EventScoreModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<EventScoreModel> updateEventScore(
    int eventId,
    int userId, {
    double? score,
    String? division,
    String? notes,
    Map<String, dynamic>? stageScores,
  }) async {
    final resp = await _dio.put(
      '/events/$eventId/scores/$userId',
      data: {
        if (score != null) 'score': score,
        if (division != null) 'division': division,
        if (notes != null) 'notes': notes,
        if (stageScores != null) 'stage_scores': stageScores,
      },
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    final scoreJson = body['score'] as Map;
    return EventScoreModel.fromJson(Map<String, dynamic>.from(scoreJson));
  }

  Future<List<EventLiveScoreRow>> getLiveEventScores(int id) async {
    final resp = await _dio.get('/events/$id/live-scores');
    final raw = resp.data;
    if (raw is! Map) return const [];
    final list = raw['scores'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => EventLiveScoreRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<EventLiveScoreRow>> storeLiveEventScore(
    int id, {
    required int userId,
    required double score,
    int stage = 1,
  }) async {
    final resp = await _dio.post(
      '/events/$id/live-scores',
      data: {
        'user_id': userId,
        'score': score,
        'stage': stage,
      },
    );
    final raw = Map<String, dynamic>.from(resp.data as Map);
    final list = raw['scores'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => EventLiveScoreRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CheckinDeskState> getCheckinDesk(int id) async {
    final resp = await _dio.get('/events/$id/checkin-desk');
    return CheckinDeskState.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<Map<String, dynamic>> toggleCheckinDesk(int id, {required bool open}) async {
    final resp = await _dio.post(
      '/events/$id/checkin-desk/toggle',
      data: {'open': open},
    );
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<Map<String, dynamic>> staffCheckin(int eventId, int userId) async {
    final resp = await _dio.post(
      '/events/$eventId/checkin-desk/check-in',
      data: {'user_id': userId},
    );
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<Map<String, dynamic>> undoStaffCheckin(int eventId, int userId) async {
    final resp = await _dio.delete('/events/$eventId/checkin-desk/$userId');
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<Map<String, dynamic>> endShootDay(int eventId) async {
    final resp = await _dio.post('/events/$eventId/checkin-desk/end-day');
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<ShootLiveState> getShootState(int shootId) async {
    final resp = await _dio.get('/shoots/$shootId/state');
    return ShootLiveState.fromJson(Map<String, dynamic>.from(resp.data as Map));
  }

  Future<ShootLiveState> advanceShoot(
    int shootId, {
    required String action,
  }) async {
    final resp = await _dio.post(
      '/shoots/$shootId/advance',
      data: {'action': action},
    );
    return _shootStateFromMutation(shootId, resp.data);
  }

  Future<Map<String, dynamic>> getShootDetail(int shootId) async {
    final resp = await _dio.get('/shoots/$shootId');
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<ShootLiveState> recordShootQuickAction(
    int shootId, {
    required int participantId,
    required int stageId,
    required String action,
  }) async {
    final resp = await _dio.post(
      '/shoots/$shootId/score/quick',
      data: {
        'participant_id': participantId,
        'stage_id': stageId,
        'action': action,
      },
    );
    return _shootStateFromMutation(shootId, resp.data);
  }

  Future<ShootLiveState> recordStageScore(
    int shootId, {
    required int participantId,
    required int stageId,
    required Map<String, dynamic> fields,
  }) async {
    final resp = await _dio.post(
      '/shoots/$shootId/score/stage',
      data: {
        'participant_id': participantId,
        'stage_id': stageId,
        ...fields,
      },
    );
    return _shootStateFromMutation(shootId, resp.data);
  }

  Future<ShootLiveState> beginStageTimeEntry(
    int shootId, {
    required int participantId,
    required int stageId,
  }) async {
    final resp = await _dio.post(
      '/shoots/$shootId/score/stage/time-entry',
      data: {
        'participant_id': participantId,
        'stage_id': stageId,
      },
    );
    return _shootStateFromMutation(shootId, resp.data);
  }

  Future<ShootLiveState> recordClayEvent(
    int shootId, {
    required int participantId,
    required int standId,
    required String result,
  }) async {
    final resp = await _dio.post(
      '/shoots/$shootId/score/clay',
      data: {
        'participant_id': participantId,
        'stand_id': standId,
        'result': result,
      },
    );
    return _shootStateFromMutation(shootId, resp.data);
  }

  Future<ShootLiveState> undoClayEvent(
    int shootId, {
    required int participantId,
    required int standId,
  }) async {
    final resp = await _dio.post(
      '/shoots/$shootId/score/undo-clay',
      data: {
        'participant_id': participantId,
        'stand_id': standId,
      },
    );
    return _shootStateFromMutation(shootId, resp.data);
  }

  Future<ShootLiveState> recordSimpleScore(
    int shootId, {
    required int participantId,
    required Map<String, dynamic> fields,
  }) async {
    final resp = await _dio.post(
      '/shoots/$shootId/score/simple',
      data: {
        'participant_id': participantId,
        ...fields,
      },
    );
    return _shootStateFromMutation(shootId, resp.data);
  }

  Future<ShootLiveState> relayAction(
    int shootId, {
    required String endpoint,
  }) async {
    final resp = await _dio.post('/shoots/$shootId/score/relay/$endpoint');
    return _shootStateFromMutation(shootId, resp.data);
  }

  Future<NotificationSummary> getNotificationSummary() async {
    try {
      final resp = await _dio.get('/notifications/summary');
      final body = _asMap(resp.data);
      if (body == null) {
        throw const FormatException('Notification summary was not a JSON object');
      }
      return NotificationSummary.fromJson(body);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return _emptyNotificationSummary;
      }
      rethrow;
    }
  }

  static const _emptyNotificationSummary = NotificationSummary(
    unreadNotifications: 0,
    unreadMessages: 0,
    pendingFriendRequests: 0,
    pendingGroupInvites: 0,
  );

  Future<List<AppNotification>> getNotifications({int page = 1}) async {
    try {
      final resp = await _dio.get(
        '/notifications',
        queryParameters: {'per_page': 25, 'page': page},
      );
      return _parseNotificationList(resp.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw InboxApiUnavailableException();
      }
      rethrow;
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _dio.post('/notifications/$notificationId/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.post('/notifications/read-all');
  }

  Future<void> deleteNotification(String notificationId) async {
    await _dio.delete('/notifications/$notificationId');
  }

  Future<void> clearReadNotifications() async {
    await _dio.post('/notifications/clear-read');
  }

  Future<void> markAllMessagesRead() async {
    await _dio.post('/notifications/messages/read-all');
  }

  Future<List<ConversationSummary>> getConversations() async {
    try {
      final resp = await _dio.get('/conversations');
      return _parseConversationList(resp.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw InboxApiUnavailableException();
      }
      rethrow;
    }
  }

  Future<({ConversationSummary conversation, List<ChatMessage> messages})>
      getConversation(int conversationId) async {
    try {
      final resp = await _dio.get('/conversations/$conversationId');
      final body = _asMap(resp.data);
      if (body == null) {
        throw const FormatException('Conversation response was not a JSON object');
      }

      final conversationRaw = body['conversation'];
      if (conversationRaw is! Map) {
        throw const FormatException('Conversation response missing conversation');
      }

      final conversation = ConversationSummary.fromJson(
        Map<String, dynamic>.from(conversationRaw),
      );
      final messages = _parseMessageList(body['messages']);
      return (conversation: conversation, messages: messages);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw InboxApiUnavailableException();
      }
      rethrow;
    }
  }

  Future<ChatMessage> sendConversationMessage(
    int conversationId, {
    required String body,
  }) async {
    final resp = await _dio.post(
      '/conversations/$conversationId/messages',
      data: {'body': body},
    );
    final payload = Map<String, dynamic>.from(resp.data as Map);
    return ChatMessage.fromJson(
      Map<String, dynamic>.from(payload['message'] as Map),
    );
  }

  Future<void> dismissStructuredLogReminder(int eventId) async {
    await _dio.post('/structured-shoot-log-reminders/$eventId/dismiss');
  }

  Future<List<StructuredLogReminder>> getStructuredLogReminders() async {
    final resp = await _dio.get('/structured-shoot-log-reminders');
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (item) => StructuredLogReminder.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> linkStructuredLogReminder({
    required int eventId,
    required int shootLogId,
  }) async {
    await _dio.post(
      '/structured-shoot-log-reminders/$eventId/link',
      data: {'shoot_log_id': shootLogId},
    );
  }

  Future<List<ClubListItem>> getMyClubs() async {
    final resp = await _dio.get('/clubs');
    final raw = resp.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => ClubListItem.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<ClubDetailModel> getClub(String slug) async {
    final resp = await _dio.get('/clubs/$slug');
    return ClubDetailModel.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<List<ClubLeagueModel>> getClubLeagues(String slug) async {
    final resp = await _dio.get('/clubs/$slug/leagues');
    final raw = resp.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (entry) => ClubLeagueModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<ClubLeagueStandingsModel> getClubLeagueStandings(
    String slug,
    int leagueId, {
    int? season,
    String? division,
    int? bestN,
  }) async {
    final resp = await _dio.get(
      '/clubs/$slug/leagues/$leagueId',
      queryParameters: {
        if (season != null) 'season': season,
        if (division != null && division.isNotEmpty) 'division': division,
        if (bestN != null) 'best_n': bestN,
      },
    );
    return ClubLeagueStandingsModel.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<void> joinClub(String slug) async {
    await _dio.post('/clubs/$slug/join');
  }

  Future<void> leaveClub(String slug) async {
    await _dio.delete('/clubs/$slug/leave');
  }

  Future<List<ClubMemberModel>> getClubMembers(
    String slug, {
    String status = 'active',
  }) async {
    final resp = await _dio.get(
      '/clubs/$slug/members',
      queryParameters: {'status': status},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => ClubMemberModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<ClubMemberModel> approveClubMember(String slug, int memberId) async {
    final resp = await _dio.post('/clubs/$slug/members/$memberId/approve');
    final body = Map<String, dynamic>.from(resp.data as Map);
    return ClubMemberModel.fromJson(
      Map<String, dynamic>.from(body['member'] as Map),
    );
  }

  Future<ClubMemberModel> changeClubMemberRole(
    String slug,
    int memberId,
    String role,
  ) async {
    final resp = await _dio.patch(
      '/clubs/$slug/members/$memberId/role',
      data: {'role': role},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    return ClubMemberModel.fromJson(
      Map<String, dynamic>.from(body['member'] as Map),
    );
  }

  Future<void> removeClubMember(String slug, int memberId) async {
    await _dio.delete('/clubs/$slug/members/$memberId');
  }

  Future<ClubMemberModel> inviteClubMember(String slug, String email) async {
    final resp = await _dio.post(
      '/clubs/$slug/members/invite',
      data: {'email': email},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    return ClubMemberModel.fromJson(
      Map<String, dynamic>.from(body['member'] as Map),
    );
  }

  Future<List<GroupListItem>> getMyGroups() async {
    final resp = await _dio.get('/groups');
    final raw = resp.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => GroupListItem.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<List<GroupInviteModel>> getGroupInvites() async {
    final resp = await _dio.get('/groups/invites');
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => GroupInviteModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<GroupDetailModel> getGroup(int groupId) async {
    final resp = await _dio.get('/groups/$groupId');
    return GroupDetailModel.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<List<GroupMemberModel>> getGroupMembers(
    int groupId, {
    String status = 'active',
  }) async {
    final resp = await _dio.get(
      '/groups/$groupId/members',
      queryParameters: {'status': status},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => GroupMemberModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<List<InviteableFriend>> getGroupInviteableFriends(int groupId) async {
    final resp = await _dio.get('/groups/$groupId/inviteable-friends');
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => InviteableFriend.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<GroupMemberModel> inviteGroupMember(int groupId, int userId) async {
    final resp = await _dio.post(
      '/groups/$groupId/members/invite',
      data: {'user_id': userId},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    return GroupMemberModel.fromJson(
      Map<String, dynamic>.from(body['member'] as Map),
    );
  }

  Future<GroupMemberModel> changeGroupMemberRole(
    int groupId,
    int memberId,
    String role,
  ) async {
    final resp = await _dio.patch(
      '/groups/$groupId/members/$memberId/role',
      data: {'role': role},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    return GroupMemberModel.fromJson(
      Map<String, dynamic>.from(body['member'] as Map),
    );
  }

  Future<void> removeGroupMember(int groupId, int memberId) async {
    await _dio.delete('/groups/$groupId/members/$memberId');
  }

  Future<void> leaveGroup(int groupId) async {
    await _dio.delete('/groups/$groupId/leave');
  }

  Future<int> acceptGroupInvite(int membershipId) async {
    final resp = await _dio.post('/groups/invites/$membershipId/accept');
    final body = Map<String, dynamic>.from(resp.data as Map);
    return body['group_id'] as int;
  }

  Future<void> declineGroupInvite(int membershipId) async {
    await _dio.post('/groups/invites/$membershipId/decline');
  }

  Future<GroupDetailModel> createGroup({
    required String name,
    String? description,
  }) async {
    final resp = await _dio.post(
      '/groups',
      data: {
        'name': name,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
    return GroupDetailModel.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<void> cancelGroupInvite(int groupId, int memberId) async {
    await _dio.delete('/groups/$groupId/members/$memberId/invite');
  }

  Future<GroupMemberModel> banGroupMember(int groupId, int memberId) async {
    final resp = await _dio.patch('/groups/$groupId/members/$memberId/ban');
    final body = Map<String, dynamic>.from(resp.data as Map);
    return GroupMemberModel.fromJson(
      Map<String, dynamic>.from(body['member'] as Map),
    );
  }

  Future<GroupMemberModel> unbanGroupMember(int groupId, int memberId) async {
    final resp = await _dio.patch('/groups/$groupId/members/$memberId/unban');
    final body = Map<String, dynamic>.from(resp.data as Map);
    return GroupMemberModel.fromJson(
      Map<String, dynamic>.from(body['member'] as Map),
    );
  }

  Future<void> transferGroupOwnership(int groupId, int memberId) async {
    await _dio.patch('/groups/$groupId/members/$memberId/transfer-ownership');
  }

  Future<List<GroupPostModel>> getGroupPosts(int groupId, {int page = 1}) async {
    final resp = await _dio.get(
      '/groups/$groupId/posts',
      queryParameters: {'page': page, 'per_page': 20},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => GroupPostModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<GroupPostModel> createGroupPost(
    int groupId, {
    required String title,
    String? body,
  }) async {
    final resp = await _dio.post(
      '/groups/$groupId/posts',
      data: {
        'title': title,
        if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
      },
    );
    return GroupPostModel.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<EventDetailModel> createGroupEvent(
    int groupId, {
    required String name,
    required String eventDate,
    String? startTime,
    String? endTime,
    String? location,
    String? description,
    String status = 'published',
  }) async {
    final resp = await _dio.post(
      '/groups/$groupId/events',
      data: {
        'name': name,
        'event_date': eventDate,
        if (startTime != null && startTime.isNotEmpty) 'start_time': startTime,
        if (endTime != null && endTime.isNotEmpty) 'end_time': endTime,
        if (location != null && location.trim().isNotEmpty)
          'location': location.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'status': status,
      },
    );
    return EventDetailModel.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<List<FriendshipModel>> getFriends({int page = 1}) async {
    final resp = await _dio.get(
      '/friends',
      queryParameters: {'page': page, 'per_page': 50},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => FriendshipModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<List<FriendshipModel>> getReceivedFriendRequests() async {
    final resp = await _dio.get('/friends/requests/received');
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => FriendshipModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<List<FriendshipModel>> getSentFriendRequests() async {
    final resp = await _dio.get('/friends/requests/sent');
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => FriendshipModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<List<FriendUserModel>> searchFriends(String query) async {
    final resp = await _dio.get(
      '/friends/search',
      queryParameters: {'q': query},
    );
    final body = Map<String, dynamic>.from(resp.data as Map);
    final list = body['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (entry) => FriendUserModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  Future<void> sendFriendRequest(int userId) async {
    await _dio.post('/friends/$userId/request');
  }

  Future<void> acceptFriendRequest(int friendshipId) async {
    await _dio.post('/friendships/$friendshipId/accept');
  }

  Future<void> declineFriendRequest(int friendshipId) async {
    await _dio.post('/friendships/$friendshipId/decline');
  }

  Future<void> removeFriend(int friendshipId) async {
    await _dio.delete('/friendships/$friendshipId');
  }

  Future<void> blockFriend(int userId) async {
    await _dio.post('/friends/$userId/block');
  }

  Future<void> unblockFriend(int userId) async {
    await _dio.post('/friends/$userId/unblock');
  }

  Future<ShootLiveState> _shootStateFromMutation(
    int shootId,
    Object? data,
  ) async {
    if (data is Map) {
      final body = Map<String, dynamic>.from(data);
      final state = body['state'];
      if (state is Map) {
        return ShootLiveState.fromJson(Map<String, dynamic>.from(state));
      }
    }
    return getShootState(shootId);
  }
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> _extractListMaps(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }
  final body = _asMap(raw);
  if (body == null) return const [];
  final data = body['data'];
  if (data is List) {
    return data
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }
  return const [];
}

List<AppNotification> _parseNotificationList(Object? raw) {
  final notifications = <AppNotification>[];
  for (final entry in _extractListMaps(raw)) {
    try {
      notifications.add(AppNotification.fromJson(entry));
    } catch (_) {}
  }
  return notifications;
}

List<ConversationSummary> _parseConversationList(Object? raw) {
  final conversations = <ConversationSummary>[];
  for (final entry in _extractListMaps(raw)) {
    try {
      conversations.add(ConversationSummary.fromJson(entry));
    } catch (_) {}
  }
  return conversations;
}

List<ChatMessage> _parseMessageList(Object? raw) {
  final messages = <ChatMessage>[];
  for (final entry in _extractListMaps(raw)) {
    try {
      messages.add(ChatMessage.fromJson(entry));
    } catch (_) {}
  }
  return messages;
}
