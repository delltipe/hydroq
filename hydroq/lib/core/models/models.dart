import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum ReadingState {
  normal,
  warning,
  critical,
  stale,
  offline,
  incomplete,
  unavailable,
}

extension ReadingStateX on ReadingState {
  String get label {
    switch (this) {
      case ReadingState.normal:
        return 'Normal';
      case ReadingState.warning:
        return 'Perlu perhatian';
      case ReadingState.critical:
        return 'Kritis';
      case ReadingState.stale:
        return 'Data terlambat';
      case ReadingState.offline:
        return 'Perangkat offline';
      case ReadingState.incomplete:
        return 'Data tidak lengkap';
      case ReadingState.unavailable:
        return 'Tidak tersedia';
    }
  }

  String get shortLabel {
    switch (this) {
      case ReadingState.normal:
        return 'Normal';
      case ReadingState.warning:
        return 'Warning';
      case ReadingState.critical:
        return 'Critical';
      case ReadingState.stale:
        return 'Stale';
      case ReadingState.offline:
        return 'Offline';
      case ReadingState.incomplete:
        return 'Parsial';
      case ReadingState.unavailable:
        return 'N/A';
    }
  }

  Color get color {
    switch (this) {
      case ReadingState.normal:
        return AppColors.success;
      case ReadingState.warning:
        return AppColors.warning;
      case ReadingState.critical:
        return AppColors.critical;
      case ReadingState.stale:
        return AppColors.stale;
      case ReadingState.offline:
      case ReadingState.unavailable:
        return AppColors.offline;
      case ReadingState.incomplete:
        return AppColors.information;
    }
  }

  Color get softColor {
    switch (this) {
      case ReadingState.normal:
        return AppColors.successSoft;
      case ReadingState.warning:
        return AppColors.warningSoft;
      case ReadingState.critical:
        return AppColors.criticalSoft;
      case ReadingState.stale:
        return AppColors.staleSoft;
      case ReadingState.offline:
      case ReadingState.unavailable:
        return AppColors.offlineSoft;
      case ReadingState.incomplete:
        return AppColors.informationSoft;
    }
  }

  IconData get icon {
    switch (this) {
      case ReadingState.normal:
        return Icons.check_circle_outline_rounded;
      case ReadingState.warning:
        return Icons.warning_amber_rounded;
      case ReadingState.critical:
        return Icons.error_outline_rounded;
      case ReadingState.stale:
        return Icons.schedule_rounded;
      case ReadingState.offline:
        return Icons.cloud_off_outlined;
      case ReadingState.incomplete:
        return Icons.sensors_off_outlined;
      case ReadingState.unavailable:
        return Icons.remove_circle_outline_rounded;
    }
  }
}


ReadingState classifyReading({
  required double? value,
  required double minimum,
  required double maximum,
  int warningMarginPercent = 10,
}) {
  if (value == null) return ReadingState.unavailable;
  if (value < minimum || value > maximum) return ReadingState.critical;

  final double range = maximum - minimum;
  if (range <= 0) return ReadingState.normal;
  final double margin = range * warningMarginPercent.clamp(0, 50).toDouble() / 100;
  if (value <= minimum + margin || value >= maximum - margin) {
    return ReadingState.warning;
  }
  return ReadingState.normal;
}

ReadingState combineReadingStates(Iterable<ReadingState> states) {
  final Set<ReadingState> values = states.toSet();
  if (values.contains(ReadingState.offline)) return ReadingState.offline;
  if (values.contains(ReadingState.critical)) return ReadingState.critical;
  if (values.contains(ReadingState.incomplete) ||
      values.contains(ReadingState.unavailable)) {
    return ReadingState.incomplete;
  }
  if (values.contains(ReadingState.stale)) return ReadingState.stale;
  if (values.contains(ReadingState.warning)) return ReadingState.warning;
  return ReadingState.normal;
}

class MetricReading {
  const MetricReading({
    required this.label,
    required this.value,
    required this.unit,
    required this.minimum,
    required this.maximum,
    required this.state,
    required this.updatedAt,
    this.secondaryValue,
  });

  final String label;
  final double? value;
  final String unit;
  final double minimum;
  final double maximum;
  final ReadingState state;
  final DateTime updatedAt;
  final String? secondaryValue;

