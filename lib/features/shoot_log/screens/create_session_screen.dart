import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/database/app_database.dart';
import '../../../core/location/location_prefetch_provider.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/weather_service.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/sync/shoot_session_payload.dart';
import '../../../core/sync/sync_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/events/providers/events_provider.dart';
import '../../../features/locker/providers/locker_provider.dart';
import '../../../shared/models/ammo_load_model.dart';
import '../../../shared/models/firearm_model.dart';
import '../../../shared/models/equipment_model.dart';
import '../../../shared/shoot_log/shoot_log_constants.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/form_field_label.dart';
import '../data/session_draft_repository.dart';
import '../providers/shoot_log_provider.dart';
import '../widgets/form_step_indicator.dart';
import '../widgets/session_photo_picker.dart';
import '../widgets/voice_note_recorder.dart';
import '../../tools/services/target_analyzer_handoff.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({
    super.key,
    this.linkedEventId,
    this.initialGroupSize,
    this.initialGroupSizeUnit,
    this.initialHits,
    this.initialTargetType,
    this.initialDiscipline,
    this.initialLocation,
  });

  final int? linkedEventId;
  final double? initialGroupSize;
  final String? initialGroupSizeUnit;
  final int? initialHits;
  final String? initialTargetType;
  final String? initialDiscipline;
  final String? initialLocation;

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  static const _steps = [
    'Session',
    'Location',
    'Gear',
    'Results',
    'Finish',
  ];

  static const _stepHints = [
    'When did you shoot, and what kind of session was it?',
    'Range name and GPS help on the website — all optional here.',
    'Pick firearm, ammo, and kit from your locker if you like.',
    'Scores, grouping, and photos of your target.',
    'Rate the session, add weather and notes, then save.',
  ];

  static const _stepBanners = [
    'Only date, discipline, and session type are required. Tap Continue when ready.',
    'Skip this step entirely if you are logging quickly at the range.',
    'Your locker syncs from the website when you are online.',
    'Enter what you know — leave blank anything you did not record.',
    'Weather is filled from GPS when possible. Everything here is optional.',
  ];

  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String? _visibilityOverride;
  String _discipline = 'rifle';
  String _sessionType = 'practice';
  final _rangeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _venueType = 'outdoor';
  String? _lighting;
  final _laneBayCtrl = TextEditingController();
  final _roundsCtrl = TextEditingController();
  final _hitsCtrl = TextEditingController();
  final _missesCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  String _distanceUnit = 'metres';
  final _targetTypeCtrl = TextEditingController();
  final _stageNameCtrl = TextEditingController();
  final _groupSizeCtrl = TextEditingController();
  String _groupSizeUnit = 'mm';
  int _rating = 0;
  final _notesCtrl = TextEditingController();
  bool _fetchingWeather = false;
  final _weatherCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _windSpeedCtrl = TextEditingController();
  final _windDirCtrl = TextEditingController();
  final _humidityCtrl = TextEditingController();
  final _pressureCtrl = TextEditingController();
  final _windGustCtrl = TextEditingController();
  final _cloudCoverCtrl = TextEditingController();
  final _precipCtrl = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _capturingLocation = false;
  int? _firearmId;
  int? _ammoLoadId;
  final Set<int> _equipmentIds = {};
  final Map<String, String> _disciplineData = {};
  final List<SessionPhotoDraft> _targetPhotos = [];
  final List<SessionPhotoDraft> _sessionPhotos = [];
  bool _submitting = false;
  String? _voiceNotePath;
  final _draftRepo = SessionDraftRepository();
  var _draftChecked = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialGroupSize != null) {
      _groupSizeCtrl.text = widget.initialGroupSize!.toStringAsFixed(1);
    }
    if (widget.initialGroupSizeUnit != null &&
        ShootLogConstants.groupSizeUnits
            .contains(widget.initialGroupSizeUnit)) {
      _groupSizeUnit = widget.initialGroupSizeUnit!;
    }
    if (widget.initialHits != null) {
      _hitsCtrl.text = widget.initialHits.toString();
    }
    if (widget.initialTargetType != null &&
        widget.initialTargetType!.trim().isNotEmpty) {
      _targetTypeCtrl.text = widget.initialTargetType!.trim();
    }
    if (widget.initialDiscipline != null &&
        ShootLogConstants.disciplines.containsKey(widget.initialDiscipline)) {
      _discipline = widget.initialDiscipline!;
    }
    if (widget.initialLocation != null &&
        widget.initialLocation!.trim().isNotEmpty) {
      _locationCtrl.text = Uri.decodeComponent(widget.initialLocation!.trim());
    }
    if (widget.initialGroupSize != null || widget.initialHits != null) {
      _currentStep = 3;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = ref.read(appPreferencesProvider);
      final distanceUnit = await prefs.distanceUnit();
      final groupUnit = await prefs.groupSizeUnit();
      if (mounted &&
          widget.initialGroupSizeUnit == null &&
          ShootLogConstants.distanceUnits.contains(distanceUnit)) {
        setState(() => _distanceUnit = distanceUnit);
      }
      if (mounted &&
          widget.initialGroupSizeUnit == null &&
          ShootLogConstants.groupSizeUnits.contains(groupUnit)) {
        setState(() => _groupSizeUnit = groupUnit);
      }
      await _prefillFromLinkedEvent();
      if (!mounted) return;

      final handoffPhoto = TargetAnalyzerHandoff.takeTargetPhoto();
      if (handoffPhoto != null && mounted) {
        setState(() {
          _targetPhotos
            ..clear()
            ..add(handoffPhoto);
        });
      }
      if (widget.initialGroupSize != null || widget.initialHits != null) {
        _pageController.jumpToPage(3);
      }
      final locker = ref.read(lockerProvider);
      if (ref.read(isOnlineProvider) &&
          ref.read(authStateProvider).canUseApp &&
          locker.firearms.isEmpty &&
          locker.ammoLoads.isEmpty &&
          !locker.isLoading) {
        ref.read(lockerProvider.notifier).refresh();
      }
      _applyCachedLocation(ref.read(locationPrefetchProvider));
      unawaited(ref.read(locationPrefetchProvider.notifier).prefetch());
      await _maybeRestoreDraft();
    });
    for (final field
        in ShootLogConstants.disciplineFields[_discipline] ?? const []) {
      _disciplineData[field.name] = '';
    }
  }

  DateTime get _occurredAt => DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

  Future<void> _prefillFromLinkedEvent() async {
    final eventId = widget.linkedEventId;
    if (eventId == null || !ref.read(isOnlineProvider)) return;
    try {
      final detail = await ref.read(apiServiceProvider).getEvent(eventId);
      if (!mounted) return;
      setState(() {
        if (detail.discipline?.key != null &&
            ShootLogConstants.disciplines.containsKey(detail.discipline!.key)) {
          _discipline = detail.discipline!.key;
        }
        if (detail.location?.isNotEmpty == true &&
            _locationCtrl.text.trim().isEmpty) {
          _locationCtrl.text = detail.location!;
        }
        if (detail.club?.name != null && _rangeCtrl.text.trim().isEmpty) {
          _rangeCtrl.text = detail.club!.name;
        }
        if (detail.eventDate != null) {
          _date = detail.eventDate!;
        }
        if (detail.startTime != null) {
          final parts = detail.startTime!.split(':');
          if (parts.length >= 2) {
            final h = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            if (h != null && m != null) {
              _time = TimeOfDay(hour: h, minute: m);
            }
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rangeCtrl.dispose();
    _locationCtrl.dispose();
    _laneBayCtrl.dispose();
    _roundsCtrl.dispose();
    _hitsCtrl.dispose();
    _missesCtrl.dispose();
    _scoreCtrl.dispose();
    _distanceCtrl.dispose();
    _targetTypeCtrl.dispose();
    _stageNameCtrl.dispose();
    _groupSizeCtrl.dispose();
    _notesCtrl.dispose();
    _weatherCtrl.dispose();
    _tempCtrl.dispose();
    _windSpeedCtrl.dispose();
    _windDirCtrl.dispose();
    _humidityCtrl.dispose();
    _pressureCtrl.dispose();
    _windGustCtrl.dispose();
    _cloudCoverCtrl.dispose();
    _precipCtrl.dispose();
    super.dispose();
  }

  void _onDisciplineChanged(String value) {
    setState(() {
      _discipline = value;
      _disciplineData.clear();
      for (final field
          in ShootLogConstants.disciplineFields[value] ?? const []) {
        _disciplineData[field.name] = '';
      }
    });
  }

  void _autoCalcMisses() {
    final rounds = int.tryParse(_roundsCtrl.text);
    final hits = int.tryParse(_hitsCtrl.text);
    if (rounds == null || hits == null || rounds < hits) return;
    _missesCtrl.text = (rounds - hits).toString();
  }

  String? _nonNegativeInt(String? value, {String label = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null) return '$label must be a whole number';
    if (parsed < 0) return '$label cannot be negative';
    return null;
  }

  String? _optionalDouble(String? value, {String label = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value) == null) return '$label must be a number';
    return null;
  }

  String? _validateHitsMisses(String? _) {
    final rounds = int.tryParse(_roundsCtrl.text);
    final hits = int.tryParse(_hitsCtrl.text);
    final misses = int.tryParse(_missesCtrl.text);
    if (rounds != null && hits != null && misses != null) {
      if (hits + misses > rounds) {
        return 'Hits and misses cannot exceed rounds fired';
      }
    }
    return null;
  }

  Map<String, dynamic> _buildDisciplineData() {
    final data = <String, dynamic>{};
    for (final field
        in ShootLogConstants.disciplineFields[_discipline] ?? const []) {
      final value = _disciplineData[field.name]?.trim() ?? '';
      if (value.isEmpty) continue;
      data[field.name] = field.type == DisciplineFieldType.number
          ? num.tryParse(value) ?? value
          : value;
    }
    if (_venueType == 'indoor') {
      if (_lighting != null && _lighting!.isNotEmpty) {
        data['lighting'] = _lighting;
      }
      final lane = _laneBayCtrl.text.trim();
      if (lane.isNotEmpty) data['lane_bay'] = lane;
    }
    if (_venueType == 'outdoor') {
      final gust = double.tryParse(_windGustCtrl.text);
      if (gust != null) data['weather_wind_gust_kmh'] = gust;
      final cloud = double.tryParse(_cloudCoverCtrl.text);
      if (cloud != null) data['weather_cloud_cover_pct'] = cloud.round();
      final precip = double.tryParse(_precipCtrl.text);
      if (precip != null) data['weather_precipitation_mm'] = precip;
    }
    return data;
  }

  void _applyCachedLocation(CachedLocation? cached) {
    if (cached == null) return;
    setState(() {
      if (_latitude == null) {
        _latitude = cached.latitude;
        _longitude = cached.longitude;
      }
      if (_locationCtrl.text.trim().isEmpty &&
          cached.placeLabel != null &&
          cached.placeLabel!.isNotEmpty) {
        _locationCtrl.text = cached.placeLabel!;
      }
    });
  }

  void _applyWeatherData(WeatherData weather) {
    setState(() {
      _latitude = weather.latitude;
      _longitude = weather.longitude;
      _weatherCtrl.text = weather.condition;
      _tempCtrl.text = weather.temperature.toStringAsFixed(1);
      _windSpeedCtrl.text = weather.windSpeed.toStringAsFixed(1);
      _windDirCtrl.text =
          '${weather.windDirection} (${weather.windDirectionDegrees}°)';
      _humidityCtrl.text = weather.humidity.toStringAsFixed(0);
      _pressureCtrl.text = weather.pressure.toStringAsFixed(0);
      if (weather.windGust != null) {
        _windGustCtrl.text = weather.windGust!.toStringAsFixed(1);
      }
      if (weather.cloudCover != null) {
        _cloudCoverCtrl.text = weather.cloudCover!.toStringAsFixed(0);
      }
      if (weather.precipitation != null) {
        _precipCtrl.text = weather.precipitation!.toStringAsFixed(1);
      }
    });
  }

  bool get _weatherFieldsEmpty =>
      _weatherCtrl.text.trim().isEmpty &&
      _tempCtrl.text.trim().isEmpty &&
      _windSpeedCtrl.text.trim().isEmpty;

  Future<void> _addPhoto(
    ImageSource source,
    List<SessionPhotoDraft> list,
    int max,
  ) async {
    if (list.length >= max) return;
    final draft = await pickSessionPhoto(source);
    if (draft == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo not added — try a smaller image')),
        );
      }
      return;
    }
    setState(() => list.add(draft));
  }

  Future<void> _fetchWeather() async {
    setState(() => _fetchingWeather = true);
    try {
      final service = WeatherService();
      final WeatherData weather;
      if (_latitude != null && _longitude != null) {
        weather = await service
            .fetchWeatherAt(_latitude!, _longitude!)
            .timeout(const Duration(seconds: 15));
      } else {
        final cached = ref.read(locationPrefetchProvider);
        if (cached != null) {
          weather = await service
              .fetchWeatherAt(cached.latitude, cached.longitude)
              .timeout(const Duration(seconds: 15));
        } else {
          weather = await service
              .fetchCurrentWeather()
              .timeout(const Duration(seconds: 15));
        }
      }
      _applyWeatherData(weather);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get weather: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingWeather = false);
    }
  }

  Future<void> _captureGps() async {
    setState(() => _capturingLocation = true);
    try {
      final service = WeatherService();
      final fix = await service
          .fetchCachedOrCurrentPosition()
          .timeout(const Duration(seconds: 10));
      String? label;
      try {
        label = await service.reverseGeocode(fix.latitude, fix.longitude);
      } catch (_) {}
      setState(() {
        _latitude = fix.latitude;
        _longitude = fix.longitude;
        if (label != null &&
            label.isNotEmpty &&
            _locationCtrl.text.trim().isEmpty) {
          _locationCtrl.text = label;
        }
      });
      ref.read(locationPrefetchProvider.notifier).updateCache(
            CachedLocation(
              latitude: fix.latitude,
              longitude: fix.longitude,
              fetchedAt: DateTime.now(),
              placeLabel: label,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              label != null && label.isNotEmpty
                  ? 'Location saved: $label'
                  : 'Location saved (${fix.latitude.toStringAsFixed(5)}, ${fix.longitude.toStringAsFixed(5)})',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get GPS: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturingLocation = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  List<FirearmModel> _filteredFirearms(List<FirearmModel> firearms) {
    if (_ammoLoadId == null) return firearms;
    final ammo = ref
        .read(lockerProvider)
        .ammoLoads
        .where((a) => a.id == _ammoLoadId)
        .firstOrNull;
    if (ammo?.calibre == null || ammo!.calibre!.isEmpty) return firearms;
    return firearms
        .where((f) => f.calibre == null || f.calibre == ammo.calibre)
        .toList();
  }

  List<AmmoLoadModel> _filteredAmmo(List<AmmoLoadModel> ammoLoads) {
    if (_firearmId == null) return ammoLoads;
    final firearm = ref
        .read(lockerProvider)
        .firearms
        .where((f) => f.id == _firearmId)
        .firstOrNull;
    if (firearm?.calibre == null || firearm!.calibre!.isEmpty) {
      return ammoLoads;
    }
    return ammoLoads
        .where((a) => a.calibre == null || a.calibre == firearm.calibre)
        .toList();
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) return true;
    return _formKey.currentState?.validate() ?? true;
  }

  void _goToStep(int step) {
    if (step > _currentStep && !_validateCurrentStep()) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    if (step == 4 &&
        _venueType == 'outdoor' &&
        _weatherFieldsEmpty &&
        !_fetchingWeather &&
        (_latitude != null || ref.read(locationPrefetchProvider) != null)) {
      unawaited(_fetchWeather());
    }
  }

  Future<void> _maybeRestoreDraft() async {
    if (_draftChecked ||
        widget.initialGroupSize != null ||
        widget.initialHits != null) {
      return;
    }
    _draftChecked = true;
    final draft = await _draftRepo.loadDraft();
    if (draft == null || !mounted) return;

    final restore = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resume draft?'),
        content: const Text(
          'You have an unfinished session draft. Would you like to continue where you left off?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Start fresh'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Resume draft'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (restore == true) {
      _applyDraft(draft);
    } else {
      await _draftRepo.clearDraft();
    }
  }

  Map<String, dynamic> _currentDraft() {
    return serializeSessionDraft(
      currentStep: _currentStep,
      date: _date,
      discipline: _discipline,
      sessionType: _sessionType,
      venueType: _venueType,
      lighting: _lighting,
      range: _rangeCtrl.text,
      location: _locationCtrl.text,
      laneBay: _laneBayCtrl.text,
      rounds: _roundsCtrl.text,
      hits: _hitsCtrl.text,
      misses: _missesCtrl.text,
      score: _scoreCtrl.text,
      distance: _distanceCtrl.text,
      distanceUnit: _distanceUnit,
      targetType: _targetTypeCtrl.text,
      stageName: _stageNameCtrl.text,
      groupSize: _groupSizeCtrl.text,
      groupSizeUnit: _groupSizeUnit,
      rating: _rating,
      notes: _notesCtrl.text,
      weather: _weatherCtrl.text,
      temp: _tempCtrl.text,
      windSpeed: _windSpeedCtrl.text,
      windDir: _windDirCtrl.text,
      humidity: _humidityCtrl.text,
      pressure: _pressureCtrl.text,
      windGust: _windGustCtrl.text,
      cloudCover: _cloudCoverCtrl.text,
      precip: _precipCtrl.text,
      latitude: _latitude,
      longitude: _longitude,
      firearmId: _firearmId,
      ammoLoadId: _ammoLoadId,
      equipmentIds: _equipmentIds.toList(),
      disciplineData: Map<String, String>.from(_disciplineData),
      voiceNotePath: _voiceNotePath,
      linkedEventId: widget.linkedEventId,
    );
  }

  void _applyDraft(Map<String, dynamic> draft) {
    setState(() {
      _currentStep = draft['currentStep'] as int? ?? 0;
      _date = DateTime.tryParse(draft['date'] as String? ?? '') ?? DateTime.now();
      _discipline = draft['discipline'] as String? ?? 'rifle';
      _sessionType = draft['sessionType'] as String? ?? 'practice';
      _venueType = draft['venueType'] as String? ?? 'outdoor';
      _lighting = draft['lighting'] as String?;
      _rangeCtrl.text = draft['range'] as String? ?? '';
      _locationCtrl.text = draft['location'] as String? ?? '';
      _laneBayCtrl.text = draft['laneBay'] as String? ?? '';
      _roundsCtrl.text = draft['rounds'] as String? ?? '';
      _hitsCtrl.text = draft['hits'] as String? ?? '';
      _missesCtrl.text = draft['misses'] as String? ?? '';
      _scoreCtrl.text = draft['score'] as String? ?? '';
      _distanceCtrl.text = draft['distance'] as String? ?? '';
      _distanceUnit = draft['distanceUnit'] as String? ?? 'metres';
      _targetTypeCtrl.text = draft['targetType'] as String? ?? '';
      _stageNameCtrl.text = draft['stageName'] as String? ?? '';
      _groupSizeCtrl.text = draft['groupSize'] as String? ?? '';
      _groupSizeUnit = draft['groupSizeUnit'] as String? ?? 'mm';
      _rating = draft['rating'] as int? ?? 0;
      _notesCtrl.text = draft['notes'] as String? ?? '';
      _weatherCtrl.text = draft['weather'] as String? ?? '';
      _tempCtrl.text = draft['temp'] as String? ?? '';
      _windSpeedCtrl.text = draft['windSpeed'] as String? ?? '';
      _windDirCtrl.text = draft['windDir'] as String? ?? '';
      _humidityCtrl.text = draft['humidity'] as String? ?? '';
      _pressureCtrl.text = draft['pressure'] as String? ?? '';
      _windGustCtrl.text = draft['windGust'] as String? ?? '';
      _cloudCoverCtrl.text = draft['cloudCover'] as String? ?? '';
      _precipCtrl.text = draft['precip'] as String? ?? '';
      _latitude = (draft['latitude'] as num?)?.toDouble();
      _longitude = (draft['longitude'] as num?)?.toDouble();
      _firearmId = draft['firearmId'] as int?;
      _ammoLoadId = draft['ammoLoadId'] as int?;
      _equipmentIds
        ..clear()
        ..addAll(
          (draft['equipmentIds'] as List<dynamic>? ?? const [])
              .whereType<int>(),
        );
      _disciplineData
        ..clear()
        ..addAll(
          Map<String, String>.from(
            (draft['disciplineData'] as Map<dynamic, dynamic>? ?? const {})
                .map((key, value) => MapEntry('$key', '$value')),
          ),
        );
      _voiceNotePath = draft['voiceNotePath'] as String?;
    });
    _pageController.jumpToPage(_currentStep.clamp(0, _steps.length - 1));
  }

  Future<void> _saveDraft() async {
    await _draftRepo.saveDraft(_currentDraft());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved — resume anytime from Shoot Log')),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _goToStep(3);
      return;
    }
    setState(() => _submitting = true);
    try {
      final disciplineData = _buildDisciplineData();
      final companion = ShootSessionsCompanion.insert(
        date: _occurredAt,
        discipline: _discipline,
        sessionType: _sessionType,
        eventId: Value(widget.linkedEventId),
        rangeName: Value(_rangeCtrl.text.trim().isNotEmpty
            ? _rangeCtrl.text.trim()
            : null),
        venueType: Value(_venueType),
        location: Value(_locationCtrl.text.trim().isNotEmpty
            ? _locationCtrl.text.trim()
            : null),
        latitude: Value(_latitude),
        longitude: Value(_longitude),
        firearmId: Value(_firearmId),
        ammoLoadId: Value(_ammoLoadId),
        equipmentIds: Value(
          _equipmentIds.isEmpty
              ? null
              : encodeEquipmentIds(_equipmentIds.toList()),
        ),
        totalRounds: Value(int.tryParse(_roundsCtrl.text)),
        totalHits: Value(int.tryParse(_hitsCtrl.text)),
        totalMisses: Value(int.tryParse(_missesCtrl.text)),
        totalScore: Value(double.tryParse(_scoreCtrl.text)),
        rating: Value(_rating > 0 ? _rating : null),
        notes: Value(
          _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        ),
        weatherCondition: Value(
          _venueType == 'outdoor' && _weatherCtrl.text.trim().isNotEmpty
              ? _weatherCtrl.text.trim()
              : null,
        ),
        temperature: Value(
          _venueType == 'outdoor' ? double.tryParse(_tempCtrl.text) : null,
        ),
        windSpeed: Value(
          _venueType == 'outdoor'
              ? double.tryParse(_windSpeedCtrl.text)
              : null,
        ),
        windDirection: Value(
          _venueType == 'outdoor' && _windDirCtrl.text.trim().isNotEmpty
              ? _windDirCtrl.text.trim()
              : null,
        ),
        humidity: Value(
          _venueType == 'outdoor' ? double.tryParse(_humidityCtrl.text) : null,
        ),
        pressure: Value(
          _venueType == 'outdoor' ? double.tryParse(_pressureCtrl.text) : null,
        ),
        voiceNotePath: Value(_voiceNotePath),
      );

      final payload = buildShootSessionPayload(
        date: _occurredAt,
        discipline: _discipline,
        sessionType: _sessionType,
        rangeName:
            _rangeCtrl.text.trim().isNotEmpty ? _rangeCtrl.text.trim() : null,
        venueType: _venueType,
        location: _locationCtrl.text.trim().isNotEmpty
            ? _locationCtrl.text.trim()
            : null,
        latitude: _latitude,
        longitude: _longitude,
        firearmId: _firearmId,
        ammoLoadId: _ammoLoadId,
        equipmentIds: _equipmentIds.toList(),
        totalRounds: int.tryParse(_roundsCtrl.text),
        totalHits: int.tryParse(_hitsCtrl.text),
        totalMisses: int.tryParse(_missesCtrl.text),
        totalScore: double.tryParse(_scoreCtrl.text),
        rating: _rating > 0 ? _rating : null,
        notes:
            _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        weatherCondition: _venueType == 'outdoor' &&
                _weatherCtrl.text.trim().isNotEmpty
            ? _weatherCtrl.text.trim()
            : null,
        temperature:
            _venueType == 'outdoor' ? double.tryParse(_tempCtrl.text) : null,
        windSpeed: _venueType == 'outdoor'
            ? double.tryParse(_windSpeedCtrl.text)
            : null,
        windDirection: _venueType == 'outdoor' &&
                _windDirCtrl.text.trim().isNotEmpty
            ? _windDirCtrl.text.trim()
            : null,
        humidity:
            _venueType == 'outdoor' ? double.tryParse(_humidityCtrl.text) : null,
        pressure:
            _venueType == 'outdoor' ? double.tryParse(_pressureCtrl.text) : null,
        disciplineData: disciplineData.isEmpty ? null : disciplineData,
        distance: double.tryParse(_distanceCtrl.text),
        distanceUnit: _distanceUnit,
        targetType: _targetTypeCtrl.text.trim().isNotEmpty
            ? _targetTypeCtrl.text.trim()
            : null,
        stageName: _stageNameCtrl.text.trim().isNotEmpty
            ? _stageNameCtrl.text.trim()
            : null,
        groupSize: double.tryParse(_groupSizeCtrl.text),
        groupSizeUnit: _groupSizeUnit,
        eventId: widget.linkedEventId,
        visibilityOverride: _visibilityOverride,
      );

      final outcome = await ref.read(shootLogProvider.notifier).createSession(
            companion,
            payload,
            targetPhotos: _targetPhotos.map((p) => p.file).toList(),
            sessionPhotos: _sessionPhotos.map((p) => p.file).toList(),
          );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      final message = switch (outcome.result) {
        SessionSaveResult.synced => 'Session saved and synced',
        SessionSaveResult.syncedPhotosPending =>
          outcome.detail ?? 'Session saved — some photos may need retry',
        SessionSaveResult.savedOffline =>
          'Session saved offline — it will sync when you are back online',
        SessionSaveResult.savedOfflineAfterApiFailure =>
          'Could not reach the server — session saved offline for later sync',
        SessionSaveResult.savedOfflinePhotosSkipped =>
          outcome.detail ?? 'Save without photos or try again when online',
        SessionSaveResult.failed =>
          'Could not save session — please try again',
      };

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(
            seconds: outcome.result == SessionSaveResult.failed ? 4 : 3,
          ),
        ),
      );

      if (outcome.result != SessionSaveResult.failed &&
          outcome.result != SessionSaveResult.savedOfflinePhotosSkipped) {
        if (widget.linkedEventId != null) {
          ref.invalidate(structuredLogRemindersProvider);
        }
        await _draftRepo.clearDraft();
        if (!mounted) return;
        context.go('/shoot-log');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.listen<CachedLocation?>(locationPrefetchProvider, (previous, next) {
      _applyCachedLocation(next);
    });
    final cachedLocation = ref.watch(locationPrefetchProvider);
    final locker = ref.watch(lockerProvider);
    final fieldEquipment =
        locker.equipment.where((item) => item.isFieldUsable).toList();
    final filteredFirearms = _filteredFirearms(locker.firearms);
    final filteredAmmo = _filteredAmmo(locker.ammoLoads);
    final disciplineFields =
        ShootLogConstants.disciplineFields[_discipline] ?? const [];
    final isLastStep = _currentStep == _steps.length - 1;
    final continueLabel = switch (_currentStep) {
      0 => 'Continue to location',
      1 => 'Continue to gear',
      2 => 'Continue to results',
      3 => 'Continue to finish',
      _ => 'Continue',
    };

    return Scaffold(
      appBar: AppScreenAppBar.back(
        context,
        title: 'New Session',
        fallbackRoute: '/shoot-log',
        leadingIcon: Icons.close_rounded,
        leadingLabel: 'Close',
        actions: [
          TextButton(
            onPressed: _submitting ? null : _saveDraft,
            child: const Text('Save draft'),
          ),
        ],
      ),
      body: Column(
        children: [
          FormStepIndicator(
            steps: _steps,
            currentStep: _currentStep,
            stepHints: _stepHints,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildSessionStep(theme),
                  _buildLocationStep(theme, cachedLocation),
                  _buildGearStep(
                    theme,
                    locker,
                    fieldEquipment,
                    filteredFirearms,
                    filteredAmmo,
                    disciplineFields,
                  ),
                  _buildResultsStep(theme),
                  _buildFinishStep(theme),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => _goToStep(_currentStep - 1),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _submitting
                        ? null
                        : isLastStep
                            ? _submit
                            : () => _goToStep(_currentStep + 1),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isLastStep
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                    label: Text(isLastStep ? 'Save session' : continueLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStep(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.linkedEventId != null)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.event_rounded),
              title: const Text('Linked to website event'),
              subtitle: Text('Event #${widget.linkedEventId}'),
            ),
          ),
        GuidedStepBanner(message: _stepBanners[0]),
        const FormRequirementLegend(),
        const SizedBox(height: 16),
        FormSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormSectionHeader(
                title: 'When & what',
                subtitle: 'These three fields are required for every session.',
                requirement: FieldRequirement.required,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: fieldDecoration(
                    label: 'Date',
                    requirement: FieldRequirement.required,
                    prefixIcon: Icons.calendar_today_outlined,
                  ),
                  child: Text(
                    '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: fieldDecoration(
                    label: 'Time',
                    requirement: FieldRequirement.optional,
                    prefixIcon: Icons.schedule_outlined,
                  ),
                  child: Text(
                    '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _discipline,
                decoration: fieldDecoration(
                  label: 'Discipline',
                  requirement: FieldRequirement.required,
                  prefixIcon: Icons.my_location_rounded,
                ),
                items: ShootLogConstants.disciplines.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => _onDisciplineChanged(v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _sessionType,
                decoration: fieldDecoration(
                  label: 'Session type',
                  requirement: FieldRequirement.required,
                  prefixIcon: Icons.category_outlined,
                ),
                items: ShootLogConstants.sessionTypes.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _sessionType = v!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStep(ThemeData theme, CachedLocation? cachedLocation) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GuidedStepBanner(
          message: _stepBanners[1],
          icon: Icons.place_outlined,
        ),
        FormSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormSectionHeader(
                title: 'Range & venue',
                requirement: FieldRequirement.optional,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rangeCtrl,
                decoration: fieldDecoration(
                  label: 'Range name',
                  prefixIcon: Icons.location_city_outlined,
                  hintText: 'e.g. Bisley, Diggle, club range…',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Venue type',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'outdoor', label: Text('Outdoor')),
                  ButtonSegment(value: 'indoor', label: Text('Indoor')),
                ],
                selected: {_venueType},
                onSelectionChanged: (value) =>
                    setState(() => _venueType = value.first),
              ),
              if (_venueType == 'indoor') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: _lighting,
                  decoration: fieldDecoration(label: 'Lighting'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('— Select —'),
                    ),
                    ...ShootLogConstants.indoorLightingOptions.map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          ShootLogConstants.indoorLightingLabels[value] ??
                              value,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _lighting = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _laneBayCtrl,
                  decoration: fieldDecoration(
                    label: 'Lane / bay',
                    hintText: 'e.g. Lane 3',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: fieldDecoration(
                  label: 'Location label',
                  prefixIcon: Icons.location_on_outlined,
                  hintText: 'e.g. Bisley Range, Surrey…',
                ),
              ),
              const SizedBox(height: 16),
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: Icon(
                        Icons.gps_fixed_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                )
              else if (cachedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'GPS warming up — tap below if needed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _capturingLocation ? null : _captureGps,
                  icon: _capturingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    _latitude == null
                        ? 'Use GPS for coordinates'
                        : 'GPS saved — recapture',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildGearStep(
    ThemeData theme,
    LockerState locker,
    List<EquipmentModel> fieldEquipment,
    List<FirearmModel> filteredFirearms,
    List<AmmoLoadModel> filteredAmmo,
    List<DisciplineFieldDef> disciplineFields,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GuidedStepBanner(
          message: _stepBanners[2],
          icon: Icons.build_outlined,
        ),
        FormSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormSectionHeader(
                title: 'Gear',
                subtitle: 'Pick firearm, ammo, and equipment from your locker.',
                requirement: FieldRequirement.optional,
              ),
              const SizedBox(height: 16),
              if (locker.firearms.isEmpty &&
                  locker.ammoLoads.isEmpty &&
                  fieldEquipment.isEmpty)
                Text(
                  'Sync your locker first to pick firearms, ammo, and equipment.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else ...[
                DropdownButtonFormField<int?>(
                  value: filteredFirearms.any((f) => f.id == _firearmId)
                      ? _firearmId
                      : null,
                  decoration: fieldDecoration(
                    label: 'Firearm',
                    prefixIcon: Icons.settings_outlined,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('— Select firearm —'),
                    ),
                    ...filteredFirearms.map(
                      (f) => DropdownMenuItem<int?>(
                        value: f.id,
                        child: Text(f.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _firearmId = value;
                    if (value != null && _ammoLoadId != null) {
                      final ammo = locker.ammoLoads
                          .where((a) => a.id == _ammoLoadId)
                          .firstOrNull;
                      final firearm = locker.firearms
                          .where((f) => f.id == value)
                          .firstOrNull;
                      if (ammo != null &&
                          firearm?.calibre != null &&
                          ammo.calibre != firearm!.calibre) {
                        _ammoLoadId = null;
                      }
                    }
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: filteredAmmo.any((a) => a.id == _ammoLoadId)
                      ? _ammoLoadId
                      : null,
                  decoration: fieldDecoration(
                    label: 'Ammo load',
                    prefixIcon: Icons.linear_scale_rounded,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('— None / Unknown —'),
                    ),
                    ...filteredAmmo.map(
                      (a) => DropdownMenuItem<int?>(
                        value: a.id,
                        child: Text(a.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _ammoLoadId = value;
                    if (value != null && _firearmId != null) {
                      final firearm = locker.firearms
                          .where((f) => f.id == _firearmId)
                          .firstOrNull;
                      final ammo = locker.ammoLoads
                          .where((a) => a.id == value)
                          .firstOrNull;
                      if (firearm != null &&
                          ammo?.calibre != null &&
                          firearm.calibre != ammo!.calibre) {
                        _firearmId = null;
                      }
                    }
                  }),
                ),
                if (fieldEquipment.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Equipment', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: fieldEquipment.map<Widget>((item) {
                      final selected = _equipmentIds.contains(item.id);
                      return FilterChip(
                        label: Text(item.name),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _equipmentIds.add(item.id);
                            } else {
                              _equipmentIds.remove(item.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
              if (disciplineFields.isNotEmpty) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    '${ShootLogConstants.disciplines[_discipline]} details',
                  ),
                  subtitle: const Text('Optional discipline-specific fields'),
                  children: disciplineFields.map<Widget>((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _disciplineField(field),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsStep(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GuidedStepBanner(
          message: _stepBanners[3],
          icon: Icons.track_changes_outlined,
        ),
        FormSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormSectionHeader(
                title: 'Range & scoring',
                subtitle: 'Fill in what you recorded — skip anything you did not measure.',
                requirement: FieldRequirement.optional,
              ),
              const SizedBox(height: 16),
              _measurementWithUnitField(
                controller: _distanceCtrl,
                valueLabel: 'Distance',
                unitValue: _distanceUnit,
                unitItems: ShootLogConstants.distanceUnits
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(
                          u == 'metres'
                              ? 'Metres'
                              : u == 'yards'
                                  ? 'Yards'
                                  : 'Feet',
                        ),
                      ),
                    )
                    .toList(),
                onUnitChanged: (v) => setState(() => _distanceUnit = v!),
                validator: (v) => _optionalDouble(v, label: 'Distance'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetTypeCtrl,
                decoration: fieldDecoration(
                  label: 'Target type',
                  hintText: 'Paper, clay, steel…',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stageNameCtrl,
                decoration: fieldDecoration(label: 'Stage / stand'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roundsCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => _nonNegativeInt(v, label: 'Rounds fired'),
                onChanged: (_) => _autoCalcMisses(),
                decoration: fieldDecoration(label: 'Rounds fired'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scoreCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => _optionalDouble(v, label: 'Score'),
                decoration: fieldDecoration(label: 'Score'),
              ),
              const SizedBox(height: 16),
              FormField<String>(
                validator: _validateHitsMisses,
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _hitsCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => _nonNegativeInt(v, label: 'Hits'),
                      onChanged: (_) {
                        _autoCalcMisses();
                        state.didChange(_hitsCtrl.text);
                      },
                      decoration: fieldDecoration(label: 'Hits'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _missesCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => _nonNegativeInt(v, label: 'Misses'),
                      onChanged: (v) => state.didChange(v),
                      decoration: fieldDecoration(
                        label: 'Misses',
                        helperText: 'Filled automatically from rounds − hits',
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          state.errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _measurementWithUnitField(
                controller: _groupSizeCtrl,
                valueLabel: 'Group size',
                unitValue: _groupSizeUnit,
                unitItems: ShootLogConstants.groupSizeUnits
                    .map(
                      (u) => DropdownMenuItem(value: u, child: Text(u)),
                    )
                    .toList(),
                onUnitChanged: (v) => setState(() => _groupSizeUnit = v!),
                validator: (v) => _optionalDouble(v, label: 'Group size'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FormSectionCard(
          child: SessionPhotoPicker(
            title: 'Target photos',
            subtitle: 'Your target, grouping, or score sheet.',
            photos: _targetPhotos,
            onAdd: (source) => _addPhoto(source, _targetPhotos, 6),
            onRemove: (index) => setState(() => _targetPhotos.removeAt(index)),
            emptyHint: 'Snap your target or pick from gallery',
          ),
        ),
      ],
    );
  }

  Widget _buildFinishStep(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GuidedStepBanner(
          message: _stepBanners[4],
          icon: Icons.check_circle_outline_rounded,
        ),
        FormSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormSectionHeader(
                title: 'Session rating',
                requirement: FieldRequirement.optional,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...List.generate(5, (i) {
                    final star = i + 1;
                    return IconButton(
                      onPressed: () => setState(
                        () => _rating = _rating == star ? 0 : star,
                      ),
                      icon: Icon(
                        _rating >= star
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: _rating >= star
                            ? Colors.amber
                            : theme.colorScheme.onSurfaceVariant,
                        size: 36,
                      ),
                    );
                  }),
                  if (_rating > 0)
                    TextButton(
                      onPressed: () => setState(() => _rating = 0),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_venueType == 'outdoor') ...[
          const SizedBox(height: 12),
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormSectionHeader(
                  title: 'Weather',
                  subtitle:
                      'Prefilled from GPS when you reach this step. Edit any field.',
                  requirement: FieldRequirement.optional,
                ),
                const SizedBox(height: 12),
                if (_latitude != null && _longitude != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Using coordinates ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (ref.watch(isOnlineProvider))
                  OutlinedButton.icon(
                    onPressed: _fetchingWeather ? null : _fetchWeather,
                    icon: _fetchingWeather
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download_outlined, size: 18),
                    label: Text(
                      _fetchingWeather
                          ? 'Getting weather…'
                          : 'Refresh from location',
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weatherCtrl,
                  decoration: fieldDecoration(
                    label: 'Condition',
                    prefixIcon: Icons.wb_sunny_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tempCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => _optionalDouble(v, label: 'Temperature'),
                  decoration: fieldDecoration(label: 'Temperature (°C)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _humidityCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => _optionalDouble(v, label: 'Humidity'),
                  decoration: fieldDecoration(label: 'Humidity (%)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _windSpeedCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => _optionalDouble(v, label: 'Wind speed'),
                  decoration: fieldDecoration(label: 'Wind speed (km/h)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _windDirCtrl,
                  decoration: fieldDecoration(
                    label: 'Wind direction',
                    hintText: 'NE (45°)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _windGustCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => _optionalDouble(v, label: 'Wind gust'),
                  decoration: fieldDecoration(label: 'Wind gusts (km/h)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pressureCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => _optionalDouble(v, label: 'Pressure'),
                  decoration: fieldDecoration(label: 'Pressure (hPa)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cloudCoverCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => _optionalDouble(v, label: 'Cloud cover'),
                  decoration: fieldDecoration(label: 'Cloud cover (%)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precipCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => _optionalDouble(v, label: 'Precipitation'),
                  decoration: fieldDecoration(label: 'Rain (mm)'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        FormSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormSectionHeader(
                title: 'Visibility',
                subtitle: 'Who can see this session on the website',
                requirement: FieldRequirement.optional,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _visibilityOverride,
                decoration: fieldDecoration(
                  label: 'Override profile default',
                  prefixIcon: Icons.visibility_outlined,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Use profile default')),
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(
                    value: 'friends_club_members',
                    child: Text('Friends & club members'),
                  ),
                  DropdownMenuItem(value: 'friends', child: Text('Friends only')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                ],
                onChanged: (v) => setState(() => _visibilityOverride = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FormSectionCard(
          child: SessionPhotoPicker(
            title: 'Session photos',
            subtitle: 'Range setup, kit layout, or anything worth remembering.',
            photos: _sessionPhotos,
            onAdd: (source) => _addPhoto(source, _sessionPhotos, 6),
            onRemove: (index) => setState(() => _sessionPhotos.removeAt(index)),
            emptyHint: 'Optional photos from your session',
          ),
        ),
        const SizedBox(height: 12),
        FormSectionCard(
          child: VoiceNoteRecorder(
            initialPath: _voiceNotePath,
            onPathChanged: (path) => setState(() => _voiceNotePath = path),
          ),
        ),
        const SizedBox(height: 12),
        FormSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormSectionHeader(
                title: 'Notes',
                requirement: FieldRequirement.optional,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: fieldDecoration(
                  label: 'Session notes',
                  alignLabelWithHint: true,
                  hintText:
                      'General observations, conditions, lessons learned…',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _measurementWithUnitField({
    required TextEditingController controller,
    required String valueLabel,
    required String unitValue,
    required List<DropdownMenuItem<String>> unitItems,
    required ValueChanged<String> onUnitChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          validator: validator,
          decoration: fieldDecoration(label: valueLabel),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: unitValue,
          decoration: fieldDecoration(label: '$valueLabel unit'),
          items: unitItems,
          onChanged: (v) {
            if (v != null) onUnitChanged(v);
          },
        ),
      ],
    );
  }

  Widget _disciplineField(DisciplineFieldDef field) {
    final value = _disciplineData[field.name] ?? '';
    switch (field.type) {
      case DisciplineFieldType.select:
        return DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: fieldDecoration(label: field.label),
          items: [
            const DropdownMenuItem(value: null, child: Text('— Select —')),
            ...field.options.map(
              (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
            ),
          ],
          onChanged: (v) =>
              setState(() => _disciplineData[field.name] = v ?? ''),
        );
      case DisciplineFieldType.number:
        return TextFormField(
          initialValue: value,
          keyboardType: TextInputType.number,
          decoration: fieldDecoration(label: field.label),
          onChanged: (v) => _disciplineData[field.name] = v,
        );
      case DisciplineFieldType.text:
        return TextFormField(
          initialValue: value,
          decoration: fieldDecoration(label: field.label),
          onChanged: (v) => _disciplineData[field.name] = v,
        );
    }
  }
}
