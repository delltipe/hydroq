import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/app/hydroq_app.dart';
import 'package:hydroq/core/data/mock_hydro_repository.dart';
import 'package:hydroq/core/state/hydroq_controller.dart';

void main() {
  testWidgets('demo login opens the dashboard', (WidgetTester tester) async {
    final HydroQController controller = HydroQController(repository: MockHydroRepository());
    await tester.pumpWidget(HydroQApp(controller: controller));

    expect(find.text('HydroQ'), findsOneWidget);
    expect(find.byKey(const Key('loginButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Kondisi air saat ini'), findsOneWidget);
    expect(find.text('Beranda'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
