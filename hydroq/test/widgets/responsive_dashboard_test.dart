import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/app/hydroq_app.dart';
import 'package:hydroq/core/data/mock_hydro_repository.dart';
import 'package:hydroq/core/state/hydroq_controller.dart';

Future<HydroQController> openDashboard(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  final HydroQController controller = HydroQController(repository: MockHydroRepository());
  await tester.pumpWidget(HydroQApp(controller: controller));
  await tester.tap(find.byKey(const Key('loginButton')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 300));
  return controller;
}

void main() {
  testWidgets('phone dashboard fits and uses bottom navigation', (WidgetTester tester) async {
    await openDashboard(tester, const Size(390, 844));

    expect(find.text('Kondisi air saat ini'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide dashboard switches to navigation rail', (WidgetTester tester) async {
    await openDashboard(tester, const Size(1100, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unconfigured device is explicit and keeps app usable', (WidgetTester tester) async {
    final HydroQController controller = await openDashboard(tester, const Size(390, 844));
    controller.setDeviceConfigured(false);
    await tester.pump();

    expect(find.text('Perangkat belum dikonfigurasi'), findsOneWidget);
    expect(find.text('Monitoring belum tersedia sampai perangkat dikonfigurasi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('partial sensor failure does not hide healthy values', (WidgetTester tester) async {
    final HydroQController controller = await openDashboard(tester, const Size(390, 844));
    controller.setSensorAvailability(ec: false);
    await tester.pump();

    expect(find.text('Data tidak lengkap'), findsOneWidget);
    expect(find.text('6.2'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
