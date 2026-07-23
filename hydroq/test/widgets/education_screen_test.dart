import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/app/hydroq_app.dart';
import 'package:hydroq/core/data/mock_hydro_repository.dart';
import 'package:hydroq/core/state/hydroq_controller.dart';

void main() {
  testWidgets('education search narrows the plant grid', (WidgetTester tester) async {
    final HydroQController controller = HydroQController(repository: MockHydroRepository());
    await tester.pumpWidget(HydroQApp(controller: controller));

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Edukasi').last);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.showKeyboard(find.byType(TextField).first);
    tester.testTextInput.enterText('Tomat');
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('Tomat'), findsWidgets);
    expect(find.text('Selada'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
