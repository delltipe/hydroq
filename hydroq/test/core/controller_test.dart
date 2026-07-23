import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/core/data/mock_hydro_repository.dart';
import 'package:hydroq/core/models/models.dart';
import 'package:hydroq/core/state/hydroq_controller.dart';

void main() {
  late HydroQController controller;

  setUp(() {
    controller = HydroQController(repository: MockHydroRepository());
  });

  tearDown(() {
    controller.dispose();
  });

  test('login activates a beginner-friendly default plant profile', () async {
    await controller.login('demo@hydroq.app', 'hydroq123');

    expect(controller.isAuthenticated, isTrue);
    expect(controller.activePlant?.name, 'Selada');
    expect(controller.activeProfileLabel, 'Profil Selada');
  });

  test('copying plant profile creates a complete editable custom recipe', () {
    final CustomRecipe recipe = controller.copyPlantAsRecipe(controller.plants.first);

    expect(controller.recipes, hasLength(1));
    expect(recipe.name, contains('Racikan Saya'));
    expect(recipe.phMin, controller.plants.first.phMin);
    expect(recipe.minimumVolumeLiters, controller.tank.minimumSafeVolumeLiters);
    expect(recipe.warningMarginPercent, 10);
    expect(recipe.persistenceMinutes, 3);
  });

  test('activating a recipe replaces the active built-in profile', () {
    final CustomRecipe recipe = controller.copyPlantAsRecipe(controller.plants.first);
    controller.activateRecipe(recipe);

    expect(controller.activePlant, isNull);
    expect(controller.recipes.single.active, isTrue);
    expect(controller.snapshot.ec.minimum, recipe.ecMin);
    expect(controller.snapshot.volume.minimum, recipe.minimumVolumeLiters);
  });

  test('active recipe cannot be deleted', () {
    final CustomRecipe recipe = controller.copyPlantAsRecipe(controller.plants.first);
    controller.activateRecipe(recipe);

    expect(controller.deleteRecipe(recipe.id), isFalse);
    expect(controller.recipes, hasLength(1));
  });

  test('tank update refreshes capacity and safe volume target', () {
    const TankConfiguration configuration = TankConfiguration(
      name: 'Tangki Uji',
      capacityLiters: 80,
      heightCm: 55,
      minimumSafeVolumeLiters: 24,
    );

    controller.updateTank(configuration);

    expect(controller.snapshot.capacityLiters, 80);
    expect(controller.snapshot.volume.minimum, 24);
    expect(controller.snapshot.volume.maximum, 80);
  });

  test('offline demo state preserves last values and marks device offline', () {
    final double? previousPh = controller.snapshot.ph.value;
    controller.setDemoDeviceState(online: false);

    expect(controller.snapshot.deviceOnline, isFalse);
    expect(controller.snapshot.overallState, ReadingState.offline);
    expect(controller.snapshot.ph.value, previousPh);
  });

  test('partial sensor failure preserves healthy readings and marks snapshot incomplete', () {
    controller.setSensorAvailability(ec: false);

    expect(controller.snapshot.overallState, ReadingState.incomplete);
    expect(controller.snapshot.ec.value, isNull);
    expect(controller.snapshot.ph.value, isNotNull);
    expect(controller.snapshot.volume.value, isNotNull);
  });

  test('restoring a failed sensor immediately restores a reading', () {
    controller.setSensorAvailability(ec: false);
    expect(controller.snapshot.ec.value, isNull);

    controller.setSensorAvailability(ec: true);

    expect(controller.snapshot.ec.value, isNotNull);
    expect(controller.snapshot.overallState, isNot(ReadingState.incomplete));
  });

  test('unconfigured device disables monitoring state without losing data', () {
    final double? previousPh = controller.snapshot.ph.value;
    controller.setDeviceConfigured(false);

    expect(controller.deviceConfigured, isFalse);
    expect(controller.snapshot.ph.value, previousPh);
  });

  test('applying a plant profile reclassifies current readings against its targets', () {
    final PlantProfile pakcoy = controller.plants.firstWhere(
      (PlantProfile plant) => plant.name == 'Pakcoy',
    );

    controller.applyPlantProfile(pakcoy);

    expect(controller.activePlant, pakcoy);
    expect(controller.snapshot.ec.minimum, pakcoy.ecMin);
    expect(controller.snapshot.ec.maximum, pakcoy.ecMax);
    expect(controller.snapshot.ec.state, ReadingState.normal);
    expect(controller.snapshot.overallState, ReadingState.normal);
  });

  test('editing an active recipe immediately retargets the dashboard snapshot', () {
    final CustomRecipe original = controller.copyPlantAsRecipe(controller.plants.first);
    controller.activateRecipe(original);
    final CustomRecipe edited = original.copyWith(
      phMin: 6.3,
      phMax: 6.8,
      ecMin: 1.9,
      ecMax: 2.4,
      active: true,
    );

    controller.saveRecipe(edited);

    expect(controller.activeRecipe?.phMin, 6.3);
    expect(controller.snapshot.ph.minimum, 6.3);
    expect(controller.snapshot.ec.minimum, 1.9);
    expect(controller.snapshot.ph.state, ReadingState.critical);
    expect(controller.snapshot.ec.state, ReadingState.critical);
    expect(controller.snapshot.overallState, ReadingState.critical);
  });


  test('stale demo preserves readings and pauses freshness until recovery', () {
    final double? previousPh = controller.snapshot.ph.value;

    controller.setDemoStaleState(stale: true);

    expect(controller.snapshot.ph.value, previousPh);
    expect(controller.snapshot.ph.state, ReadingState.stale);
    expect(controller.snapshot.overallState, ReadingState.stale);
    expect(
      DateTime.now().difference(controller.snapshot.updatedAt),
      greaterThan(const Duration(minutes: 10)),
    );

    controller.setDemoStaleState(stale: false);
    expect(controller.snapshot.overallState, isNot(ReadingState.stale));
  });

}