  String get formattedValue {
    if (value == null) return '—';
    if (label == 'pH') return value!.toStringAsFixed(1);
    if (label == 'Volume') return value!.toStringAsFixed(1);
    return value!.toStringAsFixed(2);
  }

  String get targetText {
    final int decimals = label == 'pH' || label == 'Volume' ? 1 : 2;
    return '${minimum.toStringAsFixed(decimals)}–${maximum.toStringAsFixed(decimals)} $unit'.trim();
  }
}

class SensorSnapshot {
  const SensorSnapshot({
    required this.ph,
    required this.ec,
    required this.volume,
    required this.capacityLiters,
    required this.deviceOnline,
    required this.updatedAt,
    required this.overallState,
  });

  final MetricReading ph;
  final MetricReading ec;
  final MetricReading volume;
  final double capacityLiters;
  final bool deviceOnline;
  final DateTime updatedAt;
  final ReadingState overallState;

  int get volumePercent {
    final double? liters = volume.value;
    if (liters == null || capacityLiters <= 0) return 0;
    return ((liters / capacityLiters) * 100).round().clamp(0, 100).toInt();
  }

  SensorSnapshot copyWith({
    MetricReading? ph,
    MetricReading? ec,
    MetricReading? volume,
    double? capacityLiters,
    bool? deviceOnline,
    DateTime? updatedAt,
    ReadingState? overallState,
  }) {
    return SensorSnapshot(
      ph: ph ?? this.ph,
      ec: ec ?? this.ec,
      volume: volume ?? this.volume,
      capacityLiters: capacityLiters ?? this.capacityLiters,
      deviceOnline: deviceOnline ?? this.deviceOnline,
      updatedAt: updatedAt ?? this.updatedAt,
      overallState: overallState ?? this.overallState,
    );
  }
}

class ChartPoint {
  const ChartPoint(this.label, this.value);

  final String label;
  final double value;
}

enum ReportMetric { ph, ec, volume }

enum ReportPeriod { daily, weekly, monthly }

extension ReportMetricX on ReportMetric {
  String get label {
    switch (this) {
      case ReportMetric.ph:
        return 'pH';
      case ReportMetric.ec:
        return 'EC / TDS';
      case ReportMetric.volume:
        return 'Volume';
    }
  }

  String get unit {
    switch (this) {
      case ReportMetric.ph:
        return '';
      case ReportMetric.ec:
        return 'mS/cm';
      case ReportMetric.volume:
        return 'L';
    }
  }
}

extension ReportPeriodX on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.daily:
        return 'Hari';
      case ReportPeriod.weekly:
        return 'Minggu';
      case ReportPeriod.monthly:
        return 'Bulan';
    }
  }
}

class ReportSummary {
  const ReportSummary({
    required this.points,
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.warningCount,
    required this.criticalCount,
    required this.abnormalDurationMinutes,
  });

  final List<ChartPoint> points;
  final double average;
  final double minimum;
  final double maximum;
  final int warningCount;
  final int criticalCount;
  final int abnormalDurationMinutes;

  int get sampleCount => points.length;
}

class AlertEvent {
  const AlertEvent({
    required this.id,
    required this.title,
    required this.message,
    required this.state,
    required this.createdAt,
    required this.metric,
    required this.valueText,
    this.durationMinutes,
    this.targetRange,
    this.endedAt,
    this.resolved = false,
  });

  final String id;
  final String title;
  final String message;
  final ReadingState state;
  final DateTime createdAt;
  final String metric;
  final String valueText;
  final int? durationMinutes;
  final String? targetRange;
  final DateTime? endedAt;
  final bool resolved;
}

class PlantProfile {
  const PlantProfile({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.phMin,
    required this.phMax,
    required this.ecMin,
    required this.ecMax,
    required this.daysToHarvest,
    required this.description,
    required this.nutritionTips,
    required this.careTips,
    required this.commonProblems,
    required this.artSeed,
    this.waterTempMin = 18,
    this.waterTempMax = 24,
    this.aliases = const <String>[],
  });

  final String id;
  final String name;
  final String category;
  final String difficulty;
  final double phMin;
  final double phMax;
  final double ecMin;
  final double ecMax;
  final int daysToHarvest;
  final String description;
  final List<String> nutritionTips;
  final List<String> careTips;
  final List<String> commonProblems;
  final int artSeed;
  final double waterTempMin;
  final double waterTempMax;
  final List<String> aliases;

