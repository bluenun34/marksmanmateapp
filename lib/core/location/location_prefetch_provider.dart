import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/weather_service.dart';

/// Cached GPS fix prefetched at login and when the app returns to foreground.
class CachedLocation {
  const CachedLocation({
    required this.latitude,
    required this.longitude,
    required this.fetchedAt,
    this.placeLabel,
  });

  final double latitude;
  final double longitude;
  final DateTime fetchedAt;
  final String? placeLabel;

  bool get isFresh => DateTime.now().difference(fetchedAt).inMinutes < 30;
}

class LocationPrefetchNotifier extends Notifier<CachedLocation?> {
  bool _inFlight = false;

  @override
  CachedLocation? build() => null;

  /// Replace cache after the user explicitly captures GPS on the shoot log form.
  void updateCache(CachedLocation location) {
    state = location;
  }

  /// Quietly refresh GPS in the background. Keeps any previous cache on failure.
  Future<void> prefetch() async {
    if (_inFlight) return;
    final existing = state;
    if (existing != null && existing.isFresh) return;

    _inFlight = true;
    try {
      final service = WeatherService();
      final fix = await service.fetchCachedOrCurrentPosition();
      String? label;
      try {
        label = await service.reverseGeocode(fix.latitude, fix.longitude);
      } catch (_) {}

      state = CachedLocation(
        latitude: fix.latitude,
        longitude: fix.longitude,
        fetchedAt: DateTime.now(),
        placeLabel: label,
      );
    } catch (_) {
      // Leave existing cache unchanged.
    } finally {
      _inFlight = false;
    }
  }
}

final locationPrefetchProvider =
    NotifierProvider<LocationPrefetchNotifier, CachedLocation?>(
  LocationPrefetchNotifier.new,
);
