import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/core/models/models.dart';

void main() {
  test('volume percentage is clamped to a safe display range', () {
    final DateTime now = DateTime(2026, 7, 23);
    final SensorSnapshot snapshot = SensorSnapshot(
      ph: MetricReading(label: 'pH', value: 6.2, unit: '', minimum: 5.5, maximum: 6.5, state: ReadingState.normal, updatedAt: now),
      ec: MetricReading(label: 'Nutrisi', value: 1.5, unit: 'mS/cm', minimum: 1.2, maximum: 1.8, state: ReadingState.normal, updatedAt: now),
      volume: MetricReading(label: 'Volume', value: 75, unit: 'L', minimum: 20, maximum: 60, state: ReadingState.warning, updatedAt: now),
      capacityLiters: 60,
      deviceOnline: true,
      updatedAt: now,
      overallState: ReadingState.warning,
    );

    expect(snapshot.volumePercent, 100);
  });

  test('status labels never rely on color alone', () {
    for (final ReadingState state in ReadingState.values) {
      expect(state.label, isNotEmpty);
      expect(state.icon, isNotNull);
      expect(state.color, isNotNull);
    }
  });

  test('plant profile calculates TDS estimates from EC', () {
    const PlantProfile plant = PlantProfile(
      id: 'test',
      name: 'Test',
      category: 'Test',
      difficulty: 'Pemula',
      phMin: 5.5,
      phMax: 6.5,
      ecMin: 1.2,
      ecMax: 1.8,
      daysToHarvest: 30,
      description: 'Test',
      nutritionTips: <String>[],
      careTips: <String>[],
      commonProblems: <String>[],
      artSeed: 1,
    );

    expect(plant.tdsMin, 768);
    expect(plant.tdsMax, 1152);
  });

  group('reading classification', () {
    test('marks values outside the configured range as critical', () {
      expect(
        classifyReading(value: 5.2, minimum: 5.5, maximum: 6.5),
        ReadingState.critical,
      );
      expect(
        classifyReading(value: 6.8, minimum: 5.5, maximum: 6.5),
        ReadingState.critical,
      );
    });

    test('marks values inside the warning margin as warning', () {
      expect(
        classifyReading(value: 5.55, minimum: 5.5, maximum: 6.5),
        ReadingState.warning,
      );
      expect(
        classifyReading(value: 6.45, minimum: 5.5, maximum: 6.5),
        ReadingState.warning,
      );
    });

    test('marks values safely inside the range as normal', () {
      expect(
        classifyReading(value: 6.0, minimum: 5.5, maximum: 6.5),
        ReadingState.normal,
      );
    });

    test('combines states using operational severity', () {
      expect(
        combineReadingStates(<ReadingState>[
          ReadingState.normal,
          ReadingState.warning,
        ]),
        ReadingState.warning,
      );
      expect(
        combineReadingStates(<ReadingState>[
          ReadingState.warning,
          ReadingState.critical,
        ]),
        ReadingState.critical,
      );
      expect(
        combineReadingStates(<ReadingState>[
          ReadingState.normal,
          ReadingState.unavailable,
        ]),
        ReadingState.incomplete,
      );
      expect(
        combineReadingStates(<ReadingState>[
          ReadingState.critical,
          ReadingState.offline,
        ]),
        ReadingState.offline,
      );
    });
  });

}
