import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/models/ammo_load_model.dart';
import '../../shared/models/equipment_model.dart';
import '../../shared/models/event_model.dart';
import '../../shared/models/firearm_model.dart';
import '../../shared/models/shoot_session_model.dart';
import '../../shared/models/sync_payload.dart';
import '../../shared/models/user_model.dart';
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

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<UserModel> getUser() async {
    final resp = await _dio.get('/user');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
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
    final resp = await _dio.get('/events', queryParameters: {'limit': limit});
    final raw = resp.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => EventModel.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }
}
