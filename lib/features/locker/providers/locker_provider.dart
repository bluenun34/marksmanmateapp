import 'dart:async';

import 'package:drift/drift.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/api_errors.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/user_access.dart';
import '../../../shared/models/ammo_load_model.dart';
import '../../../shared/models/equipment_model.dart';
import '../../../shared/models/firearm_model.dart';
import '../../../shared/models/sync_payload.dart';

class LockerState {
  const LockerState({
    this.firearms = const [],
    this.ammoLoads = const [],
    this.equipment = const [],
    this.isLoading = false,
    this.error,
  });

  final List<FirearmModel> firearms;
  final List<AmmoLoadModel> ammoLoads;
  final List<EquipmentModel> equipment;
  final bool isLoading;
  final String? error;

  LockerState copyWith({
    List<FirearmModel>? firearms,
    List<AmmoLoadModel>? ammoLoads,
    List<EquipmentModel>? equipment,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      LockerState(
        firearms: firearms ?? this.firearms,
        ammoLoads: ammoLoads ?? this.ammoLoads,
        equipment: equipment ?? this.equipment,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class LockerNotifier extends Notifier<LockerState> {
  int _loadGeneration = 0;

  @override
  LockerState build() {
    unawaited(_loadFromCache());
    return const LockerState();
  }

  AppDatabase get _db => ref.read(appDatabaseProvider);
  ApiService get _api => ref.read(apiServiceProvider);

  Future<void> _loadFromCache() async {
    final generation = ++_loadGeneration;
    try {
      final firearms = await _db.lockerDao
          .getAllFirearms()
          .timeout(const Duration(seconds: 3), onTimeout: () => []);
      final ammo = await _db.lockerDao
          .getAllAmmoLoads()
          .timeout(const Duration(seconds: 3), onTimeout: () => []);
      final equipment = await _db.lockerDao
          .getAllEquipment()
          .timeout(const Duration(seconds: 3), onTimeout: () => []);
      if (generation != _loadGeneration) return;

      if (firearms.isEmpty &&
          ammo.isEmpty &&
          equipment.isEmpty &&
          (state.firearms.isNotEmpty ||
              state.ammoLoads.isNotEmpty ||
              state.equipment.isNotEmpty)) {
        return;
      }

      state = state.copyWith(
        firearms: firearms
            .map((f) => FirearmModel(
                  id: f.id,
                  name: f.name,
                  make: f.make,
                  model: f.model,
                  calibre: f.calibre,
                  serialNumber: f.serialNumber,
                  notes: f.notes,
                ))
            .toList(),
        ammoLoads: ammo
            .map((a) => AmmoLoadModel(
                  id: a.id,
                  name: a.name,
                  calibre: a.calibre,
                  manufacturer: a.manufacturer,
                  bulletWeight: a.bulletWeight,
                  powderCharge: a.powderCharge,
                  notes: a.notes,
                ))
            .toList(),
        equipment: equipment
            .map((e) => EquipmentModel(
                  id: e.id,
                  name: e.name,
                  category: e.category,
                  brand: e.brand,
                  model: e.model,
                  firearmId: e.firearmId,
                  notes: e.notes,
                ))
            .toList(),
      );
    } catch (_) {}
  }

  Future<void> reloadFromCache() => _loadFromCache();

  void applyRemotePayload(SyncPayload payload) {
    ++_loadGeneration;
    final firearms =
        payload.firearms.map((json) => FirearmModel.fromJson(json)).toList();
    final ammo =
        payload.ammoLoads.map((json) => AmmoLoadModel.fromJson(json)).toList();
    final equipment = payload.equipment
        .map((json) => EquipmentModel.fromJson(json))
        .toList();

    state = state.copyWith(
      firearms: firearms,
      ammoLoads: ammo,
      equipment: equipment,
      isLoading: false,
      clearError: true,
    );

    unawaited(_cacheData(firearms, ammo, equipment));
  }

  Future<void> refresh() async {
    final generation = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final firearms = await _api.getFirearms()
          .timeout(const Duration(seconds: 15));
      final ammo = await _api.getAmmoLoads()
          .timeout(const Duration(seconds: 15));
      final equipment = await _api.getEquipment()
          .timeout(const Duration(seconds: 15));

      if (generation != _loadGeneration) return;

      state = state.copyWith(
        firearms: firearms,
        ammoLoads: ammo,
        equipment: equipment,
        isLoading: false,
      );

      unawaited(_cacheData(firearms, ammo, equipment));
    } catch (e) {
      if (generation != _loadGeneration) return;
      final message = e is DioException && e.response?.statusCode == 403
          ? mobileSyncInactiveMessage
          : 'Failed to sync locker: ${messageFromApiError(e)}';
      state = state.copyWith(
        isLoading: false,
        error: message,
      );
    }
  }

  Future<void> _cacheData(
    List<FirearmModel> firearms,
    List<AmmoLoadModel> ammo,
    List<EquipmentModel> equipment,
  ) async {
    try {
      await _db.lockerDao.replaceFirearms(firearms
          .map(
            (f) => CachedFirearmsCompanion.insert(
              id: Value(f.id),
              name: f.name,
              make: f.make ?? '',
              model: f.model ?? '',
              calibre: Value(f.calibre),
              serialNumber: Value(f.serialNumber),
              notes: Value(f.notes),
            ),
          )
          .toList());
      await _db.lockerDao.replaceAmmoLoads(ammo
          .map(
            (a) => CachedAmmoLoadsCompanion.insert(
              id: Value(a.id),
              name: a.name,
              calibre: a.calibre ?? '',
              manufacturer: Value(a.manufacturer),
              bulletWeight: Value(a.bulletWeight),
              powderCharge: Value(a.powderCharge),
              notes: Value(a.notes),
            ),
          )
          .toList());
      await _db.lockerDao.replaceEquipment(equipment
          .map(
            (e) => CachedEquipmentCompanion.insert(
              id: Value(e.id),
              name: e.name,
              category: Value(e.category),
              brand: Value(e.brand),
              model: Value(e.model),
              firearmId: Value(e.firearmId),
              notes: Value(e.notes),
            ),
          )
          .toList());
    } catch (_) {}
  }
}

final lockerProvider = NotifierProvider<LockerNotifier, LockerState>(
  LockerNotifier.new,
);
