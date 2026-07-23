import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_hydro_repository.dart';
import '../models/models.dart';

class HydroQController extends ChangeNotifier {
  HydroQController({required MockHydroRepository repository})
      : _repository = repository,
        snapshot = repository.initialSnapshot(),
        plants = List<PlantProfile>.unmodifiable(repository.plantProfiles),
        alerts = List<AlertEvent>.unmodifiable(repository.alertEvents) {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_realtimeEnabled && deviceConfigured) {
        snapshot = _applySensorAvailability(
          _reclassifySnapshot(_repository.nextSnapshot(snapshot)),
        );
        notifyListeners();
      }
    });
  }

  final MockHydroRepository _repository;
  Timer? _timer;
  bool _realtimeEnabled = true;

  bool isAuthenticated = false;
  bool deviceConfigured = true;
  bool isRefreshing = false;
  String userName = 'Pengguna HydroQ';
  String userEmail = '';
  SensorSnapshot snapshot;
  final List<PlantProfile> plants;
  List<AlertEvent> alerts;
  PlantProfile? activePlant;
  List<CustomRecipe> recipes = <CustomRecipe>[];
  TankConfiguration tank = const TankConfiguration(
    name: 'Tangki Utama',
    capacityLiters: 60,
    heightCm: 45,
    minimumSafeVolumeLiters: 18,
  );
  DeviceInfo device = DeviceInfo(
    name: 'HydroQ Hub',
    serialNumber: 'HQ-ESP32-24071',
    firmwareVersion: '1.0.0',
    wifiName: 'Greenhouse-WiFi',
    lastSeen: DateTime.now(),
    online: true,
    phSensorAvailable: true,
    ecSensorAvailable: true,
    levelSensorAvailable: true,
  );
  NotificationPreferences notificationPreferences = const NotificationPreferences();

  CustomRecipe? get activeRecipe {
    for (final CustomRecipe recipe in recipes) {
      if (recipe.active) return recipe;
    }
    return null;
  }

  String get activeProfileLabel {
    if (activePlant != null) return 'Profil ${activePlant!.name}';
    if (activeRecipe != null) return activeRecipe!.name;
    return 'Belum ada profil aktif';
  }

  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    userEmail = email.trim();
    userName = email.split('@').first.replaceAll('.', ' ');
    if (userName.isNotEmpty) {
      userName = userName[0].toUpperCase() + userName.substring(1);
    }
    isAuthenticated = true;
    activePlant ??= plants.first;
    _realtimeEnabled = true;
    notifyListeners();
  }

  void logout() {
    isAuthenticated = false;
    _realtimeEnabled = false;
    notifyListeners();
  }

  ReportSummary getReport(ReportMetric metric, ReportPeriod period) {
    return _repository.report(metric, period);
  }

  Future<void> refreshNow() async {
    if (isRefreshing || !deviceConfigured) return;
    isRefreshing = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (device.online) {
      snapshot = _applySensorAvailability(
        _reclassifySnapshot(_repository.nextSnapshot(snapshot)),
      );
    }
    isRefreshing = false;
    notifyListeners();
  }

  void applyPlantProfile(PlantProfile plant) {
    activePlant = plant;
    recipes = recipes
        .map((CustomRecipe recipe) => recipe.copyWith(active: false))
        .toList();
    snapshot = _reclassifySnapshot(
      snapshot.copyWith(
        ph: _retarget(snapshot.ph, minimum: plant.phMin, maximum: plant.phMax),
        ec: _retarget(snapshot.ec, minimum: plant.ecMin, maximum: plant.ecMax),
        volume: _retarget(
          snapshot.volume,
          minimum: tank.minimumSafeVolumeLiters,
          maximum: tank.capacityLiters,
        ),
      ),
      warningMarginPercent: 10,
    );
    notifyListeners();
  }

  CustomRecipe copyPlantAsRecipe(PlantProfile plant) {
    final CustomRecipe recipe = CustomRecipe(
      id: 'recipe-${DateTime.now().millisecondsSinceEpoch}',
      name: '${plant.name} Racikan Saya',
      phMin: plant.phMin,
      phMax: plant.phMax,
      ecMin: plant.ecMin,
      ecMax: plant.ecMax,
      minimumVolumeLiters: tank.minimumSafeVolumeLiters,
      warningMarginPercent: 10,
      persistenceMinutes: 3,
      sourcePlantId: plant.id,
    );
    recipes = <CustomRecipe>[...recipes, recipe];
    notifyListeners();
    return recipe;
  }

  void saveRecipe(CustomRecipe recipe) {
    final int index = recipes.indexWhere((CustomRecipe item) => item.id == recipe.id);
    if (index == -1) {
      recipes = <CustomRecipe>[...recipes, recipe];
    } else {
      final List<CustomRecipe> updated = List<CustomRecipe>.from(recipes);
      updated[index] = recipe;
      recipes = updated;
    }
    if (recipe.active) {
      activateRecipe(recipe);
      return;
    }
    notifyListeners();
  }

  void activateRecipe(CustomRecipe recipe) {
    activePlant = null;
    recipes = recipes
        .map(
          (CustomRecipe item) => item.copyWith(active: item.id == recipe.id),
        )
        .toList();
    snapshot = _reclassifySnapshot(
      snapshot.copyWith(
        ph: _retarget(
          snapshot.ph,
          minimum: recipe.phMin,
          maximum: recipe.phMax,
          warningMarginPercent: recipe.warningMarginPercent,
        ),
        ec: _retarget(
          snapshot.ec,
          minimum: recipe.ecMin,
          maximum: recipe.ecMax,
          warningMarginPercent: recipe.warningMarginPercent,
        ),
        volume: _retarget(
          snapshot.volume,
          minimum: recipe.minimumVolumeLiters,
          maximum: tank.capacityLiters,
          warningMarginPercent: recipe.warningMarginPercent,
        ),
      ),
      warningMarginPercent: recipe.warningMarginPercent,
    );
    notifyListeners();
  }

  bool deleteRecipe(String id) {
    final int index = recipes.indexWhere((CustomRecipe item) => item.id == id);
    if (index < 0 || recipes[index].active) return false;
    recipes = <CustomRecipe>[...recipes]..removeAt(index);
    notifyListeners();
    return true;
  }

  void updateTank(TankConfiguration configuration) {
    tank = configuration;
    final double requestedMinimum =
        activeRecipe?.minimumVolumeLiters ?? configuration.minimumSafeVolumeLiters;
    final double effectiveMinimum = requestedMinimum < configuration.capacityLiters
        ? requestedMinimum
        : configuration.capacityLiters;
    snapshot = _reclassifySnapshot(
      snapshot.copyWith(
        capacityLiters: configuration.capacityLiters,
        volume: _retarget(
          snapshot.volume,
          minimum: effectiveMinimum,
          maximum: configuration.capacityLiters,
        ),
      ),
    );
    notifyListeners();
  }

  void updateNotificationPreferences(NotificationPreferences preferences) {
    notificationPreferences = preferences;
    notifyListeners();
  }

  void setDemoDeviceState({required bool online}) {
    final DateTime now = DateTime.now();
    device = DeviceInfo(
      name: device.name,
      serialNumber: device.serialNumber,
      firmwareVersion: device.firmwareVersion,
      wifiName: device.wifiName,
      lastSeen: now,
      online: online,
      phSensorAvailable: device.phSensorAvailable,
      ecSensorAvailable: device.ecSensorAvailable,
      levelSensorAvailable: device.levelSensorAvailable,
    );
    snapshot = _applySensorAvailability(
      snapshot.copyWith(
        deviceOnline: online,
        overallState: online
            ? combineReadingStates(
                <ReadingState>[
                  snapshot.ph.state,
                  snapshot.ec.state,
                  snapshot.volume.state,
                ],
              )
            : ReadingState.offline,
        updatedAt: online ? now : snapshot.updatedAt,
      ),
    );
    _realtimeEnabled = online;
    notifyListeners();
  }

  void setDemoStaleState({required bool stale}) {
    if (!deviceConfigured || !device.online) return;
    if (stale) {
      _realtimeEnabled = false;
      final DateTime staleAt = DateTime.now().subtract(const Duration(minutes: 12));
      MetricReading markStale(MetricReading reading) {
        return MetricReading(
          label: reading.label,
          value: reading.value,
          unit: reading.unit,
          minimum: reading.minimum,
          maximum: reading.maximum,
          state: reading.value == null ? ReadingState.unavailable : ReadingState.stale,
          updatedAt: staleAt,
          secondaryValue: reading.secondaryValue,
        );
      }

      snapshot = snapshot.copyWith(
        ph: markStale(snapshot.ph),
        ec: markStale(snapshot.ec),
        volume: markStale(snapshot.volume),
        updatedAt: staleAt,
        overallState: ReadingState.stale,
      );
    } else {
      _realtimeEnabled = true;
      snapshot = _applySensorAvailability(
        _reclassifySnapshot(_repository.nextSnapshot(snapshot)),
      );
    }
    notifyListeners();
  }

  void setSensorAvailability({bool? ph, bool? ec, bool? level}) {
    device = DeviceInfo(
      name: device.name,
      serialNumber: device.serialNumber,
      firmwareVersion: device.firmwareVersion,
      wifiName: device.wifiName,
      lastSeen: DateTime.now(),
      online: device.online,
      phSensorAvailable: ph ?? device.phSensorAvailable,
      ecSensorAvailable: ec ?? device.ecSensorAvailable,
      levelSensorAvailable: level ?? device.levelSensorAvailable,
    );
    final SensorSnapshot source = device.online
        ? _repository.nextSnapshot(snapshot)
        : snapshot;
    snapshot = _applySensorAvailability(_reclassifySnapshot(source));
    notifyListeners();
  }

  MetricReading _retarget(
    MetricReading reading, {
    required double minimum,
    required double maximum,
    int? warningMarginPercent,
  }) {
    return MetricReading(
      label: reading.label,
      value: reading.value,
      unit: reading.unit,
      minimum: minimum,
      maximum: maximum,
      state: classifyReading(
        value: reading.value,
        minimum: minimum,
        maximum: maximum,
        warningMarginPercent:
            warningMarginPercent ?? activeRecipe?.warningMarginPercent ?? 10,
      ),
      updatedAt: reading.updatedAt,
      secondaryValue: reading.secondaryValue,
    );
  }

  SensorSnapshot _reclassifySnapshot(
    SensorSnapshot source, {
    int? warningMarginPercent,
  }) {
    final int margin =
        warningMarginPercent ?? activeRecipe?.warningMarginPercent ?? 10;

    MetricReading classify(MetricReading reading) {
      return MetricReading(
        label: reading.label,
        value: reading.value,
        unit: reading.unit,
        minimum: reading.minimum,
        maximum: reading.maximum,
        state: classifyReading(
          value: reading.value,
          minimum: reading.minimum,
          maximum: reading.maximum,
          warningMarginPercent: margin,
        ),
        updatedAt: reading.updatedAt,
        secondaryValue: reading.secondaryValue,
      );
    }

    final MetricReading ph = classify(source.ph);
    final MetricReading ec = classify(source.ec);
    final MetricReading volume = classify(source.volume);
    return source.copyWith(
      ph: ph,
      ec: ec,
      volume: volume,
      overallState: source.deviceOnline
          ? combineReadingStates(
              <ReadingState>[ph.state, ec.state, volume.state],
            )
          : ReadingState.offline,
    );
  }

  SensorSnapshot _applySensorAvailability(SensorSnapshot source) {
    MetricReading unavailable(MetricReading reading) {
      return MetricReading(
        label: reading.label,
        value: null,
        unit: reading.unit,
        minimum: reading.minimum,
        maximum: reading.maximum,
        state: ReadingState.unavailable,
        updatedAt: reading.updatedAt,
      );
    }

    final bool incomplete = !device.phSensorAvailable || !device.ecSensorAvailable || !device.levelSensorAvailable;
    return source.copyWith(
      ph: device.phSensorAvailable ? source.ph : unavailable(source.ph),
      ec: device.ecSensorAvailable ? source.ec : unavailable(source.ec),
      volume: device.levelSensorAvailable ? source.volume : unavailable(source.volume),
      overallState: device.online && incomplete ? ReadingState.incomplete : source.overallState,
    );
  }

  void setDeviceConfigured(bool configured) {
    deviceConfigured = configured;
    _realtimeEnabled = configured && device.online;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class HydroQScope extends InheritedNotifier<HydroQController> {
  const HydroQScope({
    super.key,
    required HydroQController controller,
    required super.child,
  }) : super(notifier: controller);

  static HydroQController of(BuildContext context) {
    final HydroQScope? scope = context.dependOnInheritedWidgetOfExactType<HydroQScope>();
    assert(scope != null, 'HydroQScope tidak ditemukan di context.');
    return scope!.notifier!;
  }

  static HydroQController read(BuildContext context) {
    final InheritedElement? element = context.getElementForInheritedWidgetOfExactType<HydroQScope>();
    final HydroQScope? scope = element?.widget as HydroQScope?;
    assert(scope != null, 'HydroQScope tidak ditemukan di context.');
    return scope!.notifier!;
  }
}
