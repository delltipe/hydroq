import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hydroq/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can login, open education, and view a plant', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Kondisi air saat ini'), findsOneWidget);
    await tester.tap(find.text('Edukasi').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pakcoy'));
    await tester.pumpAndSettle();

    expect(find.text('Rentang air ideal'), findsOneWidget);
    expect(find.text('Gunakan profil ini'), findsOneWidget);
    expect(find.textContaining('Suhu air'), findsWidgets);
  });
}
