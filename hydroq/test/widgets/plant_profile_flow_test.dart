import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/app/hydroq_app.dart';
import 'package:hydroq/core/data/mock_hydro_repository.dart';
import 'package:hydroq/core/state/hydroq_controller.dart';

void main() {
  testWidgets('applying a plant profile requires tank-aware confirmation', (WidgetTester tester) async {
    final HydroQController controller = HydroQController(repository: MockHydroRepository());
    await tester.pumpWidget(HydroQApp(controller: controller));
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Edukasi').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Pakcoy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('Gunakan profil ini'));
    await tester.pump();
    await tester.tap(find.text('Gunakan profil ini'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Gunakan profil tanaman?'), findsOneWidget);
    expect(find.textContaining('Pakcoy'), findsWidgets);
    expect(find.textContaining('Tangki Utama'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Gunakan profil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.activePlant?.name, 'Pakcoy');
  });
}