  int get tdsMin => (ecMin * 640).round();
  int get tdsMax => (ecMax * 640).round();
}

class CustomRecipe {
  const CustomRecipe({
    required this.id,
    required this.name,
    required this.phMin,
    required this.phMax,
    required this.ecMin,
    required this.ecMax,
    required this.minimumVolumeLiters,
    required this.warningMarginPercent,
    required this.persistenceMinutes,
    this.sourcePlantId,
    this.active = false,
  });

  final String id;
  final String name;
  final double phMin;
  final double phMax;
  final double ecMin;
  final double ecMax;
  final double minimumVolumeLiters;
  final int warningMarginPercent;
  final int persistenceMinutes;
  final String? sourcePlantId;
  final bool active;

  CustomRecipe copyWith({
    String? id,
    String? name,
    double? phMin,
    double? phMax,
    double? ecMin,
    double? ecMax,
    double? minimumVolumeLiters,
    int? warningMarginPercent,
    int? persistenceMinutes,
    String? sourcePlantId,
    bool? active,
  }) {
    return CustomRecipe(
      id: id ?? this.id,
      name: name ?? this.name,
      phMin: phMin ?? this.phMin,
      phMax: phMax ?? this.phMax,
      ecMin: ecMin ?? this.ecMin,
      ecMax: ecMax ?? this.ecMax,
      minimumVolumeLiters: minimumVolumeLiters ?? this.minimumVolumeLiters,
      warningMarginPercent: warningMarginPercent ?? this.warningMarginPercent,
      persistenceMinutes: persistenceMinutes ?? this.persistenceMinutes,
      sourcePlantId: sourcePlantId ?? this.sourcePlantId,
      active: active ?? this.active,
    );
  }
}

class TankConfiguration {
  const TankConfiguration({
    required this.name,
    required this.capacityLiters,
    required this.heightCm,
    required this.minimumSafeVolumeLiters,
  });

  final String name;
  final double capacityLiters;
  final double heightCm;
  final double minimumSafeVolumeLiters;

  TankConfiguration copyWith({
    String? name,
    double? capacityLiters,
    double? heightCm,
    double? minimumSafeVolumeLiters,
  }) {
    return TankConfiguration(
      name: name ?? this.name,
      capacityLiters: capacityLiters ?? this.capacityLiters,
      heightCm: heightCm ?? this.heightCm,
      minimumSafeVolumeLiters: minimumSafeVolumeLiters ?? this.minimumSafeVolumeLiters,
    );
  }
}

class DeviceInfo {
  const DeviceInfo({
    required this.name,
    required this.serialNumber,
    required this.firmwareVersion,
    required this.wifiName,
    required this.lastSeen,
    required this.online,
    required this.phSensorAvailable,
    required this.ecSensorAvailable,
    required this.levelSensorAvailable,
  });

  final String name;
  final String serialNumber;
  final String firmwareVersion;
  final String wifiName;
  final DateTime lastSeen;
  final bool online;
  final bool phSensorAvailable;
  final bool ecSensorAvailable;
  final bool levelSensorAvailable;
}

class NotificationPreferences {
  const NotificationPreferences({
    this.allEnabled = true,
    this.phEnabled = true,
    this.ecEnabled = true,
    this.volumeEnabled = true,
    this.recoveryEnabled = true,
    this.deviceOfflineEnabled = true,
  });

  final bool allEnabled;
  final bool phEnabled;
  final bool ecEnabled;
  final bool volumeEnabled;
  final bool recoveryEnabled;
  final bool deviceOfflineEnabled;

  NotificationPreferences copyWith({
    bool? allEnabled,
    bool? phEnabled,
    bool? ecEnabled,
    bool? volumeEnabled,
    bool? recoveryEnabled,
    bool? deviceOfflineEnabled,
  }) {
    return NotificationPreferences(
      allEnabled: allEnabled ?? this.allEnabled,
      phEnabled: phEnabled ?? this.phEnabled,
      ecEnabled: ecEnabled ?? this.ecEnabled,
      volumeEnabled: volumeEnabled ?? this.volumeEnabled,
      recoveryEnabled: recoveryEnabled ?? this.recoveryEnabled,
      deviceOfflineEnabled: deviceOfflineEnabled ?? this.deviceOfflineEnabled,
    );
  }
}
